import CoreData
import SwiftUI
import CoreGraphics
import Combine
import SwiftfulLoadingIndicators
import SVGView


struct SheetStrWrapper: Identifiable {
    let id = UUID()
    let str: String
}



struct TimerTime: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller
    @Environment(\.colorScheme) var colourScheme
    
    @inlinable func getTimerColor() -> Color {
        #warning("move this to timer controller?")
        if timerController.mode == .inspecting && colourScheme == .dark && timerController.timerColour == Color.Timer.normal {
            switch timerController.inspectionSecs {
            case ..<8: return Color.Timer.normal
            case 8..<12: return Color(uiColor: .systemYellow)
            case 12..<15: return Color(uiColor: .systemOrange)
            default: return Color(uiColor: .systemRed)
            }
        } else {
            return timerController.timerColour
        }
    }
    
    var body: some View {
        #warning("move this to timer controller?")
        Text(timerController.secondsStr
             + (timerController.mode == .inspecting
                ? ((timerController.inspectionSecs >= 17
                    ? "(DNF)"
                    : (timerController.inspectionSecs >= 15
                       ? "(+2)"
                       : "")))
                : ""))
        .foregroundColor(getTimerColor())
        .modifier(DynamicText())
        // for smaller phones (iPhoneSE and test sim), disable animation to larger text
        // to prevent text clipping and other UI problems
        .ifelse (stopwatchManager.isSmallDevice) { view in
            return view
                .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDescBold, 54, nil)))
        } elseDo: { view in
            return view
                .modifier(AnimatingFontSize(font: stopwatchManager.ctFontDescBold, fontSize: timerController.mode == .running ? 70 : 56))
                .animation(Animation.customBouncySpring, value: timerController.mode == .running)
        }
    }
}


struct TimerBackgroundColor: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller
    
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        if timerController.mode == .inspecting && colourScheme == .light {
            switch timerController.inspectionSecs {
            case 8..<12:
                Color.Inspection.eight
                    .ignoresSafeArea()
            case 12..<15:
                Color.Inspection.twelve
                    .ignoresSafeArea()
            case let x where x >= 15:
                Color.Inspection.penalty
                    .ignoresSafeArea()
            default:
                Color("base")
            }
        } else {
            Color("base")
        }
    }
}


enum TimerTool {
    case drawScramble
    case statsCompsim
    case statsStandard
}

struct BottomTools: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @AppStorage(gsKeys.showScramble.rawValue) private var showScramble: Bool = true
    @AppStorage(gsKeys.showStats.rawValue) private var showStats: Bool = true
    
    let timerSize: CGSize
    @Binding var scrambleSheetStr: SheetStrWrapper?
    @Binding var presentedAvg: CalculatedAverage?
    
    
    var body: some View {
        HStack(alignment: .bottom) {
            if showScramble {
                BottomTool(toolType: .drawScramble, parentGeo: timerSize, scrambleSheetStr: $scrambleSheetStr)
            }
            
            if showScramble && showStats {
                Spacer()
            }
            
            if showStats {
                BottomTool(toolType: SessionTypes(rawValue: stopwatchManager.currentSession.session_type)! != .compsim
                           ? .statsStandard
                           : .statsCompsim,
                           parentGeo: timerSize,
                           presentedAvg: $presentedAvg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .safeAreaInset(safeArea: .tabBar)
        .padding(.horizontal)
    }
}

struct BottomToolBG: View {
    let maxHeight: CGFloat
    let maxWidth: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color("overlay0"))
            .frame(width: maxWidth, height: maxHeight)
    }
}

struct BottomTool: View {
    @Environment(\.colorScheme) private var colourScheme
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Binding var scrambleSheetStr: SheetStrWrapper?
    @Binding var presentedAvg: CalculatedAverage?
    
    
    let toolType: TimerTool
    let maxHeight: CGFloat
    let maxWidth: CGFloat
    
    init(toolType: TimerTool,
         parentGeo: CGSize,
         scrambleSheetStr: Binding<SheetStrWrapper?>?=nil,
         presentedAvg: Binding<CalculatedAverage?>?=nil) {
        self._scrambleSheetStr = scrambleSheetStr ?? Binding.constant(nil)
        self._presentedAvg = presentedAvg ?? Binding.constant(nil)
        self.toolType = toolType
        self.maxHeight = 120
        self.maxWidth = min(((parentGeo.width - 32) / 2), 170)
    }
    
    
    var body: some View {
        ZStack {
            BottomToolBG(maxHeight: maxHeight, maxWidth: maxWidth)
            
            switch toolType {
            case .drawScramble:
                if let svg = stopwatchManager.scrambleSVG {
                    if let scr = stopwatchManager.scrambleStr {
                        SVGView(string: svg)
                            .padding(2)
                            .frame(width: maxWidth, height: maxHeight)
                            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                scrambleSheetStr = SheetStrWrapper(str: scr)
                            }
                    }
                } else {
                    LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                        .frame(width: maxWidth, height: maxHeight, alignment: .center)
                }
                
            case .statsStandard:
                VStack(spacing: 6) {
                    HStack(spacing: 0) {
                        // ao5
                        VStack(spacing: 0) {
                            Text("AO5")
                                .font(.system(size: 13, weight: .medium))
                            
                            if let currentAo5 = stopwatchManager.currentAo5 {
                                Text(formatSolveTime(secs: currentAo5.average!, penType: currentAo5.totalPen))
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: maxWidth/2-8)
                                    .modifier(DynamicText())
                            } else {
                                Text("-")
                                    .font(.system(size: 24, weight: .medium, design: .default))
                                    .foregroundColor(Color("grey"))
                            }
                            
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .onTapGesture {
                            if stopwatchManager.currentAo5 != nil {
                                presentedAvg = stopwatchManager.currentAo5
                            }
                        }
                        
                        // ao12
                        VStack(spacing: 0) {
                            Text("AO12")
                                .font(.system(size: 13, weight: .medium))
                            
                            if let currentAo12 = stopwatchManager.currentAo12 {
                                Text(formatSolveTime(secs: currentAo12.average!, penType: currentAo12.totalPen))
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: maxWidth/2-8)
                                    .modifier(DynamicText())
                            } else {
                                Text("-")
                                    .font(.system(size: 24, weight: .medium, design: .default))
                                    .foregroundColor(Color("grey"))
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .onTapGesture {
                            if stopwatchManager.currentAo12 != nil {
                                presentedAvg = stopwatchManager.currentAo12
                            }
                        }
                    }
                    
                    Divider()
                        .frame(width: maxWidth - 48)
                    
                    HStack(spacing: 0) {
                        // ao100
                        VStack(spacing: 0) {
                            Text("AO100")
                                .font(.system(size: 13, weight: .medium))
                            
                            if let currentAo100 = stopwatchManager.currentAo100 {
                                Text(formatSolveTime(secs: currentAo100.average!, penType: currentAo100.totalPen))
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: maxWidth/2-8)
                                    .modifier(DynamicText())
                            } else {
                                Text("-")
                                    .font(.system(size: 24, weight: .medium, design: .default))
                                    .foregroundColor(Color("grey"))
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .onTapGesture {
                            if stopwatchManager.currentAo100 != nil {
                                presentedAvg = stopwatchManager.currentAo100
                            }
                        }
                        
                        // mean
                        VStack(spacing: 0) {
                            Text("MEAN")
                                .font(.system(size: 13, weight: .medium))
                            
                            if let sessionMean = stopwatchManager.sessionMean {
                                Text(formatSolveTime(secs: sessionMean))
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: maxWidth/2-8)
                                    .modifier(DynamicText())
                            } else {
                                Text("-")
                                    .font(.system(size: 24, weight: .medium, design: .default))
                                    .foregroundColor(Color("grey"))
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
                .frame(width: maxWidth, height: maxHeight)
                
                
                
                
                
            case .statsCompsim:
                VStack(spacing: 6) {
                    HStack {
                        // bpa
                        VStack(spacing: 0) {
                            Text("BPA")
                                .font(.system(size: 13, weight: .medium))
                            
                            if let bpa = stopwatchManager.bpa {
                                Text(formatSolveTime(secs: bpa))
                                    .font(.system(size: 24, weight: .bold))
                                    .frame(maxWidth: maxWidth/2-8)
                                    .modifier(DynamicText())
                            } else {
                                Text("...")
                                    .font(.system(size: 24, weight: .medium, design: .default))
                                    .foregroundColor(Color("grey"))
                            }
                            
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        
                        // wpa
                        VStack(spacing: 0) {
                            Text("WPA")
                                .font(.system(size: 13, weight: .medium))
                            
                            if let wpa = stopwatchManager.wpa {
                                if wpa == -1 {
                                    Text("DNF")
                                        .font(.system(size: 24, weight: .bold))
                                        .modifier(DynamicText())
                                } else {
                                    Text(formatSolveTime(secs: wpa))
                                        .font(.system(size: 24, weight: .bold))
                                        .frame(maxWidth: maxWidth/2-8)
                                        .modifier(DynamicText())
                                }
                                
                                
                                
                            } else {
                                Text("...")
                                    .font(.system(size: 24, weight: .medium, design: .default))
                                    .foregroundColor(Color("grey"))
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    
                    Divider()
                        .frame(width: maxWidth - 48)
                    
                    // reach target
                    VStack(spacing: 0) {
                        Text("TO REACH TARGET")
                            .font(.system(size: 13, weight: .medium))
                        
                        if let timeNeededForTarget = stopwatchManager.timeNeededForTarget {
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
                                    .foregroundColor(Color("grey"))
                            }
                        }
                    }
                }
            }
        }
        .frame(width: maxWidth, height: maxHeight)
    }
}


let padFloatingLayout = true


struct ScrambleText: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    let scr: String
    var timerSize: CGSize
    @Binding var scrambleSheetStr: SheetStrWrapper?
    
    
    var body: some View {
        let mega: Bool = stopwatchManager.currentSession.scramble_type == 7
        
        Text(scr)
            .font(stopwatchManager.ctFontScramble)
            .fixedSize(horizontal: mega, vertical: false)
            .multilineTextAlignment(mega ? .leading : .center)
            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
            .textSelection(.enabled)

            .if(mega) { view in
                view.minimumScaleFactor(0.00001).scaledToFit()
            }
            .frame(maxWidth: timerSize.width, maxHeight: timerSize.height/3)
            .onTapGesture {
                scrambleSheetStr = SheetStrWrapper(str: scr)
            }
            .padding(.horizontal)
            .padding(.leading, 0)
            .offset(y: 35 + (SetValues.hasBottomBar ? 0 : 8))
    }
}

struct TimerView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller
    @EnvironmentObject var tabRouter: TabRouter
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    // GET USER DEFAULTS
    @AppStorage("onboarding") var showOnboarding: Bool = true
    @AppStorage(gsKeys.showCancelInspection.rawValue) private var showCancelInspection: Bool = true
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @AppStorage(asKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
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
    
    
    
#warning("TODO: find a way to not use an initialiser")
    
    
    var body: some View {
        let typingMode = inputMode == .typing && stopwatchManager.currentSession.session_type != SessionTypes.multiphase.rawValue
        
        GeometryReader { geo in
            TimerBackgroundColor()
                .ignoresSafeArea(.all)
            
            
            if typingMode || targetFocused || manualInputFocused {
                Color.white.opacity(0.000001)
                    .onTapGesture {
                        if inputMode == .timer {
                            manualInputFocused = false
                            targetFocused = false
                            showInputField = false
                        } else {
                            if showManualInputFormattedText {
                                showManualInputFormattedText = false
                                manualInputFocused = true
                                
                                
                                if justManuallyInput {
                                    manualInputTime = ""
                                    justManuallyInput = false
                                }
                            } else {
                                manualInputFocused = false
                            }
                        }
                    }
            } else {
                TimerTouchView()
            }
            
            
            if !((typingMode || showInputField) && !showManualInputFormattedText) {
                VStack(alignment: .center, spacing: 0) {
                    TimerTime()
                        .allowsHitTesting(false)
                    
                    if timerController.mode == .inspecting && showCancelInspection {
                        PenaltyBar(90) {
                            Button {
                                timerController.interruptInspection()
                            } label: {
                                Text("Cancel")
                                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            }
            
            
            if (typingMode || showInputField) && !showManualInputFormattedText {
                Group {
                    TextField("0.00", text: $manualInputTime)
                        .focused($manualInputFocused)
                        .frame(maxWidth: geo.size.width-32)
                        .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDescBold, 56, nil)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(timerController.timerColour)
                        .background(Color("bg"))
                        .modifier(DynamicText())
                        .modifier(TimeMaskTextField(text: $manualInputTime))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            }
            
            if timerController.mode == .stopped {
                BottomTools(timerSize: geo.size, scrambleSheetStr: $scrambleSheetStr, presentedAvg: $presentedAvg)
                
                // 50 for tab + 8 for padding + 16/0 for bottom bar gap
                
                
                HStack(alignment: .top, spacing: 6) {
                    TimerHeader(targetFocused: $targetFocused, previewMode: false)
                    
                    Spacer()
                    
                    LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                        .frame(maxHeight: 35)
                        .padding(.top, SetValues.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                        .opacity(stopwatchManager.scrambleStr == nil ? 1 : 0)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                
                
                if let scr = stopwatchManager.scrambleStr {
                    ScrambleText(scr: scr, timerSize: geo.size, scrambleSheetStr: $scrambleSheetStr)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            
            
            if stopwatchManager.scrambleStr != nil && (typingMode || stopwatchManager.showPenOptions) {
                HStack {
                    let showPlus = stopwatchManager.currentSession.session_type != SessionTypes.multiphase.rawValue && !justManuallyInput && (inputMode != .typing || manualInputTime != "")
                    
                    if stopwatchManager.solveItem != nil && !manualInputFocused {
                        PenaltyBar(122) {
                            HStack {
                                PenaltyButton(penType: .plustwo, penSymbol: "+2", imageSymbol: true, canType: false, colour: Color.yellow)
                                
                                PenaltyButton(penType: .dnf, penSymbol: "xmark.circle", imageSymbol: false, canType: false, colour: Color.red)
                                    .frame(maxWidth: .infinity)
                                
                                PenaltyButton(penType: .none, penSymbol: "checkmark.circle", imageSymbol: false, canType: false, colour: Color.green)
                            }
                            // I don't know why there has to be uneven padding :(
                            .padding(.leading, 4)
                            .padding(.trailing, 1)
                        }
                        
                        if showPlus {
                            Rectangle()
                                .fill(Color("indent1"))
                                .frame(width: 1.5, height: 20)
                                .padding(.horizontal, 12)
                        }
                    }
                    
                    
                    if showPlus {
                        if !typingMode {
                            PenaltyBar(manualInputFocused ? 68 : 34) {
                                Button {
                                    // IF CURRENT MODE = INPUT
                                    if manualInputFocused {
                                        if manualInputTime != "" {
                                            // record entered time time
                                            timerController.stop(timeFromStr(manualInputTime))
                                            
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
                                } label: {
                                    if manualInputFocused {
                                        Text("Done")
                                            .font(.system(size: 21, weight: .semibold, design: .rounded))
                                    } else {
                                        Image(systemName: "plus.circle")
                                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    }
                                }
                                .disabled(manualInputFocused ? (manualInputTime == "") : false)
                            }
                        } else if typingMode {
                            PenaltyBar(68) {
                                Button {
                                    timerController.stop(timeFromStr(manualInputTime))
                                    
                                    // remove focus and reset time
                                    manualInputFocused = false
                                    justManuallyInput = true
                                    
                                    stopwatchManager.displayPenOptions()
                                    
                                    showManualInputFormattedText = true
                                    
                                } label: {
                                    Text("Done")
                                        .font(.system(size: 21, weight: .semibold, design: .rounded))
                                }
                            }
                        }
                    }
                }
                .disabled(stopwatchManager.scrambleStr == nil)
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: 45)
            }
            
            
        }
        .confirmationDialog("Are you sure you want to delete this solve?", isPresented: $stopwatchManager.showDeleteSolveConfirmation, titleVisibility: .visible, presenting: $stopwatchManager.solveItem) { detail in
            Button("Confirm", role: .destructive) {
                managedObjectContext.delete(detail.wrappedValue!); #warning("TODO: delete this line?")
                stopwatchManager.delete(solve: detail.wrappedValue!)
                detail.wrappedValue = nil
                timerController.secondsElapsed = 0
                //                stopwatchManager.secondsStr = formatSolveTime(secs: 0)
                timerController.secondsStr = formatSolveTime(secs: showPrevTime
                                                              ? (stopwatchManager.solvesByDate.last?.time ?? 0)
                                                              : 0)
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
        .sheet(item: $scrambleSheetStr) { str in
            TimeScrambleDetail(str.str, stopwatchManager.scrambleSVG)
        }
        .sheet(item: $presentedAvg) { item in
            StatsDetail(solves: item, session: stopwatchManager.currentSession); #warning("TODO: use SWM env object")
        }
        .onReceive(timerController.$mode) { newMode in
            tabRouter.hideTabBar = newMode == .inspecting || newMode == .running
            hideStatusBar = newMode == .inspecting || newMode == .running
        }
        .statusBar(hidden: hideStatusBar)
        .ignoresSafeArea(.keyboard)
    }
}


struct TimeScrambleDetail: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.dismiss) var dismiss
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    var scramble: String
    var svg: String?
    @State var windowedScrambleSize: Int = UserDefaults.standard.integer(forKey: asKeys.scrambleSize.rawValue)
    
    init(_ scramble: String, _ svg: String?) {
        self.scramble = scramble
        self.svg = svg
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    ScrollView {
                        Text(scramble)
                            .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDesc, CGFloat(windowedScrambleSize), nil)))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    
                    if let svg = svg {
                        SVGView(string: svg)
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300)
                            .padding(.horizontal, geo.size.width * 0.1)
                            .padding(.vertical)
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
                    
                    ToolbarItem(placement: .confirmationAction) {
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
}
