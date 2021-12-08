//
//  StopWatchManager.swift
//  txmer
//
//  Created by macos sucks balls on 12/8/21.
//

import Foundation
import CoreData
import SwiftUI

var userHoldTime: Double = 0.5 /// todo make so user can set in setting
let gestureKillTime: Double = 0.2

enum stopWatchMode {
    case running
    case stopped
}

// TO left = discard
// TO right = reload scramble
// Double Tap = penalty menu

class StopWatchManager: ObservableObject {
    @Binding var currentSession: Sessions
    let managedObjectContext: NSManagedObjectContext
    @Published var mode: stopWatchMode = .stopped
    
    let scrambler = CHTScrambler.init()
    
    var scrambleType: Int32
    var scrambleSubType: Int32 = 0
    
    var prevScrambleStr: String? = nil
    @Published var scrambleStr: String? = nil
    
    init (currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext) {
        _currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        scrambler.initSq1()
        scrambleType = currentSession.wrappedValue.scramble_type
        let scr = CHTScramble.getNewScramble(by: scrambler, type: scrambleType, subType: scrambleSubType)
        scrambleStr = scr?.scramble
    }
    
    private var timerStartTime: Date?
    
    @Published var secondsElapsed = 0.0
    
    @Environment(\.colorScheme) var colourScheme
    
    var timer = Timer()
    
    /// todo set custom fps for battery purpose, promotion can set as low as 10 / 24hz ,others 60 fixed, no option for them >:C
    var frameTime: Double = 1/60
    
    
    func rescramble() {
        prevScrambleStr = scrambleStr
        let scr = CHTScramble.getNewScramble(by: scrambler, type: scrambleType, subType: scrambleSubType)
        scrambleStr = scr?.scramble
    }
    
    
    private var canStartTimer = false
    private var allowGesture = true
    
    func start() {
        NSLog("start called")
        canStartTimer = false
        mode = .running
        
        secondsElapsed = 0
        timerStartTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [self] timer in
            self.secondsElapsed = -timerStartTime!.timeIntervalSinceNow
        }
        NSLog("started timer i think")
        
        rescramble()
        
        NSLog("scrambled")
    }
    
    func stop() {
        timer.invalidate()
        mode = .stopped

    }
    
    @Published var timerColour: Color = TimerTextColours.timerDefaultColour
    
    
    private var taskTimerReady: DispatchWorkItem?
    
    var solveItem: Solves!
    
    
    private let feedbackStyle = UIImpactFeedbackGenerator(style: .rigid) /// TODO: add option to change heaviness/turn on off in settings
    
    private var prevIsDown = false
    private var prevDownStoppedTheTimer = false
    
    let threshold = 50 as CGFloat
    
    func touchDown(value: DragGesture.Value) {
        if prevIsDown {
            if allowGesture && !canStartTimer && !prevDownStoppedTheTimer {
                if abs(value.translation.width) > threshold && abs(value.translation.height) < abs(value.translation.width) {
                    taskTimerReady?.cancel() // TODO maybe dont do this idk ask tim
                    allowGesture = false
                    if value.translation.width > 0 {
                        NSLog("Right")
                        rescramble() // TODO customize
                        self.feedbackStyle.impactOccurred()
                    } else {
                        NSLog("Left")
                            if solveItem != nil {
                            managedObjectContext.delete(solveItem)
                            solveItem = nil
                            secondsElapsed = 0
                            self.feedbackStyle.impactOccurred()
                        }
                    }
                } else if abs(value.translation.height) > threshold && abs(value.translation.width) < abs(value.translation.height) {
                    taskTimerReady?.cancel() // TODO maybe dont do this idk ask tim
                    allowGesture = false
                    if value.translation.height > 0 {
                        NSLog("Down")
                    } else {
                        NSLog("Up")
                    } // TODO disallow gestures after 200 ms
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
                // .penalty
                // .puzzle_id
                solveItem.session = currentSession /// ???
                // currentSession!.addToSolves(solveItem)
                solveItem.scramble = prevScrambleStr
                solveItem.scramble_type = scrambleType
                solveItem.scramble_subtype = scrambleSubType
                // .starred
                solveItem.time = self.secondsElapsed
                try! managedObjectContext.save()
            } else { // TODO on update gesture cancels the taskAfterHold once a drag started past a certain threshold
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
        prevIsDown = false
        allowGesture = true
        NSLog("up")
        
        if canStartTimer {
            NSLog("calling start")
            start()
        }
        timerColour = ((colourScheme == .light) ? Color.black : Color.white)
        taskTimerReady?.cancel()
    }
}
