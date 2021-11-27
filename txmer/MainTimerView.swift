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



var userHoldTime: Double = 0.5 /// todo make so user can set in setting

enum stopWatchMode {
    case running
    case stopped
}


class StopWatchManager: ObservableObject {
    @Published var mode: stopWatchMode = .stopped
    
    var managedObjectContext: NSManagedObjectContext
    
    init (managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    @Published var secondsElapsed = 0.0
    
    @Environment(\.colorScheme) var colourScheme
    
    var timer = Timer()
    
    /// todo set custom fps for battery purpose, promotion can set as low as 10 / 24hz ,others 60 fixed, no option for them >:C
    var frameTime: Double = 1/60
    
    func start() {
        mode = .running
        
        secondsElapsed = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [self] timer in
            self.secondsElapsed += 0.001
        }
    }
    
    func stop() {
        timer.invalidate()
        mode = .stopped

    }
    
    @Published var timerColour: Color = TimerTextColours.timerDefaultColour
    
    private var canStartTimer = false
    
    private var taskAfterHold: DispatchWorkItem?
    
    private let feedbackStyle = UIImpactFeedbackGenerator(style: .medium) /// TODO: add option to change heaviness/turn on off in settings
    
    func touchDown() {
        if mode == .running {
            stop()
            let controller = PersistenceController.shared
            let viewContext = controller.container.viewContext
            let solveItem = Solves(context: viewContext)
            // .comment
            solveItem.date = Date()
            // .penalty
            // .puzzle_id
            solveItem.session = Sessions(context: viewContext) // TODO
            // .scramble
            // .scramble_type
            // .starred
            solveItem.time = self.secondsElapsed
            do {
                try viewContext.save()
            } catch {
                if let error = error as NSError? {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                    /*
                    Typical reasons for an error here include:
                    * The parent directory does not exist, cannot be created, or disallows writing.
                    * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                    * The device is out of space.
                    * The store could not be migrated to the current model version.
                    Check the error message to determine what the actual problem was.
                    */
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        } else {
            let newTaskAfterHold = DispatchWorkItem {
                self.canStartTimer = true
                self.timerColour = TimerTextColours.timerCanStartColour
                self.feedbackStyle.impactOccurred()
            }
            taskAfterHold = newTaskAfterHold
            DispatchQueue.main.asyncAfter(deadline: .now() + userHoldTime, execute: newTaskAfterHold)
            
        }
        timerColour = TimerTextColours.timerHeldDownColour
    }
    
    func touchUp() {
        if canStartTimer {
            NSLog("minimumTapDurationMet, starting timer.")
            start()
            canStartTimer = false
        }
        taskAfterHold?.cancel()
        
        timerColour = ((colourScheme == .light) ? Color.black : Color.white)
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


struct SubTimerView: View {
    
    @ObservedObject var stopWatchManager: StopWatchManager
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        ZStack {
            
            
            Color(colourScheme == .light ? UIColor.systemGray6 : UIColor.black) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                .ignoresSafeArea()
            
            
            
            VStack {
                Text("(0,2)/ (0,-3)/ (3,0)/ (-5,-5)/ (6,-3)/ (-1,-4)/ (1,0)/ (-3,0)/ (-1,0)/ (0,-2)/ (2,-3)/ (-4,0)/ (1,0)")
                    //.background(Color.red)
                    .padding(22)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .position(x: UIScreen.screenWidth / 2, y: 108)
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                
                               
            }
            
            
            Text(String(format: "%.3f", stopWatchManager.secondsElapsed))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(stopWatchManager.timerColour)
                       
            GeometryReader { geometry in
                VStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.0000000001)) /// TODO: fix this don't just use this workaround: https://stackoverflow.com/questions/56819847/tap-action-not-working-when-color-is-clear-swiftui
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height - CGFloat(SetValues.tabBarHeight) /* - CGFloat(safeAreaBottomHeight) */,
                            alignment: .center
                            //height: geometry.safeAreaInsets.top,
                            //height:  - safeAreaInset(edge: .bottom) - CGFloat(tabBarHeight),
                        )
                        .modifier(Touch(changeState: { (buttonState) in
                            
                            
                            if buttonState == .pressed { /// ON TOUCH DOWN EVENT
                                self.stopWatchManager.touchDown()
                            } else { /// ON TOUCH UP (FINGER RELEASE) EVENT
                                self.stopWatchManager.touchUp()
                            }
                        }))
                        //.safeAreaInset(edge: .bottom)
                        //.aspectRatio(contentMode: ContentMode.fit)
                }
            }
        }
    }
}

struct MainTimerView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    

    
    //let bgColourGrey = Color(red: 242 / 255, green: 241 / 255, blue: 246 / 255)
    
    
    //let safeAreaBottomHeight = 34
    
    var body: some View {
        /// Please see https://developer.apple.com/forums/thread/658313
        /// For why this is done this way
        SubTimerView(stopWatchManager: StopWatchManager(managedObjectContext: managedObjectContext))
    }
    
}


struct MainTimerView_Previews: PreviewProvider {
    static var previews: some View {
        MainTimerView()
    }
}

