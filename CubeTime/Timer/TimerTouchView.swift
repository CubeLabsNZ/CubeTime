import Foundation
import SwiftUI
import UIKit


class TimerUIView: UIViewController {
    let stopwatchManager: StopwatchManager

        
    required init(stopwatchManager: StopwatchManager) {
        self.stopwatchManager = stopwatchManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #warning("TODO:  make this a subclass of UIGestureRecognizer instead to use the same coordinator")
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIApplication.shared.isIdleTimerDisabled = true
        #warning("TODO: make this actually work: impelemnt in swm (possibly remove in application delegate")
        stopwatchManager.touchDown()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        stopwatchManager.touchUp()
    }
    
    
    // iPad keyboard support
    
    private let userHoldTime: Double = UserDefaults.standard.double(forKey: gsKeys.freeze.rawValue)
    
    private var isLongPress = false
    private var keyDownThatStopped: UIKeyboardHIDUsage? = nil
    private var taskTimerReady: DispatchWorkItem?
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        if stopwatchManager.mode == .running {
            keyDownThatStopped = key.keyCode
            stopwatchManager.touchDown()
        } else if key.keyCode == .keyboardSpacebar {
            stopwatchManager.touchDown()
            NSLog("Pressed space, touch down")
            let newTaskTimerReady = DispatchWorkItem {
                NSLog("Pressed space for long press start - islongpress = true")
                self.stopwatchManager.longPressStart()
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
            stopwatchManager.touchUp() // In case any key previously stopped
        } else if keyDownThatStopped == nil && key.keyCode == .keyboardSpacebar {
            NSLog("Press ended space")
            taskTimerReady?.cancel()
            if isLongPress {
                NSLog("was long press")
                stopwatchManager.longPressEnd()
                isLongPress = false
            } else {
                NSLog("was short press")
                stopwatchManager.touchUp()
            }
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
      
}

/*
class InspectionUIView: UIView {
    let stopwatchManager: StopWatchManager
    
    required init(frame: CGRect, stopwatchManager: StopWatchManager) {
        self.stopwatchManager = stopwatchManager
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        stopwatchManager.touchDown()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        stopwatchManager.touchUp()
    }
    
}

final class InspectionTouchView: UIViewRepresentable {
    @ObservedObject var stopwatchManager: StopWatchManager
    
    init (stopwatchManager: StopWatchManager) {
        self.stopwatchManager = stopwatchManager
    }
    
    
    func makeUIView(context: UIViewRepresentableContext<InspectionTouchView>) -> TimerUIView {
        let v = TimerUIView(frame: .zero, stopwatchManager: stopwatchManager)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap(_:)))
        
        v.addGestureRecognizer(tapGesture)
        
        return v
    }
    
    func updateUIView(_ uiView: TimerUIView, context: UIViewRepresentableContext<InspectionTouchView>) {
        
    }
    
    class Coordinator: NSObject {
        let stopwatchManager: StopWatchManager
        
        init(stopwatchManager: StopWatchManager) {
            self.stopwatchManager = stopwatchManager
        }
        
        @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                stopwatchManager.startInspection()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(stopwatchManager: stopwatchManager)
    }
}
 */


struct TimerTouchView: UIViewControllerRepresentable {
    
    @ObservedObject var stopwatchManager: StopwatchManager
    
    @AppStorage(gsKeys.freeze.rawValue) private var userHoldTime: Double = 0.5
    @AppStorage(gsKeys.gestureDistance.rawValue) private var gestureThreshold: Double = 50
    
    init (stopwatchManager: StopwatchManager) {
        self.stopwatchManager = stopwatchManager
    }
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TimerTouchView>) -> TimerUIView {
        let v = TimerUIView(stopwatchManager: stopwatchManager)
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.longPress))
        longPressGesture.allowableMovement = gestureThreshold
        longPressGesture.minimumPressDuration = userHoldTime
        
        //        longPressGesture.requiresExclusiveTouchType = ?
        
        
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
        let stopwatchManager: StopwatchManager
        
        init(stopwatchManager: StopwatchManager) {
            self.stopwatchManager = stopwatchManager
        }
        
        @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                stopwatchManager.longPressStart()
            } else if gestureRecognizer.state == .ended {
                stopwatchManager.longPressEnd()
            }
        }
        
        @objc func swipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
            switch gestureRecognizer.direction {
            case .down:
                if stopwatchManager.canGesture && stopwatchManager.mode != .inspecting {
                    stopwatchManager.feedbackStyle?.impactOccurred()
                    stopwatchManager.displayPenOptions()
                } else {
                    stopwatchManager.timerColour = Color.Timer.normal
                }
                
            case .left:
                if stopwatchManager.canGesture && stopwatchManager.mode != .inspecting {
                    stopwatchManager.feedbackStyle?.impactOccurred()
                    stopwatchManager.askToDelete()
                } else {
                    stopwatchManager.timerColour = Color.Timer.normal
                }
            case .right:
                stopwatchManager.feedbackStyle?.impactOccurred()
                stopwatchManager.timerColour = Color.Timer.normal
                stopwatchManager.prevDownStoppedTimer = false
                stopwatchManager.rescramble()
            default:
                stopwatchManager.timerColour = Color.Timer.normal
            }
        }
        
        /*
        @objc func pan(_ gestureRecogniser: UIPanGestureRecognizer) {
            if gestureRecogniser.state != .cancelled {
                let translation = gestureRecogniser.translation(in: gestureRecogniser.view!.superview)
                let velocity = gestureRecogniser.velocity(in: gestureRecogniser.view!.superview)
                
                let d_x = translation.x
                let d_y = translation.y
                
                
                let v_x = velocity.x
                let v_y = velocity.y
                
                
                NSLog("\(translation.x)")
//                NSLog("\(translation.y)")
//                NSLog("\(velocity.x)")
//                NSLog("\(velocity.y)")
                
                
                if v_x.magnitude > 500 || v_y.magnitude > 500 {
                    if d_x.magnitude > d_y.magnitude {
                        if d_x > 0 {
                            stopwatchManager.feedbackStyle?.impactOccurred()
                            stopwatchManager.timerColour = Color.Timer.normal
                            stopwatchManager.prevDownStoppedTimer = false
                            stopwatchManager.rescramble()
                            
                            gestureRecogniser.state = .cancelled
                        } else if d_x < 0 {
                            if stopwatchManager.canGesture && stopwatchManager.mode != .inspecting {
                                stopwatchManager.feedbackStyle?.impactOccurred()
                                stopwatchManager.askToDelete()
                            } else {
                                stopwatchManager.timerColour = Color.Timer.normal
                            }
                            
                            gestureRecogniser.state = .cancelled
                        }
                    } else {
                        // swipe down
                        if d_y > 0 {
                            if stopwatchManager.canGesture && stopwatchManager.mode != .inspecting {
                                stopwatchManager.feedbackStyle?.impactOccurred()
                                stopwatchManager.displayPenOptions()
                            } else {
                                stopwatchManager.timerColour = Color.Timer.normal
                            }
                            
                            gestureRecogniser.state = .cancelled
                        } else if d_y < 0 {
                            // cancel any up movement
                            gestureRecogniser.state = .cancelled
                        }
                    }
                } else {
                    stopwatchManager.timerColour = Color.Timer.normal
//                    gestureRecogniser.state = .cancelled
                }
            }
        }
         */
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(stopwatchManager: stopwatchManager)
    }
}
