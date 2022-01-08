import CoreData
import SwiftUI
import CoreGraphics



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



struct TimerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    //@ObservedObject var currentSession: Sessions
   
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @AppStorage("onboarding") private var showOnboarding: Bool = true
    
    @ObservedObject var stopWatchManager: StopWatchManager
    
    @Binding var hideTabBar: Bool
    
    @Binding var currentSession: Sessions
    
    @Binding var pageIndex: Int
    
    @State var hideStatusBar = true
    
    @State var algTrainerSubset = 0
    @State var playgroundScrambleType: Int
    
//    @State var compSimTarget: String
    
    
    init(pageIndex: Binding<Int>, currentSession: Binding<Sessions>, stopWatchManager: StopWatchManager, hideTabBar: Binding<Bool>) {
        self._pageIndex = pageIndex
        self._currentSession = currentSession
        self.stopWatchManager = stopWatchManager
        self._hideTabBar = hideTabBar
        self._playgroundScrambleType = State(initialValue: Int(currentSession.wrappedValue.scramble_type))
    }

    
    var body: some View {
        ZStack {
            
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
    
    
            if stopWatchManager.mode == .inspecting {
                
                if colourScheme == .light {
                    switch stopWatchManager.inspectionSecs {
                    case 8..<12:
                        InspectionColours.eightColour
                            .ignoresSafeArea()
                    case 12..<15:
                        InspectionColours.twelveColour
                            .ignoresSafeArea()
                    case let x where x > 15: InspectionColours.penaltyColour
                            .ignoresSafeArea()
                    default:
                        EmptyView()
                    }
                }
                
                if stopWatchManager.inspectionSecs >= 17 {
                    Text("DNF")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(colourScheme == .light ? .black : nil)
                    .offset(y: 45)
                } else if stopWatchManager.inspectionSecs >= 15 {
                    Text("+2")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(colourScheme == .light ? .black : nil)
                    .offset(y: 45)
                }
            } else if  stopWatchManager.mode == .stopped {
                
                VStack {
                    Text(stopWatchManager.scrambleStr ?? "Loading scramble...")
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: UIScreen.screenHeight/3)
                        .font(.system(size: currentSession.scramble_type == 7 ? 12 : 18, weight: .semibold, design: .monospaced))
                    
                        .minimumScaleFactor(0.4)
                    
                        .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
                    
                        
                    
//                        .padding(.horizontal)
                    
                        
                
                        
                    /// TODO: **FIX MEGA SCRAMBLES GOES OFF SCREEN AND MAKE [U, D] GO ON LAST**
                    
                    Spacer()
                }
                .padding(.horizontal)
                .offset(y: 35 + (SetValues.hasBottomBar ? 0 : 8))
            }
            
            VStack {
                Spacer()
                
                Text(stopWatchManager.secondsStr)
                    .foregroundColor(
                        {
                            if stopWatchManager.mode == .inspecting && colourScheme == .dark && stopWatchManager.timerColour == TimerTextColours.timerDefaultColour {
                                switch stopWatchManager.inspectionSecs {
                                case ..<8: return TimerTextColours.timerDefaultColour
                                case 8..<12: return Color(uiColor: .systemYellow)
                                case 12..<15: return Color(uiColor: .systemOrange)
                                default: return Color(uiColor: .systemRed)
                                }
                            } else {
                                return stopWatchManager.timerColour
                            }
                        }()
                    )
                    .modifier(AnimatingFontSize(fontSize: stopWatchManager.mode == .running ? 70 : 56))
                    .modifier(DynamicText())
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
                            height: geometry.size.height - CGFloat(SetValues.tabBarHeight),
                            alignment: .center
                        )
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
            
            VStack {
                HStack {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(uiColor: .systemGray4))
                                .frame(width: 35, height: 35)
                                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                            switch SessionTypes(rawValue: currentSession.session_type)! {
                            case .standard:
                                Image(systemName: "timer.square")
                                    .font(.system(size: 26, weight: .regular))
                            case .algtrainer:
                                Image(systemName: "command.square")
                                    .font(.system(size: 26, weight: .regular))
                            case .multiphase:
                                Image(systemName: "square.stack")
                                    .font(.system(size: 22, weight: .regular))
                            case .playground:
                                Image(systemName: "square.on.square")
                                    .font(.system(size: 22, weight: .regular))
                            case .compsim:
                                Image(systemName: "globe.asia.australia")
                                    .font(.system(size: 22, weight: .medium))
                            }
                            
                        }
                        
                        switch SessionTypes(rawValue: currentSession.session_type)! {
                        case .standard:
                            Text("STANDARD SESSION")
                                .font(.system(size: 17, weight: .medium))
                                .padding(.trailing)
                        case .algtrainer:
                            Text("ALG TRAINER")
                                .font(.system(size: 17, weight: .medium))
                            Picker("", selection: $algTrainerSubset) {
                                Text("EG-1")
                                    .font(.system(size: 15, weight: .regular))
                            }
                            .pickerStyle(.menu)
                            .padding(.leading, 8)
                            .padding(.trailing)
                        case .multiphase:
                            Text("MULTIPHASE")
                                .font(.system(size: 17, weight: .medium))
                            Picker("", selection: $algTrainerSubset) {
                                Text("3 PHASES")
                                    .font(.system(size: 15, weight: .regular))
                            }
                            .pickerStyle(.menu)
                            .padding(.leading, 8)
                            .padding(.trailing)
                        case .playground:
                            Text("PLAYGROUND")
                                .font(.system(size: 17, weight: .medium))
                                .onTapGesture() {
                                    NSLog("\(playgroundScrambleType), currentsession: \(currentSession.scramble_type)")
                                }
                            Picker("", selection: $playgroundScrambleType) {
                                ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                                    Text(element.name).tag(index)
                                        .font(.system(size: 15, weight: .regular))
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: playgroundScrambleType) { newValue in
                                currentSession.scramble_type = Int32(newValue)
                                stopWatchManager.nextScrambleStr = nil
                                stopWatchManager.rescramble()
                                // TODO do not rescramble when setting to same scramble eg 3blnd -> 3oh
                            }
                            .padding(.leading, 8)
                            .padding(.trailing)
                            
                        case .compsim:
                            Text("COMP SIM")
                                .font(.system(size: 17, weight: .medium))
                            Text("SOLVE 2/5")
                                .font(.system(size: 15, weight: .regular))
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            HStack (spacing: 10) {
                                Image(systemName: "target")
                                    .font(.system(size: 15))
                                
                                Text("picker")
                            }
                            .padding(.trailing)
                            .foregroundColor(accentColour)
                            
                            
//                            TextField(compSimTarget, text: $compSimTarget)
//                                .keyboardType(.decimalPad)
                        }
                    }
                    .background(Color(uiColor: .systemGray5))
                    .frame(height: 35)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.top, SetValues.hasBottomBar ? 0 : hideTabBar ? nil : 8)
                    
                    Spacer()
                }
                
                
                Spacer()
            }
            
            
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
                managedObjectContext.delete(detail.wrappedValue!)
                detail.wrappedValue = nil
                stopWatchManager.secondsElapsed = 0
                try! managedObjectContext.save()
                stopWatchManager.secondsStr = formatSolveTime(secs: 0)
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
        .onReceive(stopWatchManager.$mode) { newMode in
            hideTabBar = newMode == .inspecting || newMode == .running
            
            
            withAnimation(.easeIn(duration: 0.1)) {
                hideStatusBar = newMode == .inspecting || newMode == .running
                
            }
        }
        .statusBar(hidden: hideStatusBar) /// TODO MAKE SO ANIMATION IS ASYMMETRIC WITH VALUES OF THE OTHER ANIMATIONS
    }
}
