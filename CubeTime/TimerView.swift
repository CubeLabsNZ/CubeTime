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
    @Environment(\.colorScheme) var colourScheme
    //@ObservedObject var currentSession: Sessions
   
    @ObservedObject var stopWatchManager: StopWatchManager
    
    @Binding var hideTabBar: Bool
    
    @State var hideStatusBar = true
    
    
    
    init(stopWatchManager: StopWatchManager, hideTabBar: Binding<Bool>) {
        //_currentSession = currentSession
        self.stopWatchManager = stopWatchManager
        self._hideTabBar = hideTabBar
    }

    var body: some View {
        ZStack {
            
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black) /// ~~todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)~~
                .ignoresSafeArea()
            
            
            
            if stopWatchManager.mode == .stopped {
                VStack {
                    Text(stopWatchManager.scrambleStr ?? "Loading scramble...")
                        //.background(Color.red)
                        
//                        .padding(.top, 48)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight/3)
    //                    .position(x: UIScreen.screenWidth / 2, y: 108)
                        .font(.system(size: stopWatchManager.scrambleType == 7 ? 13 : 18, weight: .semibold, design: .monospaced))
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
                
                Text(stopWatchManager.secondsStr)
                    .foregroundColor(stopWatchManager.timerColour)
                    .modifier(AnimatingFontSize(fontSize: stopWatchManager.mode == .running ? 70 : 56))
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
            
            
            if stopWatchManager.showPenOptions {
                HStack(alignment: .center) {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ZStack {
                            Button {
                                stopWatchManager.solveItem.penalty = PenTypes.plustwo.rawValue
                                stopWatchManager.changedPen()
                                try! managedObjectContext.save()
                            } label: {
                                Text("+2")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .fixedSize()
                            }
                            .frame(width: 35, height: 35)
                            .buttonStyle(.bordered)
                            .foregroundColor(colourScheme == .light ? .black : nil)
                            .tint(colourScheme == .light ? nil : .yellow)
                            .background(colourScheme == .light ? Color(uiColor: .systemGray4) : nil)
                            .controlSize(.regular)
                            .clipShape(Circle())
    //                        .background(Color(uiColor: .systemGray4).clipShape(Circle()))
                        }
                        .padding(5)
                        
                        
                        ZStack {
                            Button {
                                stopWatchManager.solveItem.penalty = PenTypes.dnf.rawValue
                                stopWatchManager.changedPen()
                                try! managedObjectContext.save()
                            } label: {
                                Text("DNF")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .fixedSize()
                            }
                            .frame(width: 50, height: 35)
                            .buttonStyle(.bordered)
                            .foregroundColor(colourScheme == .light ? .black : nil)
                            .tint(colourScheme == .light ? nil : .red)
                            .background(colourScheme == .light ? Color(uiColor: .systemGray4) : nil)
                            .controlSize(.regular)
                            .clipShape(Capsule())
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 2)
                        
                        ZStack {
                            Circle()
                                .fill(Color(uiColor: .systemGray4))
                                .frame(width: 35, height: 35)
                            
                            Button {
                                stopWatchManager.solveItem.penalty = PenTypes.none.rawValue
                                stopWatchManager.changedPen()
                                try! managedObjectContext.save()
                            } label: {
                                Text("OK")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    .fixedSize()
                            }
                            .frame(width: 35, height: 35)
                            .buttonStyle(.bordered)
                            .foregroundColor(colourScheme == .light ? .black : nil)
                            .tint(colourScheme == .light ? nil : .green)
                            .background(colourScheme == .light ? Color(uiColor: .systemGray4) : nil)
                            .controlSize(.regular)
                            .clipShape(Circle())
    //                        .background(Color(uiColor: .systemGray4).clipShape(Circle()))
                        }
                        .padding(5)
                    }
                    .background(Color(uiColor: .systemGray5).clipShape(Capsule()))
                    
                    Spacer()
                }
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                .ignoresSafeArea(edges: .top)
                .offset(y: 52)
                
            }
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
