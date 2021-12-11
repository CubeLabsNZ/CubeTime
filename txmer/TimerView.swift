//
//  ContentView.swift
//  timer
//
//  Created by Tim Xie on 21/11/21.
//

import CoreData
import SwiftUI
import CoreGraphics

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

struct AnimatingFontSize: AnimatableModifier {
    var fontSize: CGFloat

    var animatableData: CGFloat {
        get { fontSize }
        set { fontSize = newValue }
    }

    func body(content: Self.Content) -> some View {
        content
            .font(.system(size: self.fontSize, weight: .bold, design: .monospaced))
    }
}




@available(iOS 15.0, *)
struct TimerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    //@ObservedObject var currentSession: Sessions
    
    @ObservedObject var stopWatchManager: StopWatchManager
    
    @Binding var hideTabBar: Bool
    
    @State var hideStatusBar = true
    
    
    
    @Environment(\.colorScheme) var colourScheme
    
    
    init(stopWatchManager: StopWatchManager, hideTabBar: Binding<Bool>) {
        //_currentSession = currentSession
        self.stopWatchManager = stopWatchManager
        self._hideTabBar = hideTabBar
    }

    var body: some View {
        ZStack {
            
            
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black) /// ~~todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)~~
                .ignoresSafeArea()
            
            
            
            if stopWatchManager.mode == .stopped{
                VStack {
                    Text(stopWatchManager.scrambleStr ?? "Loading scramble")
                        //.background(Color.red)
                        
//                        .padding(.top, 48)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight/3)
    //                    .position(x: UIScreen.screenWidth / 2, y: 108)
                        .font(.system(size: stopWatchManager.scrambleType == 7 ? 13 : 17, weight: .semibold, design: .monospaced))
//                        .font(.system(size: 17, weight: .semibold, design: .monospaced))
                        .allowsTightening(true)

//                        .background(Color.red)
                    
                    
                        .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
                    /// TODO: **FIX MEGA SCRAMBLES GOES OFF SCREEN AND MAKE [U, D] GO ON LAST**
                    
                    
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
            }
            
            VStack {
                Spacer()
                
                Text(formatSolveTime(secs: stopWatchManager.secondsElapsed))
                    .foregroundColor(stopWatchManager.timerColour)
                    .modifier(AnimatingFontSize(fontSize: stopWatchManager.mode == .running ? 64 : 48))
                    .animation(Animation.spring(), value: stopWatchManager.mode == .running)
            
            
                
                Spacer()
            }
                    .ignoresSafeArea(edges: .all)
            
                       
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
                        /*
                        .modifier(Touch(changeState: { (buttonState) in
                            
                            
                            if buttonState == .pressed { /// ON TOUCH DOWN EVENT
                                self.stopWatchManager.touchDown()
                            } else { /// ON TOUCH UP (FINGER RELEASE) EVENT
                                self.stopWatchManager.touchUp()
                            }
                        }))
                        //.safeAreaInset(edge: .bottom)
                         //.aspectRatio(contentMode: ContentMode.fit)
                         */
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged({value in
                                    stopWatchManager.touchDown(value: value)
                                })
                                .onEnded({ value in
                                    stopWatchManager.touchUp(value: value)
                                })
                        )
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .confirmationDialog("Are you sure you want to delete this solve?", isPresented: $stopWatchManager.showDeleteSolveConfirmation, titleVisibility: .visible, presenting: $stopWatchManager.solveItem) { detail in
            Button("Confirm", role: .destructive) {
                NSLog("deleting \(detail)")
                managedObjectContext.delete(detail.wrappedValue!)
                detail.wrappedValue = nil
                stopWatchManager.secondsElapsed = 0
                try! managedObjectContext.save()
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
        .onReceive(stopWatchManager.$mode) { newMode in
            hideTabBar = (newMode == .running)
            
            
            withAnimation(.easeIn(duration: 0.1)) {
                hideStatusBar = (newMode == .running)
                
            }
        }
        .statusBar(hidden: hideStatusBar) /// TODO MAKE SO ANIMATION IS ASYMMETRIC WITH VALUES OF THE OTHER ANIMATIONS
    }
}

/*
struct MainTimerView_Previews: PreviewProvider {
    static var previews: some View {
        MainTimerView()
    }
}

*/
