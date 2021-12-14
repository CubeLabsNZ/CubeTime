//
//  StopWatchManager.swift
//  txmer
//
//  Created by macos sucks balls on 12/8/21.
//

import Foundation
import CoreData
import SwiftUI

//var userHoldTime: Double = 0.5
//let gestureKillTime: Double = 0.2
//let inspectionEnabled = true
//var inspectionEnabled = UserDefaults.standard.bool(forKey: gsKeys.inspection.rawValue)
let plustwotime = 15
let dnftime = 17

enum stopWatchMode {
    case running
    case stopped
    case inspecting
}

// TO left = discard
// TO right = reload scramble
// Double Tap = penalty menu TODO

class StopWatchManager: ObservableObject {
    @Binding var currentSession: Sessions
//    @Binding var feedbackType: Int
    let managedObjectContext: NSManagedObjectContext
    @Published var mode: stopWatchMode = .stopped
    
    @Published var showDeleteSolveConfirmation = false
    
    @Published var showPenOptions = false
    

    
    private var hapticType: Int = UserDefaults.standard.integer(forKey: gsKeys.hapType.rawValue)
    
    private var feedbackStyle: UIImpactFeedbackGenerator
    
    var inspectionEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.inspection.rawValue)
    var userHoldTime: Double = UserDefaults.standard.double(forKey: gsKeys.freeze.rawValue)
//    var gestureKillTime: Double = UserDefaults.standard.double(forKey: gsKeys.gestureDistance.rawValue)
    
    let scrambler = CHTScrambler.init()
    
    var scrambleType: Int32
    var scrambleSubType: Int32 = 0
    
    @Published var scrambleStr: String? = nil
    private var nextScrambleStr: String? = nil
    
    init (currentSession: Binding<Sessions>, /*feedbackType: Binding<Int>, */managedObjectContext: NSManagedObjectContext) {
        _currentSession = currentSession
//        _feedbackType = feedbackType
        self.managedObjectContext = managedObjectContext
        self.feedbackStyle = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.init(rawValue: hapticType)!)
        
        scrambler.initSq1()
        scrambleType = currentSession.wrappedValue.scramble_type
        secondsStr = formatSolveTime(secs: 0)
        DispatchQueue.main.async {
            self.rescramble()
        }
        
        NSLog(String(hapticType))
        
    }
    
    private var timerStartTime: Date?
    
    var penType: PenTypes = .none
    
    var secondsElapsed = 0.0
    @Published var secondsStr = ""
    
    var timer: Timer?
    
    /// todo set custom fps for battery purpose, promotion can set as low as 10 / 24hz ,others 60 fixed, no option for them >:C
    var frameTime: Double = 1/60
    
    
    func safeGetScramble() -> String {
        let scr = CHTScramble.getNewScramble(by: scrambler, type: scrambleType, subType: scrambleSubType)
        if let scr = scr {
            return scr.scramble
        } else {
            return "Failed to load scramble"
        }
    }
    
    func rescramble() {
        if nextScrambleStr == nil { nextScrambleStr = safeGetScramble() }
        scrambleStr = nextScrambleStr
        nextScrambleStr = safeGetScramble()
    }
    
    
    private var canStartTimer = false
    private var allowGesture = true
    
    
    var inspectionSecs = 0
    
    func startInspection() {
        timer?.invalidate()
        secondsStr = "0"
        inspectionSecs = 0
        mode = .inspecting
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            inspectionSecs += 1
            self.secondsStr = String(inspectionSecs)
            if inspectionSecs == plustwotime {
                penType = .plustwo
            } else if inspectionSecs == dnftime {
                penType = .dnf
            }
        }
    }
    
    func start() {
        NSLog("start called")
        canStartTimer = false
        mode = .running
        
        timer?.invalidate() // Stop possibly running inspections
        
        secondsElapsed = 0
        secondsStr = formatSolveTime(secs: 0)
        timerStartTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [self] timer in
            self.secondsElapsed = -timerStartTime!.timeIntervalSinceNow
            self.secondsStr = formatSolveTime(secs: self.secondsElapsed)
        }
        NSLog("started timer i think")
    }
    
    func stop() {
        timer?.invalidate()
        mode = .stopped

    }
    
    @Published var timerColour: Color = TimerTextColours.timerDefaultColour
    
    
    private var taskTimerReady: DispatchWorkItem?
    
    @Published var solveItem: Solves!
    
    
    
    private var prevIsDown = false
    private var prevDownStoppedTheTimer = false
    private var prevDownTriggeredGesture = false
    
    private var asyncScrambleTask: DispatchWorkItem?
    
    let threshold = 50 as CGFloat
    
    func touchDown(value: DragGesture.Value) {
        if prevIsDown {
            NSLog("allowgesture: \(allowGesture) !canstarttimer: \(!canStartTimer) !prevdownstoppedthetimer: \(!prevDownStoppedTheTimer) mode != inspectiuong \(mode != .inspecting)")
            if allowGesture && !canStartTimer && !prevDownStoppedTheTimer && mode != .inspecting {
                if abs(value.translation.width) > threshold && abs(value.translation.height) < abs(value.translation.width) {
                    taskTimerReady?.cancel() // TODO maybe dont do this idk ask tim
                    allowGesture = false
                    prevDownTriggeredGesture = true
                    if value.translation.width > 0 {
                        NSLog("Right") // TODO buttosn optionsal
                        rescramble() // TODO customize
                        self.feedbackStyle.impactOccurred()
                    } else {
                        NSLog("Left")
                        if solveItem != nil {
                            prevIsDown = false // Showing a dialog implies touch up
                            timerColour = .black
                            prevDownTriggeredGesture = false
                            showDeleteSolveConfirmation = true
                            self.feedbackStyle.impactOccurred()
                        }
                    }
                } else if abs(value.translation.height) > threshold && abs(value.translation.width) < abs(value.translation.height) {
                    taskTimerReady?.cancel() // TODO maybe dont do this idk ask tim
                    allowGesture = false
                    prevDownTriggeredGesture = true
                    if value.translation.height > 0 {
                        if solveItem != nil {
                            self.feedbackStyle.impactOccurred()
                            withAnimation {
                                showPenOptions = true
                            }
                        }
                    } else {
                        NSLog("Up")
                    }
                }
            }
        } else { // touchDown is called on DragGesture's onChange, which calls every time finger is moved a substantial amount
            prevIsDown = true
            prevDownStoppedTheTimer = false
            
            timerColour = TimerTextColours.timerHeldDownColour
            NSLog("Down")
            if mode == .running {
                stop()
                prevDownStoppedTheTimer = true
                solveItem = Solves(context: managedObjectContext)
                // .comment
                solveItem.date = Date()
                solveItem.penalty = penType.rawValue
                // .puzzle_id
                solveItem.session = currentSession
                // currentSession!.addToSolves(solveItem)
                solveItem.scramble = scrambleStr
                solveItem.scramble_type = scrambleType
                solveItem.scramble_subtype = scrambleSubType
                // .starred
                solveItem.time = self.secondsElapsed
                try! managedObjectContext.save()
                DispatchQueue.main.async {
                    self.rescramble()
                }
            } else if (mode == .inspecting && inspectionEnabled) || (mode == .stopped && !inspectionEnabled) {
                let newTaskTimerReady = DispatchWorkItem {
                    self.canStartTimer = true
                    self.timerColour = TimerTextColours.timerCanStartColour
                    self.feedbackStyle.impactOccurred()
                }
                taskTimerReady = newTaskTimerReady
                DispatchQueue.main.asyncAfter(deadline: .now() + userHoldTime, execute: newTaskTimerReady)
            }
        }
    }
    
    func touchUp(value: DragGesture.Value) {
        //timer?.invalidate() // Invalidate possible running inspections
        prevIsDown = false
        allowGesture = true
        if !prevDownTriggeredGesture {
            withAnimation {
                showPenOptions = false
            }
        }
        NSLog("up")
        NSLog("\(mode == .stopped) \(inspectionEnabled) \(!prevDownStoppedTheTimer) \(!prevDownTriggeredGesture)")
        if mode == .stopped && inspectionEnabled && !prevDownStoppedTheTimer && !prevDownTriggeredGesture {
            startInspection()
        } else if canStartTimer {
            NSLog("calling start")
            start()
        }
        prevDownTriggeredGesture = false
        timerColour = TimerTextColours.timerDefaultColour
        taskTimerReady?.cancel()
    }
    
    func changedPen() {
        withAnimation {
            secondsStr = formatSolveTime(secs: secondsElapsed, penType: PenTypes(rawValue: solveItem.penalty)!)
        }
    }
}
