import CoreData
import SwiftUI
import CoreGraphics
import Combine


struct SheetStrWrapper: Identifiable {
    let id = UUID()
    let str: String
}


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
    
    @State private var manualInputTime: String = ""
    
    @State private var showInputField: Bool = false
    
    @State var hideStatusBar = true
    
    @State var algTrainerSubset = 0
    
    @State private var presentedAvg: CalculatedAverage?
    
    @State private var scrambleSheetStr: SheetStrWrapper? = nil
    @State private var showDrawScrambleSheet: Bool = false
    
    
    @EnvironmentObject var tabRouter: TabRouter
    
    
    @FocusState private var targetFocused: Bool
    
    @FocusState private var manualInputFocused: Bool

    private var scaleAmount: [Int32: CGFloat] = [
        0: 1, // 2
        1: 1, // 3
        2: 0.86, // 4
        3: 0.68, // 5
        4: 0.58, // 6
        5: 0.5, // 7
        6: 0.48, // sq1
        7: 0.50, // mega
        8: 0.68, // pyra
        9: 0.48, // clock
        10: 0.60, // skewb
    ]
    
    let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                        (scene as? UIWindowScene)?.keyWindow
                    }).first?.frame.size

    var largePad: Bool
    
    
    @State var floatingPanelStage: Int = 3
    
    // TODO find a way to not use an initializer
    init(largePad: Bool = false) {
        self.largePad = largePad
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
            
            // TIMER TEXT / INSPECTION
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
                    .if(hSizeClass == .regular) { view in
                        view.modifier(AnimatingFontSize(fontSize: stopWatchManager.mode == .running ? 100 : 72))
                    }
                    .if(hSizeClass == .compact) { view in
                        view.modifier(AnimatingFontSize(fontSize: stopWatchManager.mode == .running ? 70 : 56))
                    }
                    .modifier(DynamicText())
                    .animation(Animation.spring(), value: stopWatchManager.mode == .running)
                let _ = NSLog("\(hSizeClass)")
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
            
            // IPAD BAR
            
            if largePad {
                GeometryReader { proxy in
                    FloatingPanelChild(currentStage: $floatingPanelStage, maxHeight: proxy.frame(in: .local).height, stages: [0, 50, 150, proxy.frame(in: .local).height/2, (proxy.frame(in: .local).height - 24)]) {
                        EmptyView()
                        TimerHeader(targetFocused: $targetFocused)
                        VStack {
                            TimerHeader(targetFocused: $targetFocused)
                            PrevSolvesDisplay()
                        }
                        Text("3")
                        Text("4")
                    }
                    .background(Color.blue)
                }
                .background(Color.red)
            }
            
            // VIEWS WHEN TIMER NOT RUNNING
            if !tabRouter.hideTabBar {
                if !largePad {
                    // TODO fix
                    VStack {
                        HStack {
                            TimerHeader(targetFocused: $targetFocused)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                
                //.offset(x: hSizeClass == .regular && orientation.orientation == .landscape ? 4 : 0, y: hSizeClass == .regular && orientation.orientation == .landscape ? 4 : 0)
                
                // GEO READER FOR BOTTOM TOOLS
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
                                            if let scr = stopWatchManager.scrambleStr {
                                                TimerScrambleView(svg: svg)
                                                    .aspectRatio(contentMode: .fit)
                                                    .onTapGesture {
                                                        scrambleSheetStr = SheetStrWrapper(str: scr)
                                                    }
    //                                                .onTapGesture { showDrawScrambleSheet = true }
                                                    .frame(width: maxWidth-4, height: 116)
                                                    .scaleEffect(scaleAmount[stopWatchManager.currentSession.scramble_type]!)
                                                
                                                    .offset(x: 1, y: -2.5)
                                            }
                                        } else {
                                            ProgressView()
                                                .frame(width: maxWidth-4, height: 116)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            
                            
                            // STATS
                            if showStats && SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! != .compsim {
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
                                                    
                                                    if let currentAo5 = stopWatchManager.currentAo5 {
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
                                                    if stopWatchManager.currentAo5 != nil && stopWatchManager.currentAo5?.totalPen != .dnf {
                                                        presentedAvg = stopWatchManager.currentAo5
                                                    }
                                                }
                                                
                                                VStack(spacing: 0) {
                                                    Text("AO12")
                                                        .font(.system(size: 13, weight: .medium))
                                                    
                                                    if let currentAo12 = stopWatchManager.currentAo12 {
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
                                                    if stopWatchManager.currentAo12 != nil && stopWatchManager.currentAo12?.totalPen != .dnf {
                                                        presentedAvg = stopWatchManager.currentAo12
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
                                                    
                                                    if let currentAo100 = stopWatchManager.currentAo100 {
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
                                                    if stopWatchManager.currentAo100 != nil && stopWatchManager.currentAo100?.totalPen != .dnf {
                                                        presentedAvg = stopWatchManager.currentAo100
                                                    }
                                                }
                                                
                                                VStack(spacing: 0) {
                                                    Text("MEAN")
                                                        .font(.system(size: 13, weight: .medium))
                                                    
                                                    if let sessionMean = stopWatchManager.sessionMean {
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
                            } else if showStats && SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! == .compsim {
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
                                                    
                                                    if let bpa = stopWatchManager.bpa {
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
                                                    
                                                    if let wpa = stopWatchManager.wpa {
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
                                                
                                                if let timeNeededForTarget = stopWatchManager.timeNeededForTarget {
                                                    if timeNeededForTarget == -1 {
                                                        Text("Not Possible")
                                                            .font(.system(size: 22, weight: .bold))
                                                            .modifier(DynamicText())
                                                    } else if timeNeededForTarget == -2 {
                                                        Text("Guaranteed")
                                                            .font(.system(size: 22, weight: .bold))
                                                            .modifier(DynamicText())
                                                    } else {
                                                        Text("...")
                                                            .font(.system(size: 24, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray))
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 6) // TODO check if this is right
                                            .padding(.horizontal, 4)
                                        }
                                        .frame(width: windowSize!.width/2, height: 120)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .if(!largePad) { content in
                        content
                            .safeAreaInset(edge: .bottom, spacing: 0) {Rectangle().fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : 12)}
                    }
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
                            .frame(maxWidth: windowSize!.width-32)
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
                                PenaltyBar(122) {
                                    HStack(spacing: 12) {
                                        PenaltyButton(penType: .plustwo, penSymbol: "+2", imageSymbol: true, canType: false, colour: Color.yellow)
                                        
                                        PenaltyButton(penType: .dnf, penSymbol: "xmark.circle", imageSymbol: false, canType: false, colour: Color.red)
                                        
                                        PenaltyButton(penType: .none, penSymbol: "checkmark.circle", imageSymbol: false, canType: false, colour: Color.green)
                                    }
                                    .offset(x: 1.5) // to future me who will refactor this, i've spent countless minutes trying to centre it in the bar and it just will not
                                }
                            }
                        }
                        
                        if stopWatchManager.currentSession.session_type != 2 {
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
                            .font(.system(size: stopWatchManager.currentSession.scramble_type == 7 ? (windowSize!.width) / (42.00) * 1.44 : CGFloat(scrambleSize), weight: .semibold, design: .monospaced))
                            .frame(maxHeight: UIScreen.screenHeight/3)
                            .multilineTextAlignment(stopWatchManager.currentSession.scramble_type == 7 ? .leading : .center)
                            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
                            .onTapGesture {
                                scrambleSheetStr = SheetStrWrapper(str: scr)
                            }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .offset(y: largePad ? 0 : 35 + (SetValues.hasBottomBar ? 0 : 8))
                
                    
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

            
            
            Button {
                stopWatchManager.interruptInspection()
            } label: {
                Text("stop")
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
        .sheet(item: $scrambleSheetStr) { str in
            TimeScrambleDetail(str.str, stopWatchManager.scrambleSVG)
//            ScrambleDetail(str.str)
        }
//        .sheet(isPresented: $showDrawScrambleSheet) {
//            DiagramDetail(stopWatchManager.scrambleSVG)
//        }
        .sheet(item: $presentedAvg) { item in
            StatsDetail(solves: item, session: stopWatchManager.currentSession)
        }
        .onReceive(stopWatchManager.$mode) { newMode in
            tabRouter.hideTabBar = newMode == .inspecting || newMode == .running
            hideStatusBar = newMode == .inspecting || newMode == .running
        }
        .statusBar(hidden: hideStatusBar) /// TODO MAKE SO ANIMATION IS ASYMMETRIC WITH VALUES OF THE OTHER ANIMATIONS
        .ignoresSafeArea(.keyboard)
    }
}


struct TimeScrambleDetail: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    var scramble: String
    var svg: OrgWorldcubeassociationTnoodleSvgliteSvg?
    @State var windowedScrambleSize: Int = UserDefaults.standard.integer(forKey: gsKeys.scrambleSize.rawValue)
    
    init(_ scramble: String, _ svg: OrgWorldcubeassociationTnoodleSvgliteSvg?) {
        self.scramble = scramble
        self.svg = svg
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text(scramble)
                        .font(.system(size: CGFloat(windowedScrambleSize), weight: .semibold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                
                if let svg = svg {
                    TimerScrambleView(svg: svg)
                        .aspectRatio(contentMode: .fit)
                        .padding()
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Scramble")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(alignment: .bottom) {
                        Button {
                            windowedScrambleSize = max(windowedScrambleSize - 1, 1)
                        } label: {
                            Image(systemName: "textformat.size.smaller")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(accentColour)
                        }
                        
                        
                        Button {
                            windowedScrambleSize += 1
                        } label: {
                            Image(systemName: "textformat.size.larger")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(accentColour)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}
