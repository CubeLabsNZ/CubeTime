import CoreData
import SwiftUI
import CoreGraphics
import Combine


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
    
    
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @Binding var hideTabBar: Bool
    
    @Binding var currentSession: Sessions
    
    @Binding var pageIndex: Int
    
    @State private var targetStr: String
    
    @State private var phaseCount: Int
    
    @State var hideStatusBar = true
    
    @State var algTrainerSubset = 0
    @State var playgroundScrambleType: Int
    
    
    @State private var textRect = CGRect()
    
    
    @FocusState private var targetFocused: Bool
    
//    @State var compSimTarget: String
    
    
    init(pageIndex: Binding<Int>, currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext, hideTabBar: Binding<Bool>) {
        self._pageIndex = pageIndex
        self._currentSession = currentSession
        self._hideTabBar = hideTabBar
        self._playgroundScrambleType = State(initialValue: Int(currentSession.wrappedValue.scramble_type))
        
        self._targetStr = State(initialValue: filteredStrFromTime((currentSession.wrappedValue as? CompSimSession)?.target))
        
        self._phaseCount = State(initialValue: Int((currentSession.wrappedValue as? MultiphaseSession)?.phase_count ?? 0))
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
                    case let x where x >= 15: InspectionColours.penaltyColour
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
                        .font(.system(size: currentSession.scramble_type == 7 ? (UIScreen.screenWidth) / (42.00) * 1.44 : 18, weight: .semibold, design: .monospaced))
                        .frame(maxHeight: UIScreen.screenHeight/3)
                        .multilineTextAlignment(currentSession.scramble_type == 7 ? .leading : .center)
                        .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
                    
                    
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
                ZStack {
                    TimerTouchView(stopWatchManager: stopWatchManager)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .environmentObject(stopWatchManager)
                    
                    if targetFocused {
//                        Color.clear.contentShape(Path(CGRect(origin: .zero, size: geometry.size)))
                        /// ^ this receives tap gesture but gesture is transferred to timertouchview below...
                        Color.white.opacity(0.000001) // workaround for now
                            .onTapGesture {
                                targetFocused = false
                            }
                    }
                }
                
            }
            .ignoresSafeArea(edges: .top)
            
            
            if !hideTabBar {
                VStack {
                    HStack {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
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
                                
                                HStack(spacing: 0) {
                                    Text("PHASES: ")
                                    
                                    Picker("", selection: $phaseCount) {
                                        ForEach((2...8), id: \.self) { phase in
                                            Text("\(phase)").tag(phase)
                                                .font(.system(size: 15, weight: .regular))
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 10)
                                    .onChange(of: phaseCount) { newValue in
                                        (currentSession as! MultiphaseSession).phase_count = Int16(phaseCount)
    
                                        try! managedObjectContext.save()
                                    }
                                    .padding(.leading, 8)
                                    .padding(.trailing)
                                }
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
                                
                                let solveth: Int = stopWatchManager.currentSolveth!+1
                                
                                Text("SOLVE \(solveth == 6 ? 1 : solveth)")
                                    .font(.system(size: 15, weight: .regular))
                                    .padding(.horizontal, 2)
                                
                                Divider()
                                    .padding(.vertical, 4)
                                
                                HStack (spacing: 10) {
                                    Image(systemName: "target")
                                        .font(.system(size: 15))
                                    
                                    ZStack {
                                        Text(targetStr == "" ? "0.00" : targetStr)
                                            .background(GlobalGeometryGetter(rect: $textRect))
                                            .layoutPriority(1)
                                            .opacity(0)
                                        
                                        
                                        TextField("0.00", text: $targetStr)
                                            .frame(width: textRect.width + CGFloat(targetStr.count > 6 ? 12 : 6))
    //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                            .keyboardType(.numberPad)
                                            .submitLabel(.done)
                                            .focused($targetFocused)
                                            .multilineTextAlignment(.leading)
                                            .onReceive(Just(targetStr)) { newValue in
                                                let filtered = filteredTimeInput(newValue)
                                                if filtered != newValue {
                                                    self.targetStr = filtered
                                                }
                                                
                                                if let time = timeFromStr(targetStr) {
                                                    (currentSession as! CompSimSession).target = time
                                                    
                                                    try! managedObjectContext.save()
                                                }
                                            }
                                            .padding(.trailing, 4)
                                    }
                                        
                                }
                                .padding(.trailing, 12)
                                .foregroundColor(accentColour)
                                
                                
    //                            TextField(compSimTarget, text: $compSimTarget)
    //                                .keyboardType(.decimalPad)
                            }
                        }
                        .background(Color(uiColor: .systemGray5))
                        .frame(height: 35)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    //                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.top, SetValues.hasBottomBar ? 0 : hideTabBar ? nil : 8)
                        
                        Spacer()
                    }
                    
                    
                    Spacer()
                }
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
            hideStatusBar = newMode == .inspecting || newMode == .running
        }
        .statusBar(hidden: hideStatusBar) /// TODO MAKE SO ANIMATION IS ASYMMETRIC WITH VALUES OF THE OTHER ANIMATIONS
    }
}
