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
    
    let onStartInspection: (() -> ())?
    let onInspectionSecondsChange: ((_ inspectionSecs: Int) -> ())?
    let onStop: ((_ time: Double?, _ secondsElapsed: Double, _ phaseTimes: [Double]) -> ())?
    let onTouchUp: (() -> ())?
    let preTimerStart: (() -> ())?
    let onGesture: ((_ direction: UISwipeGestureRecognizer.Direction) -> ())?
    let onModeChange: ((_ mode: stopWatchMode) -> ())?
    
    init(
        onStartInspection: (() -> ())? = nil,
        onInspectionSecondsChange: ((_ inspectionSecs: Int) -> ())? = nil,
        onStop: ((_ time: Double?, _ secondsElapsed: Double, _ phaseTimes: [Double]) -> ())? = nil,
        onTouchUp: (() -> ())? = nil,
        preTimerStart: (() -> ())? = nil,
        onGesture: ((_ direction: UISwipeGestureRecognizer.Direction) -> ())? = nil,
        onModeChange: ((_ mode: stopWatchMode) -> ())? = nil
    ) {
        self.onStartInspection = onStartInspection
        self.onInspectionSecondsChange = onInspectionSecondsChange
        self.onStop = onStop
        self.onTouchUp = onTouchUp
        self.preTimerStart = preTimerStart
        self.onGesture = onGesture
        self.onModeChange = onModeChange
    }
    
    
    // TODO: NOW: set multiphaseCount when currentsessionchanged
    
    @Published var secondsStr = formatSolveTime(secs: 0)
    @Published var inspectionSecs = 0
    @Published var mode: stopWatchMode = .stopped {
        didSet {
            onModeChange?(mode)
        }
    }
    @Published var timerColour: Color = Color.Timer.normal
    
    var timeDP: Int = UserDefaults.standard.integer(forKey: generalSettingsKey.timeDpWhenRunning.rawValue)
    
    #warning("TODO: find a better way of this that doesnt need onChange in settings.")
    var inspectionEnabled: Bool = UserDefaults.standard.bool(forKey: generalSettingsKey.inspection.rawValue)
    var insCountDown: Bool = UserDefaults.standard.bool(forKey: generalSettingsKey.inspectionCountsDown.rawValue)
    var inspectionAlert: Bool = UserDefaults.standard.bool(forKey: generalSettingsKey.inspectionAlert.rawValue)
    var inspectionAlertType: Int = UserDefaults.standard.integer(forKey: generalSettingsKey.inspectionAlertType.rawValue)
    
    var hapticType: Int = UserDefaults.standard.integer(forKey: generalSettingsKey.hapType.rawValue) {
        didSet {
            calculateFeedbackStyle()
        }
    }
    var hapticEnabled: Bool = UserDefaults.standard.bool(forKey: generalSettingsKey.hapBool.rawValue) {
        didSet {
            calculateFeedbackStyle()
        }
    }
    
    var feedbackStyle: UIImpactFeedbackGenerator?
    
    private let systemSoundID: SystemSoundID = 1057
    private let inspectionAlert_8 = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "8sec-audio", ofType: "wav")!))
    private let inspectionAlert_12 = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "12sec-audio", ofType: "wav")!))
    
    
    private var justInspected = false
    var prevDownStoppedTimer = false
    var canGesture: Bool = true
    
    
    private var timer: Timer?
    private var timerStartTime: Date?
    var secondsElapsed = 0.0
    
    
    // MARK: multiphase
    private var currentMPCount: Int = 1
    private var phaseTimes: [Double] = []
    
    
    // EDITABLE
    var disabled = false {
        didSet {
            if disabled && mode == .stopped {
                self.timerColour = Color.Timer.loading
            } else if !disabled {
                self.timerColour = Color.Timer.normal
            }
        }
    }
    var phaseCount: Int? = nil
    
    
    // TODO: make this didset
    func calculateFeedbackStyle() {
        self.feedbackStyle = hapticEnabled ? UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.init(rawValue: hapticType)!) : nil
    }
    
    func handleGesture(direction: UISwipeGestureRecognizer.Direction) {
        onGesture?(direction)
    }
    
    func startInspection() {
        timer?.invalidate()
        onStartInspection?()
        secondsStr = insCountDown ? "15" : "0"
        inspectionSecs = 0
        mode = .inspecting
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            inspectionSecs += 1
            if insCountDown {
                if inspectionSecs == 16 {
                    self.secondsStr = "-"
                } else if inspectionSecs < 16 {
                    self.secondsStr = String(15 - inspectionSecs)
                }
            } else {
                self.secondsStr = String(inspectionSecs)
            }
            
            onInspectionSecondsChange?(inspectionSecs)
            
            
            if inspectionAlert && (inspectionSecs == 8 || inspectionSecs == 12) {
                if inspectionAlertType == 1 {
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
        justInspected = false
        secondsStr = formatSolveTime(secs: self.secondsElapsed, dp: timeDP)
        
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

        if timeDP != -1 {
            timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [self] timer in
                self.secondsElapsed = -timerStartTime!.timeIntervalSinceNow
                self.secondsStr = formatSolveTime(secs: self.secondsElapsed, dp: timeDP)
            }
        } else {
            self.secondsStr = "..."
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
        
        if mode != .stopped || !disabled || prevDownStoppedTimer {
            timerColour = Color.Timer.heldDown
        }
        
        if mode == .running {
            
            justInspected = false
            
            if let phaseCount = phaseCount {
                
                if phaseCount != currentMPCount {
                    canGesture = false
                    
                    currentMPCount += 1
                    lap()
                } else {
                    canGesture = true
                    
                    lap()
                    prevDownStoppedTimer = true
                    justInspected = false
                    stop(nil)
                }
            } else {
                canGesture = true
                prevDownStoppedTimer = true
                justInspected = false
                stop(nil)
            }
        }
    }
    
    
    func touchUp() {
        #if DEBUG
        NSLog("TC: Touchup")
        #endif
        
        if mode != .stopped || !disabled {
            timerColour = Color.Timer.normal
            
            if inspectionEnabled && mode == .stopped && !prevDownStoppedTimer {
                startInspection()
                justInspected = true
            }
        } else if prevDownStoppedTimer && disabled {
            timerColour = Color.Timer.loading
        }
        
        onTouchUp?()
        
        prevDownStoppedTimer = false
    }
    
    
    func longPressStart() {
        #if DEBUG
        NSLog("TC: long press start")
        #endif
        
        if inspectionEnabled ? mode == .inspecting : mode == .stopped && !prevDownStoppedTimer && ( mode != .stopped || !disabled ) {
            #if DEBUG
            NSLog("TC: * Timer can start")
            #endif
            
            timerColour = Color.Timer.canStart
            feedbackStyle?.impactOccurred()
        }
    }
    
    func longPressEnd() {
        #if DEBUG
        NSLog("TC: Long press end")
        #endif
        
        if mode != .stopped || !disabled {
            timerColour = Color.Timer.normal
        } else if prevDownStoppedTimer && disabled {
            timerColour = Color.Timer.loading
        }
        
        onTouchUp?()
        
        if !prevDownStoppedTimer && ( mode != .stopped || !disabled ) {
            if inspectionEnabled ? mode == .inspecting : mode == .stopped {
                start()
                preTimerStart?()
            } else if inspectionEnabled && mode == .stopped && !justInspected {
                startInspection()
                justInspected = true
            }
        }
        
        prevDownStoppedTimer = false
    }
    
    
    // multiphase
    func lap() {
        phaseTimes.append(-timerStartTime!.timeIntervalSinceNow)
    }
    
}
