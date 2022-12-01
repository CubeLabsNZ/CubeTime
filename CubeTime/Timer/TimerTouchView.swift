import Foundation
import SwiftUI
import UIKit


class TimerUIView: UIViewController {
    let stopWatchManager: StopWatchManager

        
    required init(stopWatchManager: StopWatchManager) {
        self.stopWatchManager = stopWatchManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #warning("TODO:  make this a subclass of UIGestureRecognizer instead to use the same coordinator")
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIApplication.shared.isIdleTimerDisabled = true
        stopWatchManager.touchDown()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        stopWatchManager.touchUp()
    }
    
    
    // iPad keyboard support
    
    private let userHoldTime: Double = UserDefaults.standard.double(forKey: gsKeys.freeze.rawValue)
    
    private var isLongPress = false
    private var taskTimerReady: DispatchWorkItem?
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let key = presses.first?.key else { return }

        if key.keyCode == .keyboardSpacebar {
            stopWatchManager.touchDown()
            NSLog("Pressed space, touch down")
            let newTaskTimerReady = DispatchWorkItem {
                NSLog("Pressed space for long press start - islongpress = true")
                self.stopWatchManager.longPressStart()
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
        
        if key.keyCode == .keyboardSpacebar {
            NSLog("Press ended space")
            taskTimerReady?.cancel()
            if isLongPress {
                NSLog("was long press")
                stopWatchManager.longPressEnd()
                isLongPress = false
            } else {
                NSLog("was short press")
                stopWatchManager.touchUp()
            }
        } else {
            super.pressesBegan(presses, with: event)
        }
    }
      
}

/*
class InspectionUIView: UIView {
    let stopWatchManager: StopWatchManager
    
    required init(frame: CGRect, stopWatchManager: StopWatchManager) {
        self.stopWatchManager = stopWatchManager
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        stopWatchManager.touchDown()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        stopWatchManager.touchUp()
    }
    
}

final class InspectionTouchView: UIViewRepresentable {
    @ObservedObject var stopWatchManager: StopWatchManager
    
    init (stopWatchManager: StopWatchManager) {
        self.stopWatchManager = stopWatchManager
    }
    
    
    func makeUIView(context: UIViewRepresentableContext<InspectionTouchView>) -> TimerUIView {
        let v = TimerUIView(frame: .zero, stopWatchManager: stopWatchManager)
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap(_:)))
        
        v.addGestureRecognizer(tapGesture)
        
        return v
    }
    
    func updateUIView(_ uiView: TimerUIView, context: UIViewRepresentableContext<InspectionTouchView>) {
        
    }
    
    class Coordinator: NSObject {
        let stopWatchManager: StopWatchManager
        
        init(stopWatchManager: StopWatchManager) {
            self.stopWatchManager = stopWatchManager
        }
        
        @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
            if gestureRecognizer.state == .ended {
                stopWatchManager.startInspection()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(stopWatchManager: stopWatchManager)
    }
}
 */



struct TimerTouchView: UIViewControllerRepresentable {
    
    @ObservedObject var stopWatchManager: StopWatchManager
    
    @AppStorage(gsKeys.freeze.rawValue) private var userHoldTime: Double = 0.5
    @AppStorage(gsKeys.gestureDistance.rawValue) private var gestureThreshold: Double = 50
    
    init (stopWatchManager: StopWatchManager) {
        self.stopWatchManager = stopWatchManager
    }
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TimerTouchView>) -> TimerUIView {
        let v = TimerUIView(stopWatchManager: stopWatchManager)
        
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
        if stopWatchManager.scrambleStr == nil {
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
        let stopWatchManager: StopWatchManager
        
        init(stopWatchManager: StopWatchManager) {
            self.stopWatchManager = stopWatchManager
        }
        
        @objc func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            if gestureRecognizer.state == .began {
                stopWatchManager.longPressStart()
            } else if gestureRecognizer.state == .ended {
                stopWatchManager.longPressEnd()
            }
        }
        
        @objc func swipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
            switch gestureRecognizer.direction {
            case .down:
                if stopWatchManager.canGesture && stopWatchManager.mode != .inspecting {
                    stopWatchManager.feedbackStyle?.impactOccurred()
                    stopWatchManager.displayPenOptions()
                } else {
                    stopWatchManager.timerColour = TimerTextColours.timerDefaultColour
                }
                
            case .left:
                if stopWatchManager.canGesture && stopWatchManager.mode != .inspecting {
                    stopWatchManager.feedbackStyle?.impactOccurred()
                    stopWatchManager.askToDelete()
                } else {
                    stopWatchManager.timerColour = TimerTextColours.timerDefaultColour
                }
            case .right:
                stopWatchManager.feedbackStyle?.impactOccurred()
                stopWatchManager.timerColour = TimerTextColours.timerDefaultColour
                stopWatchManager.prevDownStoppedTimer = false
                stopWatchManager.rescramble()
            default:
                stopWatchManager.timerColour = TimerTextColours.timerDefaultColour
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(stopWatchManager: stopWatchManager)
    }
}
