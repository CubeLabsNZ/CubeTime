//
//  TimerController.swift
//  CubeTime
//
//  Created by trainz-are-kul on 26/02/23.
//

import Foundation
import AudioToolbox
import AVFAudio
import SwiftUI


let inspectionDnfTime = 17
let inspectionPlusTwoTime = 15

class TimerContoller: ObservableObject {
    let sm = SettingsManager.standard
    
    let onStartInspection: (() -> ())?
    let onInspectionSecondsChange: ((_ inspectionSecs: Int) -> ())?
    let onStop: ((_ time: Double?, _ secondsElapsed: Double, _ phaseTimes: [Double]) -> ())?
    let onTouchUp: (() -> ())?
    let preTimerStart: (() -> ())?
    let onGesture: ((_ direction: UISwipeGestureRecognizer.Direction) -> ())?
    let onModeChange: ((_ mode: TimerState) -> ())?
    
    init(
        onStartInspection: (() -> ())? = nil,
        onInspectionSecondsChange: ((_ inspectionSecs: Int) -> ())? = nil,
        onStop: ((_ time: Double?, _ secondsElapsed: Double, _ phaseTimes: [Double]) -> ())? = nil,
        onTouchUp: (() -> ())? = nil,
        preTimerStart: (() -> ())? = nil,
        onGesture: ((_ direction: UISwipeGestureRecognizer.Direction) -> ())? = nil,
        onModeChange: ((_ mode: TimerState) -> ())? = nil
    ) {
        self.onStartInspection = onStartInspection
        self.onInspectionSecondsChange = onInspectionSecondsChange
        self.onStop = onStop
        self.onTouchUp = onTouchUp
        self.preTimerStart = preTimerStart
        self.onGesture = onGesture
        self.onModeChange = onModeChange
    }
    
        
    @Published var secondsStr = formatSolveTime(secs: 0)
    @Published var inspectionSecs = 0
    @Published var mode: TimerState = .stopped {
        didSet {
            onModeChange?(mode)
        }
    }
    @Published var timerColour: Color = Color.Timer.normal
        
    var feedbackStyle: UIImpactFeedbackGenerator? {
        get {
            sm.hapticEnabled ? UIImpactFeedbackGenerator(style: sm.hapticType) : nil
        }
    }
    
    private let systemSoundID: SystemSoundID = 1057
    private let inspectionAlert_8 = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "8sec-audio", ofType: "wav")!))
    private let inspectionAlert_12 = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "12sec-audio", ofType: "wav")!))
    
    private var isModeBeforeStart: Bool {
        get {
            sm.inspection ? mode == .inspecting : mode == .stopped
        }
    }
    
    var prevDownStoppedTimer = false
    
    
    private var timer: Timer?
    private var timerStartTime: Date?
    var secondsElapsed = 0.0
    
    
    // MARK: multiphase
    private var currentMPCount: Int = 1
    private var phaseTimes: [Double] = []
    
    
    // EDITABLE
    var preventStart = false {
        didSet {
            if preventStart && mode == .stopped {
                self.timerColour = Color.Timer.loading
            } else if !preventStart {
                self.timerColour = Color.Timer.normal
            }
        }
    }
    var phaseCount: Int? = nil
    
    func handleGesture(direction: UISwipeGestureRecognizer.Direction) {
        prevDownStoppedTimer = false
        NSLog("HERE1 \(!preventStart) || \(mode != .stopped)")
        if !preventStart || mode != .stopped {
            NSLog("HERE2")
            timerColour = Color.Timer.normal
        }
        if mode == .stopped {
            onGesture?(direction)
        }
    }
    
    func startInspection() {
        timer?.invalidate()
        onStartInspection?()
        secondsStr = sm.inspectionCountsDown ? "15" : "0"
        inspectionSecs = 0
        mode = .inspecting
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            inspectionSecs += 1
            if sm.inspectionCountsDown {
                if inspectionSecs == 16 {
                    self.secondsStr = "-"
                } else if inspectionSecs < 16 {
                    self.secondsStr = String(15 - inspectionSecs)
                }
            } else {
                self.secondsStr = String(inspectionSecs)
            }
            
            onInspectionSecondsChange?(inspectionSecs)
            
            
            if sm.inspectionAlert && (inspectionSecs == 8 || inspectionSecs == 12) {
                if sm.inspectionAlertType == 1 {
                    AudioServicesPlayAlertSound(systemSoundID)
                } else {
                    if inspectionSecs == 8 {
                        inspectionAlert_8.play()
                    } else {
                        inspectionAlert_12.play()
                    }
                }
            }
        }
    }
    
    func interruptInspection() {
        mode = .stopped
        
        timer?.invalidate()
        inspectionSecs = 0
        secondsElapsed = 0
        secondsStr = formatSolveTime(secs: self.secondsElapsed, dp: sm.timeDpWhenRunning)
        
    }

    
    
    
    func start() {
        #if DEBUG
        NSLog("TC: Starting")
        #endif
        
        mode = .running

        timer?.invalidate() // Stop possibly running inspections

        secondsElapsed = 0
        secondsStr = formatSolveTime(secs: 0)
        timerStartTime = Date()

        if sm.timeDpWhenRunning == -1 {
            self.secondsStr = "..."
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [self] timer in
                self.secondsElapsed = -timerStartTime!.timeIntervalSinceNow
                self.secondsStr = formatSolveTime(secs: self.secondsElapsed, dp: sm.timeDpWhenRunning)
            }
        }
    }
    
    
    func stop(_ time: Double?) {
        #if DEBUG
        NSLog("TC: Stopping")
        #endif
        
        timer?.invalidate()
        
        if let time = time {
            self.secondsElapsed = time
        } else {
            prevDownStoppedTimer = true
            self.secondsElapsed = -timerStartTime!.timeIntervalSinceNow
        }
        
        self.secondsStr = formatSolveTime(secs: self.secondsElapsed)
        
        mode = .stopped
        
        onStop?(time, secondsElapsed, phaseTimes)
        
        if phaseCount != nil {
            currentMPCount = 1
            phaseTimes = []
        }
    }
    
    
    func touchDown() {
        #if DEBUG
        NSLog("TC: Touch down")
        #endif
        
        if mode != .stopped || !preventStart {
            timerColour = Color.Timer.heldDown
        }
        
        if mode != .running {
            return
        }
        
        if let phaseCount = phaseCount, phaseCount != currentMPCount {
            lap()
        } else {
            lap()
            stop(nil)
        }
    }
    

    func longPressStart() {
        #if DEBUG
        NSLog("TC: long press start")
        #endif
        
        if isModeBeforeStart && !prevDownStoppedTimer && !preventStart {
            #if DEBUG
            NSLog("TC: * Timer can start")
            #endif
            
            timerColour = Color.Timer.canStart
            feedbackStyle?.impactOccurred()
        }
    }
    
    
    func touchUpCommon() {
        if mode != .stopped || !preventStart {
            timerColour = Color.Timer.normal
        } else if prevDownStoppedTimer && preventStart {
            timerColour = Color.Timer.loading
        }
        
        onTouchUp?()
    }
    
    func touchUp() {
        #if DEBUG
        NSLog("TC: Touchup")
        #endif
        
        touchUpCommon()
        
        if sm.inspection && mode == .stopped && !prevDownStoppedTimer && !preventStart {
            startInspection()
        }
        
        prevDownStoppedTimer = false
    }
    
    func longPressEnd() {
        #if DEBUG
        NSLog("TC: Long press end")
        #endif
        
        touchUpCommon()
        
        if prevDownStoppedTimer {
            prevDownStoppedTimer = false
            return
        }
        
        if preventStart {
            return
        }
        
        if isModeBeforeStart {
            start()
            preTimerStart?()
        } else if sm.inspection {
            startInspection()
        }
    }
    
    // multiphase
    func lap() {
        currentMPCount += 1
        phaseTimes.append(-timerStartTime!.timeIntervalSinceNow)
        print("lapped")
    }
}
