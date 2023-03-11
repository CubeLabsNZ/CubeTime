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
                .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, 70, nil)))
                .scaleEffect(timerController.mode == .running ? 1 : (56/70))
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
                
            case 12..<15:
                Color.Inspection.twelve
                
            case let x where x >= 15:
                Color.Inspection.penalty
            default:
                Color("base")
            }
        } else {
            Color("base")
        }
    }
}



struct AvoidFloatingPanel: ViewModifier {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller

    
    func body(content: Content) -> some View {
        let condition = stopwatchManager.currentPadFloatingStage == 2 && timerController.mode == .stopped
        
        content
            .padding(.leading, condition ? 360 : 0)
            .padding(.leading, condition ? nil : 0)
    }
}


struct ScrambleText: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
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
            .frame(maxWidth: timerSize.width,
                   maxHeight: timerSize.height/3)
            .onTapGesture {
                scrambleSheetStr = SheetStrWrapper(str: scr)
            }
            .padding(.horizontal)
            .offset(y: 35 + (UIDevice.hasBottomBar ? 0 : 8) + ((UIDevice.deviceIsPad && hSizeClass == .regular) ? 50 : 0))
            .modifier(AvoidFloatingPanel())
    }
}


struct TimerView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var scrambleController: ScrambleController
    @EnvironmentObject var tabRouter: TabRouter
    
    @StateObject var gm = GradientManager()
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @Environment(\.dismiss) var dismiss

    
    // GET USER DEFAULTS
    @AppStorage("onboarding") var showOnboarding: Bool = true
    @Preference(\.showCancelInspection) private var showCancelInspection
    @Preference(\.scrambleSize) private var scrambleSize
    @Preference(\.showPrevTime) private var showPrevTime
    @Preference(\.inputMode) private var inputMode
    
    
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
    
    @State private var showSessions: Bool = false
    
    #warning("TODO: find a way to not use an initialiser")
    
    
    var body: some View {
        let typingMode = inputMode == .typing && stopwatchManager.currentSession.session_type != SessionType.multiphase.rawValue
        
        GeometryReader { geo in
            TimerBackgroundColor()
                .ignoresSafeArea()
            
            
            if typingMode || targetFocused || manualInputFocused {
                Color.white.opacity(0.0001)
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
                        
                        stopwatchManager.showPenOptions = false
                    }
            } else {
                TimerTouchView()
            }
            
            
            if !((typingMode || showInputField) && !showManualInputFormattedText) {
                VStack(alignment: .center, spacing: 0) {
                    TimerTime()
                        .modifier(AvoidFloatingPanel())
                        .allowsHitTesting(false)
                    
                    if timerController.mode == .inspecting && showCancelInspection {
                        HierarchicalButton(type: .mono, size: .medium, onTapRun: {
                            timerController.interruptInspection()
                        }) {
                            Text("Cancel")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea()
            }
            
            
            if (typingMode || showInputField) && !showManualInputFormattedText {
                TextField("0.00", text: $manualInputTime)
                    .focused($manualInputFocused)
                    .frame(maxWidth: geo.size.width-32)
                    .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, 56, nil)))
                    .multilineTextAlignment(.center)
                    .foregroundColor(timerController.timerColour)
                    .background(Color("base"))
                    .modifier(DynamicText())
                    .modifier(TimeMaskTextField(text: $manualInputTime))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .ignoresSafeArea()
            }
            
            if !stopwatchManager.hideUI {
                BottomTools(timerSize: geo.size, scrambleSheetStr: $scrambleSheetStr, presentedAvg: $presentedAvg)
                    .modifier(AvoidFloatingPanel())
                
                // 50 for tab + 8 for padding + 16/0 for bottom bar gap
                
                let stageMaxHeight: CGFloat = geo.size.height-CGFloat(50)
                let stages: [CGFloat] = [35, 35+16+55, stageMaxHeight]
                
                if (UIDevice.deviceIsPad && hSizeClass == .regular) {
                    HStack(alignment: .top) {
                        FloatingPanel(currentStage: $stopwatchManager.currentPadFloatingStage, maxHeight: stageMaxHeight, stages: stages) {
                            PadTimerHeader(targetFocused: self.$targetFocused, showSessions: nil)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                PadTimerHeader(targetFocused: self.$targetFocused, showSessions: nil)
                                
                                PrevSolvesDisplay(count: 3)
                                    .padding(.horizontal, 8)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                PadTimerHeader(targetFocused: self.$targetFocused, showSessions: $showSessions)
                                
                                if (self.showSessions) {
                                    SessionsView()
                                } else {
                                    TimeListView()
                                }
                            }
                        }
                        
                        Spacer()
                        
                        TimerMenu()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    .zIndex(3)
                } else {
                    HStack(alignment: .top, spacing: 6) {
                        TimerHeader(targetFocused: $targetFocused, previewMode: false)
                        
                        Spacer()
                        
                        LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
                            .frame(maxHeight: 35)
                            .padding(.top, UIDevice.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                            .opacity(scrambleController.scrambleStr == nil ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal)
                    .zIndex(3)
                }
            }
            
            if stopwatchManager.zenMode {
                CloseButton(hasBackgroundShadow: true, onTapRun: {
                    withAnimation(.customEaseInOut) {
                        stopwatchManager.zenMode = false
                    }
                })
                .padding([.trailing, .top])
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            
            
            if let scr = scrambleController.scrambleStr, timerController.mode == .stopped {
                ScrambleText(scr: scr, timerSize: geo.size, scrambleSheetStr: $scrambleSheetStr)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            
            
            if scrambleController.scrambleStr != nil && (typingMode || stopwatchManager.showPenOptions) {
                HStack {
                    let showPlus = stopwatchManager.currentSession.session_type != SessionType.multiphase.rawValue && !justManuallyInput && (inputMode != .typing || manualInputTime != "")
                    
                    
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
                .modifier(AvoidFloatingPanel())
                .disabled(scrambleController.scrambleStr == nil)
                .ignoresSafeArea()
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
        .sheet(item: $scrambleSheetStr, onDismiss: {
            scrambleSheetStr = nil
            dismiss()
        }) { str in
            #warning("crashes if you PULL DOWN on one sheet presented by draw scramble and quickly tap on scramble text")
            TimeScrambleDetail(binding: $scrambleSheetStr, str.str, scrambleController.scrambleSVG)
                .tint(Color("accent"))
        }
        .sheet(item: $presentedAvg, onDismiss: {
            self.presentedAvg = nil
        }) { item in
            StatsDetailView(solves: item, session: stopwatchManager.currentSession)
                .tint(Color("accent"))
            
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
    
    @Binding var scramble: SheetStrWrapper?
    
    var scrambleString: String
    var svg: String?
    @State var windowedScrambleSize: Int = SettingsManager.standard.scrambleSize
    
    init(binding: Binding<SheetStrWrapper?>, _ scrambleString: String, _ svg: String?) {
        self._scramble = binding
        self.scrambleString = scrambleString
        self.svg = svg
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                VStack {
                    ScrollView {
                        Text(scrambleString)
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
                        LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .medium, speed: .normal)
                    }
                }
                .frame(maxWidth: .infinity)
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
                                    .foregroundColor(Color("accent"))
                            }
                            
                            
                            Button {
                                windowedScrambleSize += 1
                            } label: {
                                Image(systemName: "textformat.size.larger")
                                    .font(.system(size: 17, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("accent"))
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        DoneButton(onTapRun: {
                            dismiss()
                            scramble = nil
                        })
                    }
                }
            }
        }
    }
}
