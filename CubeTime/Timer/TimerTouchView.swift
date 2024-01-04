import Foundation
import SwiftUI
import UIKit


class TimerUIView: UIViewController {
    let timerController: TimerController
    let stopwatchManager: StopwatchManager

        
    required init(timerController: TimerController, stopwatchManager: StopwatchManager, userHoldTime: Double) {
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
            
            var commands = [
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve), input: "\u{08}", discoverabilityTitle: "Delete Solve", attributes: .destructive),
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve), input: UIKeyCommand.inputDelete, discoverabilityTitle: "Delete Solve", attributes: .destructive),
                // ANSI delete (above doesnt register in simulator? not sure
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve), input: "\u{7F}", attributes: .destructive),
                UIKeyCommand(title: "Delete Solve", action: #selector(deleteSolve), input: "z", modifierFlags: [.command], discoverabilityTitle: "Delete Solve", attributes: .destructive),
                
                UIKeyCommand(title: "New Scramble", action: #selector(newScr), input: "+", discoverabilityTitle: "New Scramble"),
                UIKeyCommand(title: "New Scramble", action: #selector(newScr), input: "n", modifierFlags: [.command], discoverabilityTitle: "New Scramble"),
                UIKeyCommand(title: "New Scramble", action: #selector(newScr), input: UIKeyCommand.inputRightArrow, modifierFlags: [.command], discoverabilityTitle: "New Scramble"),
                
                UIKeyCommand(title: "Penalty: None", action: #selector(penNone), input: "1", modifierFlags: [.command], discoverabilityTitle: "Remove penalty", state: curPen == Penalty.none ? .on : .off),
                UIKeyCommand(title: "Penalty: +2", action: #selector(penPlus2), input: "2", modifierFlags: [.command], discoverabilityTitle: "Set penalty to +2", state: curPen == Penalty.plustwo ? .on : .off),
                UIKeyCommand(title: "Penalty: DNF", action: #selector(penDNF), input: "3", modifierFlags: [.command], discoverabilityTitle: "Set penalty to DNF", state: curPen == Penalty.dnf ? .on : .off),
            ]
            
            if (SessionType(rawValue: stopwatchManager.currentSession.sessionType) == .playground) {
                commands += [
                    UIKeyCommand(title: "Scramble: 2x2", action: #selector(setScrambleTo2x2), input: "2", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 2x2"),
                    UIKeyCommand(title: "Scramble: 3x3", action: #selector(setScrambleTo3x3), input: "3", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 3x3"),
                    UIKeyCommand(title: "Scramble: 4x4", action: #selector(setScrambleTo4x4), input: "4", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 4x4"),
                    UIKeyCommand(title: "Scramble: 5x5", action: #selector(setScrambleTo5x5), input: "5", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 5x5"),
                    UIKeyCommand(title: "Scramble: 6x6", action: #selector(setScrambleTo6x6), input: "6", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 6x6"),
                    UIKeyCommand(title: "Scramble: 7x7", action: #selector(setScrambleTo7x7), input: "7", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 7x7"),
                    UIKeyCommand(title: "Scramble: Square-1", action: #selector(setScrambleToSquare1), input: "1", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to Square-1"),
                    UIKeyCommand(title: "Scramble: Megaminx", action: #selector(setScrambleToMegaminx), input: "M", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to Megaminx"),
                    UIKeyCommand(title: "Scramble: Pyraminx", action: #selector(setScrambleToPyraminx), input: "P", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to Pyraminx"),
                    UIKeyCommand(title: "Scramble: Clock", action: #selector(setScrambleToClock), input: "C", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to Clock"),
                    UIKeyCommand(title: "Scramble: Skewb", action: #selector(setScrambleToSkewb), input: "S", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to Skewb"),
                    UIKeyCommand(title: "Scramble: 3x3 OH", action: #selector(setScrambleToOH), input: "O", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 3x3 OH"),
                    UIKeyCommand(title: "Scramble: 3x3 BLD", action: #selector(setScrambleTo3BLD), input: "B", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 3x3 BLD"),
                    UIKeyCommand(title: "Scramble: 4x4 BLD", action: #selector(setScrambleTo4BLD), input: "8", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 4x4 BLD"),
                    UIKeyCommand(title: "Scramble: 5x5 BLD", action: #selector(setScrambleTo5BLD), input: "9", modifierFlags: [.alternate], discoverabilityTitle: "Set scramble to 5x5 BLD")
                ]
            }
            
            return commands
        }
    }
    
    @objc func deleteSolve() {
        stopwatchManager.deleteLastSolve()
    }
    
    @objc func newScr() {
        stopwatchManager.scrambleController.rescramble()
    }
    
    @objc func penNone() {
        stopwatchManager.changePen(to: .none)
    }
    
    @objc func penPlus2() {
        stopwatchManager.changePen(to: .plustwo)
    }
    
    @objc func penDNF() {
        stopwatchManager.changePen(to: .dnf)
    }
    
    @objc func setScrambleTo2x2() { stopwatchManager.playgroundScrambleType = 0 }
    @objc func setScrambleTo3x3() { stopwatchManager.playgroundScrambleType = 1 }
    @objc func setScrambleTo4x4() { stopwatchManager.playgroundScrambleType = 2 }
    @objc func setScrambleTo5x5() { stopwatchManager.playgroundScrambleType = 3 }
    @objc func setScrambleTo6x6() { stopwatchManager.playgroundScrambleType = 4 }
    @objc func setScrambleTo7x7() { stopwatchManager.playgroundScrambleType = 5 }
    @objc func setScrambleToSquare1() { stopwatchManager.playgroundScrambleType = 6 }
    @objc func setScrambleToMegaminx() { stopwatchManager.playgroundScrambleType = 7 }
    @objc func setScrambleToPyraminx() { stopwatchManager.playgroundScrambleType = 8 }
    @objc func setScrambleToClock() { stopwatchManager.playgroundScrambleType = 9 }
    @objc func setScrambleToSkewb() { stopwatchManager.playgroundScrambleType = 10 }
    @objc func setScrambleToOH() { stopwatchManager.playgroundScrambleType = 11 }
    @objc func setScrambleTo3BLD() { stopwatchManager.playgroundScrambleType = 12 }
    @objc func setScrambleTo4BLD() { stopwatchManager.playgroundScrambleType = 13 }
    @objc func setScrambleTo5BLD() { stopwatchManager.playgroundScrambleType = 14 }
    
    
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
    
    @EnvironmentObject var timerController: TimerController
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
        let timerController: TimerController
        let sm = SettingsManager.standard
        
        private var panHasTriggeredGesture = false
        
        init(timerController: TimerController) {
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
                        if d_y < 0 {
                            timerController.handleGesture(direction: .up)
                        } else if d_y > 0 {
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
