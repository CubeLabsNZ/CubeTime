//
//  ContentView.swift
//  timer
//
//  Created by Tim Xie on 21/11/21.
//

import SwiftUI



var userTapDuration: Double = 0.5 /// todo make so user can set in settings

let timerDefault = Color.black
let timerColourHeld = Color.red
let timerColourHeldCanStart = Color.green

var timerColour: Color = timerDefault


enum stopWatchMode {
    case running
    case stopped
}

class StopWatchManager: ObservableObject {
    
    @Published var mode: stopWatchMode = .stopped
    
    @Published var secondsElapsed = 0.0
    
    var timer = Timer()
    
    var frameTime: Double = 1/60 /// todo dynamic make epic 120hz support
    
    func start() {
        mode = .running
        
        secondsElapsed = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: frameTime, repeats: true) { [self] timer in
            self.secondsElapsed += self.frameTime
        }
    }
    
    func stop() {
            timer.invalidate()
            mode = .stopped
        }

    



}

public enum ButtonState {
    case pressed
    case notPressed
}

public struct Touch: ViewModifier {
    @GestureState private var isPressed = false
    let changeState: (ButtonState) -> Void
    public func body(content: Content) -> some View {
        let drag = DragGesture(minimumDistance: 0)
            .updating($isPressed) { (value, gestureState, transaction) in
                gestureState = true
            }
        
        return content
            .gesture(drag)
            .onChange(of: isPressed, perform: { (pressed) in
                        if pressed {
                            self.changeState(.pressed)
                        } else {
                            self.changeState(.notPressed)
                        }
                    })
    }
}

struct ContentView: View {
    @ObservedObject var stopWatchManager = StopWatchManager()

    @State var timerColour = Color.black

    @State var buttonPressed = false
    @State var justPressed = false
    @State var minimumTapDurationMet = false
    
    @State var doNotStart = false
    
    @State var tapId = 0
    @State var currentTapId = 0
    
    
    var body: some View {
        Text(String(format: "%.3f", stopWatchManager.secondsElapsed))
            .padding()
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .foregroundColor(timerColour)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(Color.white) /// todo make so user can change colour/changes dynamically with system theme
            .modifier(Touch(changeState: { (buttonState) in
                    if buttonState == .pressed { /// ON TOUCH DOWN EVENT
                        buttonPressed = true /// BUG: if users press fast enough, the timer will be activated (maybe fix by detecting second True before False??@?!?!)
                        NSLog("buttonPressed state on first touchdown" + String(buttonPressed))
                        
                        timerColour = timerColourHeld
                        
                        
                        
                        if self.stopWatchManager.mode == .running {
                            self.stopWatchManager.stop()
                        } else {
                            
                            NSLog("buttonPressed state before hold duration start" + String(buttonPressed))
                            DispatchQueue.main.asyncAfter(deadline: .now() + userTapDuration) {
                                NSLog("buttonPressed state on hold duration start" + String(buttonPressed))
                                
                                
                                //NSLog("current tap id =" + String(currentTapId))
                                //NSLog("tap id =" + String(tapId))
                                if self.buttonPressed {
                                    minimumTapDurationMet = true
                                    timerColour = timerColourHeldCanStart
                                    NSLog("minimumTapDurationMet = " + String(minimumTapDurationMet))

                                }
                                                                    
                            }
                            
                            
                            //tapId += 1
                        }
                        
                       
                    } else { /// ON TOUCH UP (FINGER RELEASE) EVENT
                        buttonPressed = false
                        
                        NSLog("\n\n" + String(buttonPressed))
                        if !self.justPressed {
                            if self.minimumTapDurationMet {
                                timerColour = timerDefault
                                if self.stopWatchManager.mode == .stopped {
                                    self.stopWatchManager.start()
                                    self.justPressed = true
                                }
                                self.minimumTapDurationMet = false
                                
                            } else {
                                timerColour = timerDefault
                            }
                        } else {
                            self.justPressed = false
                            timerColour = timerDefault
                        }
                    }
                }))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
