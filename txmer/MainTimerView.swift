//
//  ContentView.swift
//  timer
//
//  Created by Tim Xie on 21/11/21.
//

import CoreData
import SwiftUI
import CoreGraphics

import UIKit



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



extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}





struct MainTimerView: View {
    @ObservedObject var stopWatchManager = StopWatchManager()

    @State var timerColour = Color.black

    @State var buttonPressed = false
    @State var justPressed = false
    @State var minimumTapDurationMet = false
    
    @State var doNotStart = false
    
    @State var tapId = 0
    @State var currentTapId = 0
    
    //let bgColourGrey = Color(red: 242 / 255, green: 241 / 255, blue: 246 / 255)
    let bgNoFill = Color.black.opacity(0.00001)
    let tabBarHeight = 50
    let marginLeftRight = 16
    
    
    //let safeAreaBottomHeight = 34
    
    
    
    var body: some View {
        
        
        ZStack {
            Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                .ignoresSafeArea()
            
            
            
            VStack {
                Text(String("(0,2)/ (0,-3)/ (3,0)/ (-5,-5)/ (6,-3)/ (-1,-4)/ (1,0)/ (-3,0)/ (-1,0)/ (0,-2)/ (2,-3)/ (-4,0)/ (1,0)"))
                    //.background(Color.red)
                    .padding(22)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .position(x: UIScreen.screenWidth / 2, y: 108)
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                
                               
            }
            
            
            Text(String(format: "%.3f", stopWatchManager.secondsElapsed))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(timerColour)
            
            tabBar
            
            GeometryReader { geometry in
                VStack {
                    Rectangle()
                        .fill(Color.red.opacity(0.01))
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height - CGFloat(tabBarHeight) /* - CGFloat(safeAreaBottomHeight) */,
                            alignment: .center
                            //height: geometry.safeAreaInsets.top,
                            //height:  - safeAreaInset(edge: .bottom) - CGFloat(tabBarHeight),
                        )
                        .modifier(Touch(changeState: { (buttonState) in
                            let taskAfterHold = DispatchWorkItem {
                                NSLog("buttonPressed state on hold duration start" + String(buttonPressed))
                                if self.buttonPressed {
                                    minimumTapDurationMet = true
                                    timerColour = timerColourHeldCanStart
                                    NSLog("minimumTapDurationMet = " + String(minimumTapDurationMet))
                                }
                            }
                                if buttonState == .pressed { /// ON TOUCH DOWN EVENT
                                    buttonPressed = true /// BUG: if users press fast enough, the timer will be activated (maybe fix by detecting second True before False??@?!?!)
                                    NSLog("buttonPressed state on first touchdown" + String(buttonPressed))
                                    timerColour = timerColourHeld
                                    if self.stopWatchManager.mode == .running {
                                        self.stopWatchManager.stop()
                                    } else {
                                        NSLog("buttonPressed state before hold duration start" + String(buttonPressed))
                                        DispatchQueue.main.asyncAfter(deadline: .now() + userTapDuration, execute: taskAfterHold)
                                        NSLog("async started")
                                    }
                                } else { /// ON TOUCH UP (FINGER RELEASE) EVENT
                                    buttonPressed = false
                                    
                                    taskAfterHold.cancel()
                                    NSLog("task cancelled")
                                    
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
                        //.safeAreaInset(edge: .bottom)
                        //.aspectRatio(contentMode: ContentMode.fit)
                }
            }
        }
    }
    
    var tabBar: some View {
        GeometryReader { geometry in
            VStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red)
                
                    .frame(
                        width: geometry.size.width - CGFloat(marginLeftRight * 2),
                        height: CGFloat(tabBarHeight),
                        alignment: .center
                        //height: geometry.safeAreaInsets.top,
                        //height:  - safeAreaInset(edge: .bottom) - CGFloat(tabBarHeight),
                    )
                
                    .position(
                        x: geometry.size.width / 2 - CGFloat(marginLeftRight),
                        y: geometry.size.height - 0.5 * CGFloat(tabBarHeight)
                    )
                
                    /*
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 50)
                     */
                    .padding(.leading, CGFloat(marginLeftRight))
                    .padding(.trailing, CGFloat(marginLeftRight))
            }
        }
        .frame(alignment: .bottom)
    }
    
    
}

/*
struct MainTimerView_Previews: PreviewProvider {
    static var previews: some View {
        MainTimerView()
    }
}
*/
