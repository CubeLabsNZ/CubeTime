import Foundation
import SwiftUI
import UIKit


class TimerUIView: UIView {    
    let stopWatchManager: StopWatchManager

        
    required init(frame: CGRect, stopWatchManager: StopWatchManager) {
        self.stopWatchManager = stopWatchManager
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO make this a subclass of UIGestureRecognizer instead to use the same coordinator
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        stopWatchManager.touchDown()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        stopWatchManager.touchUp()
    }
}

// Must be final class - see
// https://github.com/mediweb/UIViewRepresentableBug
final class TimerTouchView: UIViewRepresentable {
    
    @ObservedObject var stopWatchManager: StopWatchManager
    
    @AppStorage(gsKeys.freeze.rawValue) var userHoldTime: Double = 0.5
    @AppStorage(gsKeys.gestureDistance.rawValue) var geatureThreshold: Double = 50
    
    init (stopWatchManager: StopWatchManager) {
        self.stopWatchManager = stopWatchManager
    }
    
    
    func makeUIView(context: UIViewRepresentableContext<TimerTouchView>) -> TimerUIView {
        let v = TimerUIView(frame: .zero, stopWatchManager: stopWatchManager)
        
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.longPress))
        longPressGesture.allowableMovement = geatureThreshold
        longPressGesture.minimumPressDuration = userHoldTime
//        longPressGesture.requiresExclusiveTouchType = ?

        v.addGestureRecognizer(longPressGesture)
        
        return v
    }
    
    func updateUIView(_ uiView: TimerUIView, context: UIViewRepresentableContext<TimerTouchView>) {
        
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
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(stopWatchManager: stopWatchManager)
    }
}
