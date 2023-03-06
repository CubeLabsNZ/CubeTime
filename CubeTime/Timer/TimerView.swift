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
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var timerController: TimerContoller
    @Environment(\.colorScheme) var colourScheme
    
    @inlinable func getTimerColor() -> Color {
#warning("move this to timer controller?")
        if timerController.mode == .inspecting && colourScheme == .dark && timerController.timerColour == Color.Timer.normal {
            switch timerController.inspectionSecs {
            case ..<8: return Color.Timer.normal
            case 8..<12: return Color("yellow")
            case 12..<15: return Color("orange")
            default: return Color("red")
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
                .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, 54, nil)))
        } elseDo: { view in
            return view
                .modifier(AnimatingFontSize(font: fontManager.ctFontDescBold, fontSize: timerController.mode == .running ? 70 : 56))
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
    @AppStorage(generalSettingsKey.showScramble.rawValue) private var showScramble: Bool = true
    @AppStorage(generalSettingsKey.showStats.rawValue) private var showStats: Bool = true
    
    let timerSize: CGSize
    @Binding var scrambleSheetStr: SheetStrWrapper?
    @Binding var presentedAvg: CalculatedAverage?
    
    
    var body: some View {
        HStack(alignment: .bottom) {
            if showScramble {
                BottomToolContainer {
                    TimerDrawScramble(scrambleSheetStr: $scrambleSheetStr)
                }
            }
            
            if showScramble && showStats {
                Spacer()
            }
            
            if showStats {
                BottomToolContainer {
                    Group {
                        if stopwatchManager.currentSession.session_type == SessionTypes.compsim.rawValue {
                            TimerStatsCompSim()
                        } else {
                            TimerStatsStandard(presentedAvg: $presentedAvg)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .safeAreaInset(safeArea: .tabBar)
        .padding(.horizontal)
    }
}

struct BottomToolBG: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color("overlay0"))
    }
}


struct BottomToolContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("overlay0"))
            
            content
        }
        .frame(maxWidth: 170)
        .frame(height: 120)
    }
}

struct TimerDrawScramble: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Binding var scrambleSheetStr: SheetStrWrapper?
    
    var body: some View {
        GeometryReader { geo in
            if let svg = stopwatchManager.scrambleSVG {
                if let scr = stopwatchManager.scrambleStr {
                    SVGView(string: svg)
                        .padding(2)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: geo.size.width, height: geo.size.height) // For some reason above doesnt work
                        .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            scrambleSheetStr = SheetStrWrapper(str: scr)
                        }
                }
            } else {
                LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
    }
}


struct TimerStatRaw: View {
    let name: String
    let value: String?
    let placeholderText: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(name)
                .font(.system(size: 13, weight: .medium))
            
            if let value = value {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .modifier(DynamicText())
            } else {
                Text(placeholderText)
                    .font(.system(size: 24, weight: .medium, design: .default))
                    .foregroundColor(Color("grey"))
            }
            
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct TimerStat: View {
    let name: String
    let average: CalculatedAverage?
    let value: String?
    let placeholderText: String
    @Binding var presentedAvg: CalculatedAverage?

    init(name: String, average: CalculatedAverage?, placeholderText: String = "-", presentedAvg: Binding<CalculatedAverage?>) {
        self.name = name
        self.average = average
        self.placeholderText = placeholderText
        self._presentedAvg = presentedAvg
        if let average = average {
            self.value = formatSolveTime(secs: average.average!, penType: average.totalPen)
        } else {
            self.value = nil
        }
    }

    var body: some View {
        TimerStatRaw(name: name, value: value, placeholderText: placeholderText)
            .onTapGesture {
                if average != nil {
                    presentedAvg = average
                }
            }
    }
}

struct TimerStatsStandard: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Binding var presentedAvg: CalculatedAverage?
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                TimerStat(name: "AO5", average: stopwatchManager.currentAo5, presentedAvg: $presentedAvg)
                TimerStat(name: "AO12", average: stopwatchManager.currentAo12, presentedAvg: $presentedAvg)
            }
            
            Divider()
                .padding(.horizontal, 24)
            
            
            HStack(spacing: 0) {
                TimerStat(name: "AO100", average: stopwatchManager.currentAo5, presentedAvg: $presentedAvg)
                TimerStatRaw(name: "MEAN", value: stopwatchManager.sessionMean == nil ? nil : formatSolveTime(secs: stopwatchManager.sessionMean!), placeholderText: "-")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TimerStatsCompSim: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager

    
    var body: some View {
        let timeNeededText: String? = {
            if let timeNeededForTarget = stopwatchManager.timeNeededForTarget {
                switch timeNeededForTarget {
                case .notPossible:
                    return "Not Possible"
                case .guaranteed:
                    return "Guaranteed"
                case .value(let double):
                    return formatSolveTime(secs: double)
                }
            }
            return nil
        }()
    
        VStack(spacing: 6) {
            HStack {
                TimerStatRaw(name: "BPA", value: stopwatchManager.bpa == nil ? nil : formatSolveTime(secs: stopwatchManager.bpa!), placeholderText: "...")
                TimerStatRaw(name: "WPA", value: stopwatchManager.wpa == nil ? nil : formatSolveTime(secs: stopwatchManager.wpa!), placeholderText: "...")
            }
            
            Divider()
                .padding(.horizontal, 24)
            
            TimerStatRaw(name: "TO REACH TARGET", value: stopwatchManager.wpa == nil ? nil : formatSolveTime(secs: stopwatchManager.wpa!), placeholderText: "...")
        }
    }
}


struct ScrambleText: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    let scr: String
    var timerSize: CGSize
    @Binding var scrambleSheetStr: SheetStrWrapper?
    
    
    var body: some View {
        let mega: Bool = stopwatchManager.currentSession.scramble_type == 7
        
        Text(scr)
            .font(fontManager.ctFontScramble)
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
            .offset(y: 35 + (SetValues.hasBottomBar ? 0 : 8))
    }
}

struct TimerView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var scrambleController: ScrambleController
    @EnvironmentObject var tabRouter: TabRouter
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    // GET USER DEFAULTS
    @AppStorage("onboarding") var showOnboarding: Bool = true
    @AppStorage(generalSettingsKey.showCancelInspection.rawValue) private var showCancelInspection: Bool = true
    @AppStorage(appearanceSettingsKey.scrambleSize.rawValue) private var scrambleSize: Int = 18
    @AppStorage(generalSettingsKey.showPrevTime.rawValue) private var showPrevTime: Bool = false
    @AppStorage(generalSettingsKey.inputMode.rawValue) private var inputMode: InputMode = .timer
    
    
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
                        HierarchialButton(type: .mono, size: .medium, onTapRun: {
                            timerController.interruptInspection()
                        }) {
                            Text("Cancel")
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
                        .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, 56, nil)))
                        .multilineTextAlignment(.center)
                        .foregroundColor(timerController.timerColour)
                        .background(Color("bg"))
                        .modifier(DynamicText())
                        .modifier(TimeMaskTextField(text: $manualInputTime))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            }
            
            if !stopwatchManager.hideUI {
                BottomTools(timerSize: geo.size, scrambleSheetStr: $scrambleSheetStr, presentedAvg: $presentedAvg)
                
                // 50 for tab + 8 for padding + 16/0 for bottom bar gap
                
                
                HStack(alignment: .top, spacing: 6) {
                    TimerHeader(targetFocused: $targetFocused, previewMode: false)
                    
                    Spacer()
                    
                    LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                        .frame(maxHeight: 35)
                        .padding(.top, SetValues.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                        .opacity(scrambleController.scrambleStr == nil ? 1 : 0)
                    
                    TimerMenu()
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .zIndex(3)
                
                
            }
            
            if stopwatchManager.zenMode {
                CloseButton(hasBackgroundShadow: true, onTapRun: {
                    stopwatchManager.zenMode = false
                })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            if let scr = scrambleController.scrambleStr, timerController.mode == .stopped {
                ScrambleText(scr: scr, timerSize: geo.size, scrambleSheetStr: $scrambleSheetStr)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            
            
            if scrambleController.scrambleStr != nil && (typingMode || stopwatchManager.showPenOptions) {
                HStack {
                    let showPlus = stopwatchManager.currentSession.session_type != SessionTypes.multiphase.rawValue && !justManuallyInput && (inputMode != .typing || manualInputTime != "")
                    
                    
                    PenaltyBar {
                        HStack(spacing: 12) {
                            if stopwatchManager.solveItem != nil && !manualInputFocused {
                                PenaltyButton(penType: .plustwo, penSymbol: "+2", imageSymbol: true, canType: false, colour: Color("orange"))
                                
                                PenaltyButton(penType: .dnf, penSymbol: "xmark.circle", imageSymbol: false, canType: false, colour: Color("red"))
                                    .frame(maxWidth: .infinity)
                                
                                PenaltyButton(penType: .none, penSymbol: "checkmark.circle", imageSymbol: false, canType: false, colour: Color("green"))
                                
                                if (showPlus) {
                                    ThemedDivider(isHorizontal: false)
                                        .padding(.vertical, 6)
                                }
                            }
                            if (showPlus) {
                                if !typingMode {
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
                                                .font(.body.weight(.medium))
                                                .padding(.horizontal, 8)
                                        } else {
                                            Image(systemName: "plus.circle")
                                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                        }
                                    }
                                    .disabled(manualInputFocused ? (manualInputTime == "") : false)
                                } else if typingMode {
                                    Button {
                                        timerController.stop(timeFromStr(manualInputTime))
                                        
                                        // remove focus and reset time
                                        manualInputFocused = false
                                        justManuallyInput = true
                                        
                                        stopwatchManager.displayPenOptions()
                                        
                                        showManualInputFormattedText = true
                                        
                                    } label: {
                                        Text("Done")
                                            .font(.body.weight(.medium))
                                            .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                    
                }
                .disabled(scrambleController.scrambleStr == nil)
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: 40)
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
            TimeScrambleDetail(str.str, scrambleController.scrambleSVG)
        }
        .sheet(item: $presentedAvg) { item in
            StatsDetailView(solves: item, session: stopwatchManager.currentSession)
            
#warning("TODO: use SWM env object")
        }
        .onReceive(stopwatchManager.$hideUI) { newValue in
            tabRouter.hideTabBar = newValue
        }
        .statusBar(hidden: stopwatchManager.hideUI)
        .ignoresSafeArea(.keyboard)
    }
}


struct TimeScrambleDetail: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    
    var scramble: String
    var svg: String?
    @State var windowedScrambleSize: Int = UserDefaults.standard.integer(forKey: appearanceSettingsKey.scrambleSize.rawValue)
    
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
                            .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDesc, CGFloat(windowedScrambleSize), nil)))
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
                                    .foregroundColor(Color.accentColor)
                            }
                            
                            
                            Button {
                                windowedScrambleSize += 1
                            } label: {
                                Image(systemName: "textformat.size.larger")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.accentColor)
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        DoneButton(onTapRun: {
                            dismiss()
                        })
                    }
                }
            }
        }
    }
}
