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
    @Environment(\.horizontalSizeClass) private var hSizeClass
    
    var body: some View {
        let fontSize: CGFloat = (UIDevice.deviceIsPad && hSizeClass == .regular)
            ? timerController.mode == .running ? 88 : 66
            : timerController.mode == .running ? 70 : 56
        
        HStack{
            Text(timerController.secondsStr)
                .modifier(DynamicText())
                // for smaller phones (iPhoneSE and test sim), disable animation to larger text
                // to prevent text clipping and other UI problems
                .ifelse (stopwatchManager.isSmallDevice) { view in
                    return view
                        .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, 54, nil)))
                } elseDo: { view in
                    return view
                        .modifier(AnimatingFontSize(font: fontManager.ctFontDescBold, fontSize: fontSize))
                }
            
            Group {
                if (timerController.mode == .inspecting) {
                    if (15..<17 ~= timerController.inspectionSecs) {
                        Text("[+2]")
                    } else if (timerController.inspectionSecs >= 17) {
                        Text("[DNF]")
                    }
                }
            }
            .modifier(AnimatingFontSize(font: fontManager.ctFontDescBold, fontSize: fontSize - 32))
        }
        .animation(Animation.customBouncySpring, value: timerController.mode == .running)
        .foregroundColor(timerController.timerColour)
    }
}


struct AvoidFloatingPanel: ViewModifier {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var timerController: TimerContoller
    @Environment(\.horizontalSizeClass) private var hSizeClass

    
    func body(content: Content) -> some View {
        let condition = stopwatchManager.currentPadFloatingStage == 2 && timerController.mode == .stopped
        
        content
            .padding(.leading, condition ? 360 : 0)
            .padding(.leading, condition ? nil : 0)
            .onChange(of: hSizeClass) { newValue in
                if (newValue == .compact) {
                    stopwatchManager.currentPadFloatingStage = 1
                }
            }
    }
}


struct ScrambleText: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var scrambleController: ScrambleController
    @EnvironmentObject var fontManager: FontManager
    let scr: String
    var timerSize: CGSize
    @Binding var scrambleSheetStr: SheetStrWrapper?
    
    
    var body: some View {
        let mega: Bool = stopwatchManager.currentSession.scrambleType == 7
        
        Text(scr)
            .padding(4)
            
            .background(Color("base"))
            .font(fontManager.ctFontScramble)
            .fixedSize(horizontal: mega, vertical: false)
            .multilineTextAlignment(mega ? .leading : .center)
            
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 4, style: .continuous))
            .contextMenu {
                if let scrambleString = scrambleController.scrambleStr {
                    Button {
                        copyScramble(scramble: scrambleString)
                    } label: {
                        Label("Copy Scramble", systemImage: "doc.on.doc")
                    }
                }
                
                if (stopwatchManager.isScrambleLocked) {
                    Button {
                        stopwatchManager.isScrambleLocked = false
                    } label: {
                        Label("Unlock Scramble", systemImage: "lock.rotation.open")
                    }
                } else {
                    Button {
                        stopwatchManager.isScrambleLocked = true
                    } label: {
                        Label("Lock Scramble", systemImage: "lock.rotation")
                    }
                }
            }
            
        
            .if(mega) { view in
                view.minimumScaleFactor(0.00001).scaledToFit()
            }
            .frame(maxWidth: timerSize.width,
                   maxHeight: timerSize.height/3)
        
            
        
            .onTapGesture {
                scrambleSheetStr = SheetStrWrapper(str: scr)
            }
            .offset(y: 35 + (UIDevice.hasBottomBar ? 0 : 8) + ((UIDevice.deviceIsPad && hSizeClass == .regular) ? 50 : 0))
            .padding(.horizontal)
            .modifier(AvoidFloatingPanel())
            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
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
    
    
    @State private var manualInputTime: String = ""
    @State private var showInputField: Bool = false
    @State private var toggleSessionName: Bool = false
    
    // scramble sheet
    @State private var presentedAvg: CalculatedAverage?
    @State private var scrambleSheetStr: SheetStrWrapper?
    @State private var showDrawScrambleSheet: Bool = false
    
    
    @State private var justManuallyInput: Bool = false
    @State private var showManualInputFormattedText: Bool = false
    
    @State var algTrainerSubset = 0
    
    @State private var showSessions: Bool = false
    
    #warning("TODO: find a way to not use an initialiser")
    
    
    var body: some View {
        let typingMode = inputMode == .typing && stopwatchManager.currentSession.sessionType != SessionType.multiphase.rawValue
        
        GeometryReader { geo in
            Color("base")
                .ignoresSafeArea()
            
            
            if (typingMode || targetFocused || manualInputFocused) {
                Color.white.opacity(0.0001)
                    .onTapGesture {
                        switch (inputMode) {
                        case .timer:
                            manualInputFocused = false
                            targetFocused = false
                            showInputField = false
                            manualInputTime = ""
                            
                        case .typing:
                            if (showManualInputFormattedText) {
                                showManualInputFormattedText = false
                                manualInputFocused = true
                                
                                
                                if justManuallyInput {
                                    manualInputTime = ""
                                    justManuallyInput = false
                                }
                            } else {
                                manualInputFocused = false
                                showManualInputFormattedText = true
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
                        .padding(.horizontal)
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
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
                
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
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
                } else {
                    HStack(alignment: .top, spacing: 6) {
                        TimerHeader(targetFocused: $targetFocused, previewMode: false)
                        
                        Spacer()
                        
                        if (stopwatchManager.isScrambleLocked) {
                            Image(systemName: "lock.rotation")
                                .font(.system(size: 17, weight: .medium, design: .default))
                                .imageScale(.medium)
                                .frame(width: 35, height: 35, alignment: .center)
                                .onTapGesture {
                                    stopwatchManager.showUnlockScrambleConfirmation = true
                                }
                        } else {
                            LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
                                .frame(maxHeight: 35)
                                .padding(.top, UIDevice.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                                .opacity(scrambleController.scrambleStr == nil ? 1 : 0)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal)
                    .zIndex(3)
                    .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
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
                    let showPlus = stopwatchManager.currentSession.sessionType != SessionType.multiphase.rawValue && !justManuallyInput && (inputMode != .typing || manualInputTime != "")
                    
                    
                    PenaltyBar {
                        HStack(spacing: 12) {
                            let _ = NSLog("\(showManualInputFormattedText)")
                            
                            if (stopwatchManager.solveItem != nil && !manualInputFocused && (inputMode == .typing ? showManualInputFormattedText : true)) {
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
                                if (!typingMode) {
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
                                } else if (typingMode) {
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
                        .if (showPlus || (stopwatchManager.solveItem != nil && !manualInputFocused && showManualInputFormattedText)) { view in
                            view.padding(.horizontal, 5)
                        }
                    }
                    
                }
                .modifier(AvoidFloatingPanel())
                .disabled(scrambleController.scrambleStr == nil)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: 40)
            }
            
            
        }
        .confirmationDialog("Unlock scramble?", isPresented: $stopwatchManager.showUnlockScrambleConfirmation, titleVisibility: .visible) {
            Button("Unlock!") {
                print(scrambleController.scrambleStr)
                stopwatchManager.isScrambleLocked = false
                scrambleController.rescramble()
                print(scrambleController.scrambleStr)
            }
            
            Button("Cancel", role: .cancel) {
                print(scrambleController.scrambleStr)
            }
        }
        
        .confirmationDialog("Are you sure you want to delete this solve?", isPresented: $stopwatchManager.showDeleteSolveConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                stopwatchManager.deleteLastSolve()
            }
            Button("Cancel", role: .cancel) { }
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
            StatsDetailView(solves: item)
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
