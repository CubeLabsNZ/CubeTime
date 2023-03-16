import Foundation
import SwiftUI
import UIKit


class TimerUIView: UIViewController {
    let timerController: TimerContoller
    let stopwatchManager: StopwatchManager

        
    required init(timerController: TimerContoller, stopwatchManager: StopwatchManager, userHoldTime: Double) {
        self.timerController = timerController
        self.stopwatchManager = stopwatchManager
        self.userHoldTime = userHoldTime
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #warning("TODO:  make this a subclass of UIGestureRecognizer instead to use the same coordinator")
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIApplication.shared.isIdleTimerDisabled = true
        timerController.touchDown()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        timerController.touchUp()
    }
    
    // Setting coming soon. Watch this space :)
    // - backspace/del/ctrl-z = delete
    // - plus/ctrl-n/ctrl-rightarrow = new scramble
    // - ctrl-1,2,3 = ok, +2, dnf
    // - option-{2,7 | M | S | K | P | C | B} = switch playground puzzle type
    
    #warning("TODO: make this a UIMenu for mac catalyst and sections in the discoverability overlay")
    override var keyCommands: [UIKeyCommand]? {
        get {
            if (stopwatchManager.timerController !== timerController) {return []}
            let curPen: Penalty? = {
                guard let pen = self.stopwatchManager.solveItem?.penalty else {return nil}
                return Penalty(rawValue: pen)
            }()
            
            return [
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve(key:)), input: "\u{08}", discoverabilityTitle: "Delete Solve", attributes: .destructive),
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve(key:)), input: UIKeyCommand.inputDelete, discoverabilityTitle: "Delete Solve", attributes: .destructive),
                // ANSI delete (above doesnt register in simulator? not sure
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve(key:)), input: "\u{7F}", attributes: .destructive),
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve(key:)), input: "z", modifierFlags: [.command], discoverabilityTitle: "Delete Solve", attributes: .destructive),
                
                UIKeyCommand(title: "New Scramble", action: #selector(newScr(key:)), input: "+", discoverabilityTitle: "New Scramble"),
                UIKeyCommand(title: "New Scramble", action: #selector(newScr(key:)), input: "n", modifierFlags: [.command], discoverabilityTitle: "New Scramble"),
                UIKeyCommand(title: "New Scramble", action: #selector(newScr(key:)), input: UIKeyCommand.inputRightArrow, modifierFlags: [.command], discoverabilityTitle: "New Scramble"),
                
                UIKeyCommand(title: "Penalty: None", action: #selector(penNone(key:)), input: "1", modifierFlags: [.command], discoverabilityTitle: "Remove the current penalty", state: curPen == Penalty.none ? .on : .off),
                UIKeyCommand(title: "Penalty: +2", action: #selector(penPlus2(key:)), input: "2", modifierFlags: [.command], discoverabilityTitle: "Set the current penalty to +2", state: curPen == .plustwo ? .on : .off),
                UIKeyCommand(title: "Penalty: DNF", action: #selector(penDNF(key:)), input: "3", modifierFlags: [.command], discoverabilityTitle: "Set the current penalty to DNF", state: curPen == .dnf ? .on : .off),
                
                
                UIKeyCommand(title: "Playground scramble: 2x2", action: #selector(setScrambleTo2x2(key:)), input: "2", modifierFlags: [.alternate], discoverabilityTitle: "Set the current playground scramble to 2x2")
            ]
        }
    }
    
    @objc func deleteSolve(key: UIKeyCommand?) {
        stopwatchManager.deleteLastSolve()
    }
    
    @objc func newScr(key: UIKeyCommand?) {
        stopwatchManager.scrambleController.rescramble()
    }
    
    @objc func penNone(key: UIKeyCommand?) {
        stopwatchManager.changePen(to: .none)
    }
    
    @objc func penPlus2(key: UIKeyCommand?) {
        stopwatchManager.changePen(to: .plustwo)
    }
    
    @objc func penDNF(key: UIKeyCommand?) {
        stopwatchManager.changePen(to: .dnf)
    }
    
    @objc func setScrambleTo2x2(key: UIKeyCommand?) {
        if SessionType(rawValue: stopwatchManager.currentSession.sessionType) == .playground {
            stopwatchManager.playgroundScrambleType = 0
        }
    }
    
    // iPad keyboard support
    
    var userHoldTime: Double
    
    private var isLongPress = false
    private var keyDownThatStopped: UIKeyboardHIDUsage? = nil
    private var taskTimerReady: DispatchWorkItem?
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        if timerController.mode == .running {
            keyDownThatStopped = key.keyCode
            timerController.touchDown()
        } else if key.keyCode == .keyboardSpacebar {
            timerController.touchDown()
            let newTaskTimerReady = DispatchWorkItem {
                self.timerController.longPressStart()
                self.isLongPress = true
            }
            taskTimerReady = newTaskTimerReady
            DispatchQueue.main.asyncAfter(deadline: .now() + userHoldTime, execute: newTaskTimerReady)
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }
        
        if keyDownThatStopped == key.keyCode {
            keyDownThatStopped = nil
            timerController.touchUp() // In case any key previously stopped
        } else if keyDownThatStopped == nil && key.keyCode == .keyboardSpacebar {
            taskTimerReady?.cancel()
            if isLongPress {
                timerController.longPressEnd()
                isLongPress = false
            } else {
                timerController.touchUp()
            }
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
      
}


struct TimerTouchView: UIViewControllerRepresentable {
    
    @EnvironmentObject var timerController: TimerContoller
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @Preference(\.holdDownTime) private var holdDownTime
    @Preference(\.gestureDistance) private var gestureThreshold
    
    init () {
    }
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TimerTouchView>) -> TimerUIView {
        let v = TimerUIView(timerController: timerController, stopwatchManager: stopwatchManager, userHoldTime: holdDownTime)
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.longPress))
        longPressGesture.allowableMovement = gestureThreshold
        longPressGesture.minimumPressDuration = holdDownTime
        
        //        longPressGesture.requiresExclusiveTouchType = ?
        
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.pan))
        pan.allowedScrollTypesMask = .all
        pan.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirectPointer.rawValue)]
        v.view.addGestureRecognizer(pan)
        
        for direction in [UISwipeGestureRecognizer.Direction.up, UISwipeGestureRecognizer.Direction.down, UISwipeGestureRecognizer.Direction.left, UISwipeGestureRecognizer.Direction.right] {
            let gesture = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.swipe))
            gesture.direction = direction
            gesture.require(toFail: longPressGesture)
                        
            v.view.addGestureRecognizer(gesture)
        }
        
        
        
       
        v.view.addGestureRecognizer(longPressGesture)
        
        
        return v
    }
    
    func updateUIViewController(_ uiView: TimerUIView, context: UIViewControllerRepresentableContext<TimerTouchView>) {
        uiView.userHoldTime = holdDownTime
        /*
        if stopwatchManager.scrambleStr == nil {
            for gesture in uiView.gestureRecognizers! {
                /*
                if gesture is UISwipeGestureRecognizer && (gesture as! UISwipeGestureRecognizer).direction == UISwipeGestureRecognizer.Direction.right {
                    uiView.removeGestureRecognizer(gesture)
                } else */
                if gesture is UILongPressGestureRecognizer {
                    uiView.removeGestureRecognizer(gesture)
                }
            }
        } else {
            let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.longPress))
            longPressGesture.allowableMovement = gestureThreshold
            longPressGesture.minimumPressDuration = userHoldTime
            
            uiView.addGestureRecognizer(longPressGesture)
        }
         */
    }
    
    class Coordinator: NSObject {
        let timerController: TimerContoller
        let sm = SettingsManager.standard
        
        private var panHasTriggeredGesture = false
        
        init(timerController: TimerContoller) {
            self.timerController = timerController
        }
        
        @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                timerController.longPressStart()
            } else if gestureRecognizer.state == .ended {
                timerController.longPressEnd()
            }
        }
        
        @objc func swipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
            #if DEBUG
            NSLog("SWIPED: \(timerController.mode), DIR: \(gestureRecognizer.direction)")
            #endif
            
            timerController.handleGesture(direction: gestureRecognizer.direction)
        }
        
        @objc func pan(_ gestureRecogniser: UIPanGestureRecognizer) {
            #if DEBUG
            NSLog("State: \(gestureRecogniser.state), panHasTriggeredGesture: \(panHasTriggeredGesture)")
            #endif
            if panHasTriggeredGesture {
                if (gestureRecogniser.state == .cancelled || gestureRecogniser.state == .ended) {
                    panHasTriggeredGesture = false
                }
                return
            }
            if gestureRecogniser.state != .cancelled {
                let translation = gestureRecogniser.translation(in: gestureRecogniser.view!.superview)
                let velocity = gestureRecogniser.velocity(in: gestureRecogniser.view!.superview)
                
                let d_x = translation.x
                let d_y = translation.y
                
                
                let v_x = velocity.x
                let v_y = velocity.y
                
                if v_x.magnitude > sm.gestureDistanceTrackpad || v_y.magnitude > sm.gestureDistanceTrackpad {
                    panHasTriggeredGesture = true
                    if d_x.magnitude > d_y.magnitude {
                        if d_x > 0 {
                            timerController.handleGesture(direction: .right)
                        } else if d_x < 0 {
                            timerController.handleGesture(direction: .left)
                        }
                    } else {
                        if d_y > 0 {
                            timerController.handleGesture(direction: .up)
                        } else if d_y < 0 {
                            timerController.handleGesture(direction: .down)
                        }
                    }
                } else {
//                    stopwatchManager.timerColour = Color.Timer.normal
                    gestureRecogniser.state = .cancelled
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(timerController: timerController)
    }
}
