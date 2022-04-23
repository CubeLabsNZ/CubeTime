import CoreData
import SwiftUI
import CoreGraphics
import Combine





struct TimerView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @Environment(\.horizontalSizeClass) var hSizeClass
   
    
    
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @AppStorage("onboarding") var showOnboarding: Bool = true
    
    @AppStorage(gsKeys.showScramble.rawValue) private var showScramble: Bool = true
    @AppStorage(gsKeys.showStats.rawValue) private var showStats: Bool = true
    
    @AppStorage(gsKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    
    
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @Binding var hideTabBar: Bool
    
    @Binding var currentSession: Sessions
    
    @Binding var pageIndex: Int
    
    @State private var targetStr: String
    
    @State private var manualInputTime: String = ""
    
    @State private var showInputField: Bool = false
    
    @State private var phaseCount: Int
    
    @State var hideStatusBar = true
    
    @State var algTrainerSubset = 0
    @State var playgroundScrambleType: Int
    
    @State private var presentedAvg: CalculatedAverage?
    
    @State private var showScrambleSheet: Bool = false
    @State private var showDrawScrambleSheet: Bool = false
    
    
    @State private var textRect = CGRect()
    
    @FocusState private var targetFocused: Bool
    
    @FocusState private var manualInputFocused: Bool
    
//    @State var compSimTarget: String
    
    
    let stats: Stats
    
    var currentAo5: CalculatedAverage?
    var currentAo12: CalculatedAverage?
    var currentAo100: CalculatedAverage?
    var sessionMean: Double?
    
    
    var bpa: Double?
    var wpa: Double?
    
    @State var timeNeededForTarget: Double?
    
    private var scaleAmount: CGFloat
       
    
    init(pageIndex: Binding<Int>, currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext, hideTabBar: Binding<Bool>) {
        self._pageIndex = pageIndex
        self._currentSession = currentSession
        self._hideTabBar = hideTabBar
        self._playgroundScrambleType = State(initialValue: Int(currentSession.wrappedValue.scramble_type))
        
        self._targetStr = State(initialValue: filteredStrFromTime((currentSession.wrappedValue as? CompSimSession)?.target))
        
        self._phaseCount = State(initialValue: Int((currentSession.wrappedValue as? MultiphaseSession)?.phase_count ?? 0))
        
        stats = Stats(currentSession: currentSession.wrappedValue)
        
        
        self.currentAo5 = stats.getCurrentAverageOf(5)
        self.currentAo12 = stats.getCurrentAverageOf(12)
        self.currentAo100 = stats.getCurrentAverageOf(100)
        self.sessionMean = stats.getSessionMean()
        
        
        self.bpa = stats.getWpaBpa().0
        self.wpa = stats.getWpaBpa().1
        
        self._timeNeededForTarget = State(initialValue: stats.getTimeNeededForTarget())
        
        self.scaleAmount = {
            let type = Int(currentSession.wrappedValue.scramble_type)
            
            switch type {
            case 2: return 0.86 // 4
            case 3: return 0.68 // 5
            case 4: return 0.58 // 6
            case 5: return 0.5 // 7
            case 6: return 0.48 // sq1
            case 7: return  0.50 // mega
            case 8: return 0.68 // pyra
            case 9: return 0.48 // clock
            case 10: return 0.60 // skewb
            default:
                return 1
            }
        }()
    }
    
    var body: some View {
        ZStack {
            // BACKGROUND COLOUR
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
    
            // SCRAMBLE
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
                        .font(.system(size: hSizeClass == .regular ? 28 : 22, weight: .semibold, design: .rounded))
                        .foregroundColor(colourScheme == .light ? .black : nil)
                        .offset(y: 52)
                } else if stopWatchManager.inspectionSecs >= 15 {
                    Text("+2")
                        .font(.system(size: hSizeClass == .regular ? 28 : 22, weight: .semibold, design: .rounded))
                        .foregroundColor(colourScheme == .light ? .black : nil)
                        .offset(y: 52)
                }
            }
            
            VStack {
                Spacer()
                
                Text(stopWatchManager.secondsStr)
                    .foregroundColor({
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
                    .modifier(AnimatingFontSize(fontSize: stopWatchManager.mode == .running ? 100 : 72))
                    .modifier(DynamicText())
                    .animation(Animation.spring(), value: stopWatchManager.mode == .running)
                
                Spacer()
            }
            .ignoresSafeArea(edges: .all)
            
            // TOUCH (GESTURE) RECOGNISER
            GeometryReader { geometry in
                ZStack {
                    
                    TimerTouchView(stopWatchManager: stopWatchManager)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .environmentObject(stopWatchManager)
                                        
                    if targetFocused || manualInputFocused /*|| (!manualInputFocused && showInputField)*/ {
//                        Color.clear.contentShape(Path(CGRect(origin: .zero, size: geometry.size)))
                        /// ^ this receives tap gesture but gesture is transferred to timertouchview below...
                        Color.white.opacity(0.000001) // workaround for now
                            .onTapGesture {
                                targetFocused = false
                                manualInputFocused = false
                                showInputField = false
                            }
                    }
                }
                
            }
            .ignoresSafeArea(edges: .top)
            
            
            // VIEWS WHEN TIMER NOT RUNNING
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
                            
                            // TOP BAR
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
                                .padding(.leading, 6)
                                .padding(.trailing)
                                .accentColor(accentColour)
                            case .multiphase:
                                Text("MULTIPHASE")
                                    .font(.system(size: 17, weight: .medium))
                                
                                HStack(spacing: 0) {
                                    Text("PHASES: ")
                                        .font(.system(size: 15, weight: .regular))
                                    
                                    Text("\(phaseCount)")
                                        .font(.system(size: 15, weight: .regular))
                                    
                                    /// TEMPORARILY REMOVED THE PICKER UNTIL MULTIPHASE PLAYGROUND IS ADDED - MIGRATE TO THERE
                                    
                                    /*
                                    Picker("", selection: $phaseCount) {
                                        ForEach((2...8), id: \.self) { phase in
                                            Text("\(phase)").tag(phase)
                                                .font(.system(size: 15, weight: .regular))
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .frame(width: 8)
                                    .onChange(of: phaseCount) { newValue in
                                        (currentSession as! MultiphaseSession).phase_count = Int16(phaseCount)
    
                                        try! managedObjectContext.save()
                                    }
                                     */
                                }
                                .padding(.leading, 6)
                                .padding(.trailing)
                            case .playground:
                                Text("PLAYGROUND")
                                    .font(.system(size: 17, weight: .medium))
                                    
                                Picker("", selection: $playgroundScrambleType) {
                                    ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                                        Text(element.name).tag(index)
                                            .font(.system(size: 15, weight: .regular))
                                    }
                                }
                                .accentColor(accentColour)
                                .pickerStyle(.menu)
                                .onChange(of: playgroundScrambleType) { newValue in
                                    currentSession.scramble_type = Int32(newValue)
//                                    stopWatchManager.nextScrambleStr = nil
                                    stopWatchManager.rescramble()
                                    // TODO do not rescramble when setting to same scramble eg 3blnd -> 3oh
                                }
                                .padding(.leading, 6)
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
                                        .foregroundColor(accentColour)
                                    
                                    ZStack {
                                        Text(targetStr == "" ? "0.00" : targetStr)
                                            .background(GlobalGeometryGetter(rect: $textRect))
                                            .layoutPriority(1)
                                            .opacity(0)
                                        
                                        
                                        TextField("0.00", text: $targetStr)
                                            .frame(width: textRect.width + CGFloat(targetStr.count > 6 ? 12 : 6))
    //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                            .submitLabel(.done)
                                            .focused($targetFocused)
                                            .multilineTextAlignment(.leading)
                                            .tint(accentColour)
                                            .modifier(TimeMaskTextField(text: $targetStr, onReceiveAlso: { text in
                                                if let time = timeFromStr(text) {
                                                    (currentSession as! CompSimSession).target = time
                                                    
                                                    try! managedObjectContext.save()
                                                }
                                                timeNeededForTarget = stats.getTimeNeededForTarget()
                                            }))
                                            .padding(.trailing, 4)
                                    }
                                        
                                }
                                .padding(.leading, 6)
                                .padding(.trailing, 12)
                                .foregroundColor(accentColour)
                                
                                
    //                            TextField(compSimTarget, text: $compSimTarget)
    //                                .keyboardType(.decimalPad)
                            }
                        }
                        .background(Color(uiColor: .systemGray5))
                        .frame(height: 35)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(.horizontal)
                        .padding(.top, SetValues.hasBottomBar ? 0 : hideTabBar ? nil : 8)
                        
                        Spacer()
                    }
                    
                    
                    Spacer()
                }
                
                if hSizeClass == .regular {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            
                            let maxWidth = geometry.size.width - 12 - UIScreen.screenWidth/1.35
                                     
                            ZStack {
                                // SCRAMBLE VIEW
                                if showScramble {
                                    HStack {
                                        ZStack(alignment: .bottomLeading) {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(uiColor: .systemGray5))
                                                .frame(width: maxWidth, height: 120)
                                            
                                            // tried .overlay but the geometry becomes fixed and scaling doesn't work correctly
                                            
                                            if let svg = stopWatchManager.scrambleSVG {
                                                TimerScrambleView(svg: svg)
                                                    .aspectRatio(contentMode: .fit)
                                                    .onTapGesture { showDrawScrambleSheet = true }
                                                    .frame(width: maxWidth-4, height: 116)
                                                    .scaleEffect(scaleAmount)
                                                
                                                    .offset(x: 1, y: -2.5)
                                                
                                            } else {
                                                ProgressView()
                                                    .frame(width: maxWidth-4, height: 116)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                
                                
                                // STATS
                                if showStats && SessionTypes(rawValue: currentSession.session_type)! != .compsim {
                                    HStack {
                                        Spacer()
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(uiColor: .systemGray5))
                                                .frame(width: UIScreen.screenWidth/4, height: 120)
                                            
                                            
                                            VStack(spacing: 6) {
                                                HStack(spacing: 0) {
                                                    VStack(spacing: 0) {
                                                        Text("AO5")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let currentAo5 = currentAo5 {
                                                            Text(formatSolveTime(secs: currentAo5.average!, penType: currentAo5.totalPen))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/8-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("-")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                            
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    .onTapGesture {
                                                        if currentAo5 != nil && currentAo5?.totalPen != .dnf {
                                                            presentedAvg = currentAo5
                                                        }
                                                    }
                                                    
                                                    VStack(spacing: 0) {
                                                        Text("AO12")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let currentAo12 = currentAo12 {
                                                            Text(formatSolveTime(secs: currentAo12.average!, penType: currentAo12.totalPen))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/8-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("-")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    .onTapGesture {
                                                        if currentAo12 != nil && currentAo12?.totalPen != .dnf {
                                                            presentedAvg = currentAo12
                                                        }
                                                    }
                                                }
                                                .padding(.top, 6)
                                                
                                                Divider()
                                                    .frame(width: UIScreen.screenWidth/4 - 48)
                                                
                                                HStack(spacing: 0) {
                                                    VStack(spacing: 0) {
                                                        Text("AO100")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let currentAo100 = currentAo100 {
                                                            Text(formatSolveTime(secs: currentAo100.average!, penType: currentAo100.totalPen))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/8-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("-")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    .onTapGesture {
                                                        if currentAo100 != nil && currentAo100?.totalPen != .dnf {
                                                            presentedAvg = currentAo100
                                                        }
                                                    }
                                                    
                                                    VStack(spacing: 0) {
                                                        Text("MEAN")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let sessionMean = sessionMean {
                                                            Text(formatSolveTime(secs: sessionMean))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/8-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("-")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                }
                                                .padding(.bottom, 6)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        .frame(width: UIScreen.screenWidth/4, height: 120)
                                    }
                                } else if showStats && SessionTypes(rawValue: currentSession.session_type)! == .compsim {
                                    HStack {
                                        Spacer()
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(uiColor: .systemGray5))
                                                .frame(width: UIScreen.screenWidth/2, height: 120)
                                            
                                            
                                            VStack(spacing: 6) {
                                                HStack {
                                                    VStack(spacing: 0) {
                                                        Text("BPA")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let bpa = bpa {
                                                            Text(formatSolveTime(secs: bpa))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/4-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("...")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                            
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    
                                                    VStack(spacing: 0) {
                                                        Text("WPA")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let wpa = wpa {
                                                            if wpa == -1 {
                                                                Text("DNF")
                                                                    .font(.system(size: 24, weight: .bold))
                                                                    .modifier(DynamicText())
                                                            } else {
                                                                Text(formatSolveTime(secs: wpa))
                                                                    .font(.system(size: 24, weight: .bold))
                                                                    .frame(maxWidth: UIScreen.screenWidth/4-8)
                                                                    .modifier(DynamicText())
                                                            }
                                                            
                                                            
                                                            
                                                        } else {
                                                            Text("...")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                }
                                                .padding(.top, 6)
                                                
                                                Divider()
                                                    .frame(width: UIScreen.screenWidth/2 - 48)
                                                
                                                VStack(spacing: 0) {
                                                    Text("TO REACH TARGET")
                                                        .font(.system(size: 13, weight: .medium))
                                                    
                                                    if let timeNeededForTarget = timeNeededForTarget {
                                                        if timeNeededForTarget == -1 {
                                                            Text("Not Possible")
                                                                .font(.system(size: 22, weight: .bold))
                                                                .modifier(DynamicText())
                                                        } else if timeNeededForTarget == -2 {
                                                            Text("Guaranteed")
                                                                .font(.system(size: 22, weight: .bold))
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("≤"+formatSolveTime(secs: timeNeededForTarget))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .modifier(DynamicText())
                                                        }
                                                        
                                                        
                                                        
                                                    } else {
                                                        Text("...")
                                                            .font(.system(size: 24, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray))
                                                    }
                                                }
                                                .padding(.bottom, 6)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        .frame(width: UIScreen.screenWidth/2, height: 120)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .safeAreaInset(edge: .bottom, spacing: 0) {Rectangle().fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : 12)}
                } else {
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            
                            let maxWidth = geometry.size.width - 12 - UIScreen.screenWidth/2
                            
                                                    
                            ZStack {
                                // SCRAMBLE VIEW
                                if showScramble {
                                    HStack {
                                        ZStack(alignment: .bottomLeading) {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(uiColor: .systemGray5))
                                                .frame(width: maxWidth, height: 120)
                                            
                                            // tried .overlay but the geometry becomes fixed and scaling doesn't work correctly
                                            
                                            if let svg = stopWatchManager.scrambleSVG {
                                                TimerScrambleView(svg: svg)
                                                    .aspectRatio(contentMode: .fit)
                                                    .onTapGesture { showDrawScrambleSheet = true }
                                                    .frame(width: maxWidth-4, height: 116)
                                                    .scaleEffect(scaleAmount)
                                                
                                                    .offset(x: 1, y: -2.5)
                                                
                                            } else {
                                                ProgressView()
                                                    .frame(width: maxWidth-4, height: 116)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                
                                
                                // STATS
                                if showStats && SessionTypes(rawValue: currentSession.session_type)! != .compsim {
                                    HStack {
                                        Spacer()
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(uiColor: .systemGray5))
                                                .frame(width: UIScreen.screenWidth/2, height: 120)
                                            
                                            
                                            VStack(spacing: 6) {
                                                HStack(spacing: 0) {
                                                    VStack(spacing: 0) {
                                                        Text("AO5")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let currentAo5 = currentAo5 {
                                                            Text(formatSolveTime(secs: currentAo5.average!, penType: currentAo5.totalPen))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/4-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("-")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                            
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    .onTapGesture {
                                                        if currentAo5 != nil && currentAo5?.totalPen != .dnf {
                                                            presentedAvg = currentAo5
                                                        }
                                                    }
                                                    
                                                    VStack(spacing: 0) {
                                                        Text("AO12")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let currentAo12 = currentAo12 {
                                                            Text(formatSolveTime(secs: currentAo12.average!, penType: currentAo12.totalPen))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/4-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("-")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    .onTapGesture {
                                                        if currentAo12 != nil && currentAo12?.totalPen != .dnf {
                                                            presentedAvg = currentAo12
                                                        }
                                                    }
                                                }
                                                .padding(.top, 6)
                                                
                                                Divider()
                                                    .frame(width: UIScreen.screenWidth/2 - 48)
                                                
                                                HStack(spacing: 0) {
                                                    VStack(spacing: 0) {
                                                        Text("AO100")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let currentAo100 = currentAo100 {
                                                            Text(formatSolveTime(secs: currentAo100.average!, penType: currentAo100.totalPen))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/4-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("-")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    .onTapGesture {
                                                        if currentAo100 != nil && currentAo100?.totalPen != .dnf {
                                                            presentedAvg = currentAo100
                                                        }
                                                    }
                                                    
                                                    VStack(spacing: 0) {
                                                        Text("MEAN")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let sessionMean = sessionMean {
                                                            Text(formatSolveTime(secs: sessionMean))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/4-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("-")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                }
                                                .padding(.bottom, 6)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        .frame(width: UIScreen.screenWidth/2, height: 120)
                                    }
                                } else if showStats && SessionTypes(rawValue: currentSession.session_type)! == .compsim {
                                    HStack {
                                        Spacer()
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(Color(uiColor: .systemGray5))
                                                .frame(width: UIScreen.screenWidth/2, height: 120)
                                            
                                            
                                            VStack(spacing: 6) {
                                                HStack {
                                                    VStack(spacing: 0) {
                                                        Text("BPA")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let bpa = bpa {
                                                            Text(formatSolveTime(secs: bpa))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .frame(maxWidth: UIScreen.screenWidth/4-8)
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("...")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                            
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    
                                                    VStack(spacing: 0) {
                                                        Text("WPA")
                                                            .font(.system(size: 13, weight: .medium))
                                                        
                                                        if let wpa = wpa {
                                                            if wpa == -1 {
                                                                Text("DNF")
                                                                    .font(.system(size: 24, weight: .bold))
                                                                    .modifier(DynamicText())
                                                            } else {
                                                                Text(formatSolveTime(secs: wpa))
                                                                    .font(.system(size: 24, weight: .bold))
                                                                    .frame(maxWidth: UIScreen.screenWidth/4-8)
                                                                    .modifier(DynamicText())
                                                            }
                                                            
                                                            
                                                            
                                                        } else {
                                                            Text("...")
                                                                .font(.system(size: 24, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                        }
                                                    }
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                }
                                                .padding(.top, 6)
                                                
                                                Divider()
                                                    .frame(width: UIScreen.screenWidth/2 - 48)
                                                
                                                VStack(spacing: 0) {
                                                    Text("TO REACH TARGET")
                                                        .font(.system(size: 13, weight: .medium))
                                                    
                                                    if let timeNeededForTarget = timeNeededForTarget {
                                                        if timeNeededForTarget == -1 {
                                                            Text("Not Possible")
                                                                .font(.system(size: 22, weight: .bold))
                                                                .modifier(DynamicText())
                                                        } else if timeNeededForTarget == -2 {
                                                            Text("Guaranteed")
                                                                .font(.system(size: 22, weight: .bold))
                                                                .modifier(DynamicText())
                                                        } else {
                                                            Text("≤"+formatSolveTime(secs: timeNeededForTarget))
                                                                .font(.system(size: 24, weight: .bold))
                                                                .modifier(DynamicText())
                                                        }
                                                        
                                                        
                                                        
                                                    } else {
                                                        Text("...")
                                                            .font(.system(size: 24, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray))
                                                    }
                                                }
                                                .padding(.bottom, 6)
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                        .frame(width: UIScreen.screenWidth/2, height: 120)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .safeAreaInset(edge: .bottom, spacing: 0) {Rectangle().fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : 12)}
                }
                // GEO READER FOR BOTTOM TOOLS
            }
            
            // MANUAL ENTRY FIELD
            if showInputField {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        TextField("0.00", text: $manualInputTime)
                            .focused($manualInputFocused)
                            .frame(maxWidth: UIScreen.screenWidth-32)
                            .font(.system(size: 56, weight: .bold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .foregroundColor(stopWatchManager.timerColour)
                            .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black))
                            .modifier(DynamicText())
                            .modifier(TimeMaskTextField(text: $manualInputTime))
                            
                        
                        Spacer()
                    }
                    
                        
                    Spacer()
                }
                .ignoresSafeArea(edges: .all)
                

            }
            
            
            // PENALTY BAR
            if stopWatchManager.showPenOptions {
                HStack(alignment: .center) {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        if !stopWatchManager.nilSolve {
                            if !manualInputFocused {
                                PenaltyBar(114) {
                                    HStack(spacing: 12) {
                                        PenaltyButton(penType: .plustwo, penSymbol: "+2", imageSymbol: true, canType: false, colour: Color.yellow)
                                        
                                        PenaltyButton(penType: .dnf, penSymbol: "xmark.circle", imageSymbol: false, canType: false, colour: Color.red)
                                        
                                        PenaltyButton(penType: .none, penSymbol: "checkmark.circle", imageSymbol: false, canType: false, colour: Color.green)
                                    }
                                    .offset(x: 1.5) // to future me who will refactor this, i've spent countless minutes trying to centre it in the bar and it just will not
                                }
                            }
                        }
                        
                        if currentSession.session_type != 2 {
                            if !stopWatchManager.nilSolve {
                                if !manualInputFocused && stopWatchManager.scrambleStr != nil {
                                    Rectangle()
                                        .fill(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray4))
                                        .frame(width: 1.5, height: 20)
                                        .padding(.horizontal, 12)
                                }
                            }
                            
                            if stopWatchManager.scrambleStr != nil {
                                PenaltyBar(manualInputFocused ? 68 : 34) {
                                    Button(action: {
                                        if manualInputFocused {
                                            if manualInputTime != "" {
                                                stopWatchManager.stop(timeFromStr(manualInputTime))
                                                
                                                
                                                showInputField = false
                                                
                                                
                                                manualInputFocused = false

                                                manualInputTime = ""
                                            }
                                        } else {
                                            showInputField = true
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                manualInputFocused = true
                                            }
                                            
                                            manualInputTime = ""
                                            
                                        }
                                    }, label: {
                                        if manualInputFocused {
                                            Text("Done")
                                                .font(.system(size: 21, weight: .semibold, design: .rounded))
                                        } else {
                                            Image(systemName: "plus.circle")
                                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                        }
                                    })
                                        .disabled(manualInputFocused ? (manualInputTime == "") : false)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .offset(y: 45)
                .ignoresSafeArea(edges: .all)

            }
            
            
            if stopWatchManager.mode == .stopped {
                if let scr = stopWatchManager.scrambleStr {
                    VStack {
                        Text(scr)
                            .font(.system(size: currentSession.scramble_type == 7 ? (UIScreen.screenWidth) / (42.00) * 1.44 : CGFloat(scrambleSize), weight: .semibold, design: .monospaced))
                            .frame(maxHeight: UIScreen.screenHeight/3)
                            .multilineTextAlignment(currentSession.scramble_type == 7 ? .leading : .center)
                            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
                            .onTapGesture {
                                showScrambleSheet = true
                            }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .offset(y: 35 + (SetValues.hasBottomBar ? 0 : 8))
                
                    
                } else {
                    HStack {
                        Spacer()
                        
                        VStack {
                            ProgressView()
                                .frame(maxHeight: 35)
                                .padding(.trailing)
                            
                            Spacer()
                        }
                    }
                    
                }
            }
        }
        .sheet(isPresented: $showScrambleSheet) {
            ScrambleDetail(stopWatchManager.scrambleStr!)
        }
        .sheet(isPresented: $showDrawScrambleSheet) {
            DiagramDetail(stopWatchManager.scrambleSVG)
        }
        .sheet(item: $presentedAvg) { item in
            StatsDetail(solves: item, session: currentSession)
        }
        .onReceive(stopWatchManager.$mode) { newMode in
            hideTabBar = newMode == .inspecting || newMode == .running
            hideStatusBar = newMode == .inspecting || newMode == .running
        }
        .statusBar(hidden: hideStatusBar) /// TODO MAKE SO ANIMATION IS ASYMMETRIC WITH VALUES OF THE OTHER ANIMATIONS
        .ignoresSafeArea(.keyboard)
    }
}

struct ScrambleDetail: View {
    @AppStorage(gsKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    @Environment(\.dismiss) var dismiss
    
    var scramble: String
    
    init(_ scramble: String) {
        self.scramble = scramble
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(scramble)
                    .font(.system(size: CGFloat(scrambleSize), weight: .semibold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                            }
                        }
                    }
            }
            .navigationTitle("Scramble")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DiagramDetail: View {
    @Environment(\.dismiss) var dismiss
    
    var svg: OrgWorldcubeassociationTnoodleSvgliteSvg?
    
    init(_ svg: OrgWorldcubeassociationTnoodleSvgliteSvg?) {
        self.svg = svg
    }
    
    
    var body: some View {
        NavigationView {
            if let svg = svg {
                TimerScrambleView(svg: svg)
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                    .navigationTitle("Scramble")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                ProgressView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                    .navigationTitle("Scramble")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
