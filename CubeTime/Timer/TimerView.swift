import CoreData
import SwiftUI
import CoreGraphics
import Combine
import SwiftfulLoadingIndicators


struct SheetStrWrapper: Identifiable {
    let id = UUID()
    let str: String
}


struct TimerView: View {
    @EnvironmentObject var stopWatchManager: StopWatchManager
    @EnvironmentObject var tabRouter: TabRouter
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    // GET USER DEFAULTS
    @AppStorage("onboarding") var showOnboarding: Bool = true
    @AppStorage(gsKeys.showCancelInspection.rawValue) private var showCancelInspection: Bool = true
    @AppStorage(gsKeys.showSessionName.rawValue) private var showSessionName: Bool = false
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @AppStorage(gsKeys.showScramble.rawValue) private var showScramble: Bool = true
    @AppStorage(gsKeys.showStats.rawValue) private var showStats: Bool = true
    @AppStorage(gsKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    @AppStorage(gsKeys.showPrevTime.rawValue) private var showPrevTime: Bool = false
    @AppStorage(gsKeys.inputMode.rawValue) private var inputMode: InputMode = .timer
    
    // FOCUS STATES
    @FocusState private var targetFocused: Bool
    @FocusState private var manualInputFocused: Bool
    
    // STATES
    @State private var manualInputTime: String = ""
    @State private var showInputField: Bool = false
    @State private var toggleSessionName: Bool = false
    
    @State private var presentedAvg: CalculatedAverage?
    @State private var scrambleSheetStr: SheetStrWrapper? = nil
    @State private var showDrawScrambleSheet: Bool = false
    
    @State private var justManuallyInput: Bool = false
    @State private var showManualInputFormattedText: Bool = false
    
    @State var hideStatusBar = true
    @State var algTrainerSubset = 0

    
    // iPAD SPECIFIC
    @State var floatingPanelStage: Int = 2
    
    let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                        (scene as? UIWindowScene)?.keyWindow
                    }).first?.frame.size

    let useExtendedView: Bool = UIDevice.useExtendedView
    
    
    
    #warning("TODO: find a way to not use an initialiser")
    
    
    
    
    
    
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
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(colourScheme == .light ? .black : nil)
                    .offset(y: 45)
                } else if stopWatchManager.inspectionSecs >= 15 {
                    Text("+2")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(colourScheme == .light ? .black : nil)
                    .offset(y: 45)
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
                    // for smaller phones (iPhoneSE and test sim), disable animation to larger text
                    // to prevent text clipping and other UI problems
                    .if(!(smallDeviceNames.contains(getModelName()))) { view in
                        view
                            .modifier(AnimatingFontSize(fontSize: stopWatchManager.mode == .running ? 70 : 56))
                            .modifier(DynamicText())
                            .animation(Animation.spring(), value: stopWatchManager.mode == .running)
                    }
                    .if(smallDeviceNames.contains(getModelName())) { view in
                        view
                            .font(.system(size: 54, weight: .bold, design: .monospaced))
                            .modifier(DynamicText())
                    }
                    
                
                Spacer()
            }
            .ignoresSafeArea(edges: .all)
            .ignoresSafeArea(.keyboard)
            
            
            switch inputMode {
            // ONLY USE GESTURE RECOGNISER WHEN INPUTMODE SET TO TIMER
            case .timer:
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
                
            // FOR TYPING, DISPLAY INPUT BOX ALWAYS; USE GESTURE TO ESCAPE FOCUS
            case .typing:
                Color.white.opacity(0.000001)
                    .onTapGesture {
                        manualInputFocused = false
                    }
            }
            
           
            
            
            // VIEWS WHEN TIMER NOT RUNNING
            if !tabRouter.hideTabBar {
                VStack {
                    HStack {
                        if !useExtendedView {
                            TimerHeader(targetFocused: $targetFocused, previewMode: false)
                                .padding(.leading)
                                .padding(.trailing, 24)
                        } else {
                            FloatingPanel(
                                currentStage: $floatingPanelStage,
                                maxHeight: (UIScreen.screenHeight - 80),
                                stages: [0, 50, 125, (UIScreen.screenHeight - 80)],
                                content: {
                                    EmptyView()
                                    
                                    TimerHeader(targetFocused: $targetFocused, previewMode: false)
                                    
//                                    EmptyView()
                                    VStack(alignment: .leading, spacing: 0) {
                                        TimerHeader(targetFocused: $targetFocused, previewMode: false)
                                            .padding(.top)
                                            .padding(.bottom, 8)
                                        
                                        PrevSolvesDisplay(count: 3)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
//                                    EmptyView()
                                    VStack(alignment: .leading, spacing: 0) {
                                        TimerHeader(targetFocused: $targetFocused, previewMode: false)
                                            .padding(.horizontal)
                                            .padding(.vertical)
                                        
                                        MainTabsView(useExtendedView: true)
                                            .frame(maxHeight: UIScreen.screenHeight - 80 - 35 - 16*2)
                                        
                                    }
                                }
                            )
                            .ignoresSafeArea(.keyboard)
                            .frame(width: 360)
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 0)
                            .padding(.top, SetValues.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                            .padding(.leading)
                        }
                        
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    // GEO READER FOR BOTTOM TOOLS
                    GeometryReader { geometry in
                        
                            
                        let maxHeight: CGFloat = 120
                        let maxWidth: CGFloat = geometry.size.width - 12 - UIScreen.screenWidth/2
                                                
                        ZStack(alignment: .bottom) {
                            // SCRAMBLE VIEW
                            if showScramble {
                                HStack {
                                    ZStack(alignment: .bottomLeading) {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color(uiColor: .systemGray5))
                                            .frame(width: maxWidth, height: maxHeight)
                                        
                                        // this whole thing is magic
                                        
                                        // i don't know why it works
                                        // i don't know if or why passing in a width and height to uikit works
                                        // using a really small value (width: 10) seems to force views into the frame?
                                        // but using its ideal width/height does nothing
                                        // frame does not set the size for the scrambleview (seems to work for just nxns)
                                        // for for squan/mega/etc, the scramble is ridiculously large
                                        
                                        // it seems to do with uiviewrepresentable, and not being able to set master bounds
                                        // from swiftui, as swiftui uses its own autolayout, essentially overriding any config of the bound sizes from within uikit itself
                                        
                                        // if you know how to fix this, please make a pull request
                                        if let svg = stopWatchManager.scrambleSVG {
                                            if let scr = stopWatchManager.scrambleStr {
                                                DefaultScrambleView(svg: svg, width: 10, height: 120 / 3) // i'm not touching this, it works
                                                    .aspectRatio(contentMode: .fit)
                                                    .padding(.all, 2)
                                                    .frame(maxWidth: maxWidth - 4, maxHeight: 116)
                                                    .offset(x: 1, y: -2.5)
                                                
                                                    .onTapGesture {
                                                        scrambleSheetStr = SheetStrWrapper(str: scr)
                                                    }
                                            }
                                        } else {
                                            LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                                                .frame(width: maxWidth - 4, height: maxHeight - 4)
                                            
                                            /*
                                            ProgressView()
                                                .frame(width: maxWidth - 4, height: maxHeight - 4)
                                             */
                                        }
                                    }
                                    .frame(maxWidth: maxWidth)
                                    
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
                                                // ao5
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
                                                    if stopWatchManager.currentAo5 != nil {
                                                        presentedAvg = stopWatchManager.currentAo5
                                                    }
                                                }
                                                
                                                // ao12
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
                                                    if stopWatchManager.currentAo12 != nil {
                                                        presentedAvg = stopWatchManager.currentAo12
                                                    }
                                                }
                                            }
                                            .padding(.top, 6)
                                            
                                            Divider()
                                                .frame(width: UIScreen.screenWidth/2 - 48)
                                            
                                            HStack(spacing: 0) {
                                                // ao100
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
                                                    if stopWatchManager.currentAo100 != nil {
                                                        presentedAvg = stopWatchManager.currentAo100
                                                    }
                                                }
                                                
                                                // mean
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
                                                // bpa
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
                                                
                                                // wpa
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
                                            
                                            // reach target
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
                                            .padding(.bottom, 6)
                                            .padding(.horizontal, 4)
                                            #warning("TODO: check if this is right")
                                            
                                        }
                                        .frame(width: windowSize!.width/2, height: 120)
                                    }
                                }
                            }
                        }
                    }
//                    .frame(idealWidth: UIScreen.screenWidth, maxWidth: UIScreen.screenWidth, idealHeight: 120, maxHeight: 120)
    //                .safeAreaInset(edge: .bottom, spacing: 0) {Rectangle().fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : 12)}
//                    .background(Color.pink)
                    .padding(.horizontal)
                    .frame(width: UIScreen.screenWidth, height: 120)
//                    .padding(.bottom, SetValues.hasBottomBar ? 0 : 12)
//                    .padding(.bottom, 12)
                    .offset(x: 0, y: -(50 + 12 + (SetValues.hasBottomBar ? 0 : 12))) // 50 for tab + 8 for padding + 16/0 for bottom bar gap
                }
            }
            
            // MANUAL ENTRY FIELD
            if inputMode == .typing || showInputField {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        if !showManualInputFormattedText {
                            TextField("0.00", text: $manualInputTime)
                                .focused($manualInputFocused)
                                .frame(maxWidth: windowSize!.width-32)
                                .font(.system(size: 56, weight: .bold, design: .monospaced))
                                .multilineTextAlignment(.center)
                                .foregroundColor(stopWatchManager.timerColour)
                                .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black))
                                .modifier(DynamicText())
                                .modifier(TimeMaskTextField(text: $manualInputTime))
                        } else {
                            Rectangle()
                                .fill(Color.white.opacity(0.000001))
                                .frame(maxWidth: windowSize!.width-32)
                                .onTapGesture {
                                    print("tapped")
                                    showManualInputFormattedText = false
                                    manualInputFocused = true
                                    
                                 
                                    if justManuallyInput {
                                        manualInputTime = ""
                                        justManuallyInput = false
                                    }
                                }
                        }
                        
                        Spacer()
                    }
                    
                        
                    Spacer()
                }
                .ignoresSafeArea(edges: .all)
            }
            
            
            // PENALTY BAR
            if inputMode == .typing || stopWatchManager.showPenOptions {
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
                            // IF USING TIMER MODE, ONE-TIME INPUT
                            if inputMode == .timer {
                                // only show divider if one-time entry
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
                                            // IF CURRENT MODE = INPUT
                                            if manualInputFocused {
                                                if manualInputTime != "" {
                                                    // record entered time time
                                                    stopWatchManager.stop(timeFromStr(manualInputTime))
                                                    
                                                    // remove focus and reset time
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
                            } else if inputMode == .typing && !justManuallyInput {
                                if manualInputTime != "" {
                                    PenaltyBar(68) {
                                        
                                        Button {
                                            stopWatchManager.stop(timeFromStr(manualInputTime))
                                            
                                            // remove focus and reset time
                                            manualInputFocused = false
                                            justManuallyInput = true
                                            
                                            stopWatchManager.displayPenOptions()
                                            
                                            showManualInputFormattedText = true
                                            
                                        } label: {
                                            Text("Done")
                                                .font(.system(size: 21, weight: .semibold, design: .rounded))
                                        }
                                    }
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
                    .offset(y: useExtendedView ? 0 : 35 + (SetValues.hasBottomBar ? 0 : 8))
                
                    
                } else {
                    HStack {
                        Spacer()
                        
                        VStack {
                            LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                                .frame(maxHeight: 35)
                                .padding(.trailing)
                                .padding(.top, SetValues.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                            
                            Spacer()
                        }
                    }
                    
                }
            }

            if stopWatchManager.mode == .inspecting && showCancelInspection {
                HStack(alignment: .center) {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        PenaltyBar(90) {
                            Button(action: {
                                stopWatchManager.interruptInspection()
                            }, label: {
                                Text("Cancel")
                                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                            })
                        }
                    }
                    
                    Spacer()
                }
                .offset(y: 45)
                .ignoresSafeArea(edges: .all)
            }
        }
        .confirmationDialog("Are you sure you want to delete this solve?", isPresented: $stopWatchManager.showDeleteSolveConfirmation, titleVisibility: .visible, presenting: $stopWatchManager.solveItem) { detail in
            Button("Confirm", role: .destructive) {
                managedObjectContext.delete(detail.wrappedValue!); #warning("TODO: delete this line?")
                stopWatchManager.delete(solve: detail.wrappedValue!)
                detail.wrappedValue = nil
                stopWatchManager.secondsElapsed = 0
//                stopWatchManager.secondsStr = formatSolveTime(secs: 0)
                stopWatchManager.secondsStr = formatSolveTime(secs: showPrevTime
                                                              ? (stopWatchManager.solvesByDate.last?.time ?? 0)
                                                              : 0)
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
        .sheet(item: $scrambleSheetStr) { str in
            TimeScrambleDetail(str.str, stopWatchManager.scrambleSVG)
        }
        .sheet(item: $presentedAvg) { item in
            StatsDetail(solves: item, session: stopWatchManager.currentSession); #warning("TODO: use SWM env object")
        }
        .onReceive(stopWatchManager.$mode) { newMode in
            tabRouter.hideTabBar = newMode == .inspecting || newMode == .running
            hideStatusBar = newMode == .inspecting || newMode == .running
        }
        .statusBar(hidden: hideStatusBar)
        .ignoresSafeArea(.keyboard)
        
        
        #warning("TODO: make animation asymmetric?")
    }
}


struct TimeScrambleDetail: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    var scramble: String
    var svg: String?
    @State var windowedScrambleSize: Int = UserDefaults.standard.integer(forKey: gsKeys.scrambleSize.rawValue)
    
    init(_ scramble: String, _ svg: String?) {
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
                    DefaultScrambleView(svg: svg, width: UIScreen.screenWidth / UIScreen.main.scale, height: UIScreen.screenHeight / 3 / UIScreen.main.scale)
                        .aspectRatio(contentMode: .fit)
                        .padding()
                } else {
                    LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .medium, speed: .normal)
                    
//                    ProgressView()
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
