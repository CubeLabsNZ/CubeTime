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
    @EnvironmentObject var stopWatchManager: StopWatchManager
    @Environment(\.colorScheme) var colourScheme
    
    let font: CTFontDescriptor
    
    func getTimerColor() -> Color {
        if stopWatchManager.mode == .inspecting && colourScheme == .dark && stopWatchManager.timerColour == Color.Timer.normal {
            switch stopWatchManager.inspectionSecs {
            case ..<8: return Color.Timer.normal
            case 8..<12: return Color(uiColor: .systemYellow)
            case 12..<15: return Color(uiColor: .systemOrange)
            default: return Color(uiColor: .systemRed)
            }
        } else {
            return stopWatchManager.timerColour
        }
    }
    
    var body: some View {
        Text(stopWatchManager.secondsStr)
            .foregroundColor(getTimerColor())
            .modifier(DynamicText())
        // for smaller phones (iPhoneSE and test sim), disable animation to larger text
        // to prevent text clipping and other UI problems
            .if(!(smallDeviceNames.contains(getModelName()))) { view in
                view
                    .modifier(AnimatingFontSize(font: font, fontSize: stopWatchManager.mode == .running ? 70 : 56))
                    .animation(Animation.spring(), value: stopWatchManager.mode == .running)
            }
            .if(smallDeviceNames.contains(getModelName())) { view in
                view
                    .font(Font(CTFontCreateWithFontDescriptor(font, 54, nil)))
            }
    }
}


struct TimerBackgroundColor: View {
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        if stopWatchManager.mode == .inspecting && colourScheme == .light {
            switch stopWatchManager.inspectionSecs {
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
                Color.getBackgroundColour(colourScheme)
            }
        } else {
            Color.getBackgroundColour(colourScheme)
        }
    }
}


enum TimerTool {
    case drawScramble
    case stats
}

struct BottomTools: View {
    @EnvironmentObject var stopWatchManager: StopWatchManager
    @Binding var scrambleSheetStr: SheetStrWrapper?

    
    let toolType: TimerTool
    let maxHeight: CGFloat
    let maxWidth: CGFloat
    
    init(toolType: TimerTool, parentGeo: CGSize, scrambleSheetStr: Binding<SheetStrWrapper?>) {
        self._scrambleSheetStr = scrambleSheetStr
        self.toolType = toolType
        self.maxHeight = 120
        self.maxWidth = (parentGeo.width - 32) / 2 - 12
    }
    
    
    var body: some View {
        switch toolType {
        case .drawScramble:
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .systemGray5))
                    .frame(width: maxWidth, height: maxHeight)
                
                if let svg = stopWatchManager.scrambleSVG {
                    if let scr = stopWatchManager.scrambleStr {
                        SVGView(string: svg)
                            .padding(2)
                            .frame(width: maxWidth, height: maxHeight)
                            .aspectRatio(contentMode: .fit)
                            .onTapGesture {
                                scrambleSheetStr = SheetStrWrapper(str: scr)
                            }
                    }
                } else {
                    LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                        .frame(width: maxWidth, height: maxHeight, alignment: .center)
                }
            }
            .frame(width: maxWidth, height: maxHeight)
            
        case .stats:
            EmptyView()
        }
    }
}



struct PadFloatingView: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @EnvironmentObject var tabRouter: TabRouter
    
    
    @Binding var floatingPanelStage: Int
    var targetFocused: FocusState<Bool>.Binding
    
    var body: some View {
        
        FloatingPanel(
            currentStage: $floatingPanelStage,
            maxHeight: (globalGeometrySize.height - 24),
            stages: [0, 50, 130, (globalGeometrySize.height - 24)],
            content: {
                EmptyView()
                
                TimerHeader(targetFocused: targetFocused, previewMode: false)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 12) {
                    TimerHeader(targetFocused: targetFocused, previewMode: false)
                    
                    PrevSolvesDisplay(count: 3)
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 0) {
                    TimerHeader(targetFocused: targetFocused, previewMode: false)
                        .padding()
//                                            .padding(.bottom)
                    
                    MainTabsView()
                }
            }
         )
        .ignoresSafeArea(.keyboard)
        .frame(width: 360)
        .padding(.top, SetValues.hasBottomBar
                 ? 0
                 : tabRouter.hideTabBar
                    ? nil
                    : 8)
    }
}

let padFloatingLayout = true


struct TimerView: View {
    @EnvironmentObject var stopWatchManager: StopWatchManager
    @EnvironmentObject var tabRouter: TabRouter
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
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
    @AppStorage(asKeys.fontWeight.rawValue) private var fontWeight: Double = 300
    @AppStorage(asKeys.fontCasual.rawValue) private var fontCasual: Double = 0.5
    @AppStorage(asKeys.fontCursive.rawValue) private var fontCursive: Bool = false

    
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
    @State var floatingPanelStage: Int = 1
    

    
    #warning("TODO: find a way to not use an initialiser")
    
    func getFont() -> (Font, CTFontDescriptor) {
            // weight, casual, cursive
        let variations = [2003265652: fontWeight, 1128354636: fontCasual, 1129468758: fontCursive ? 1 : 0]
        let variationsTimer = [2003265652: fontWeight + 200, 1128354636: fontCasual, 1129468758: fontCursive ? 1 : 0]
        
        let ctFontDesc = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variations
        ] as! CFDictionary)
        
        let ctFontDescTimer = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variationsTimer
        ] as! CFDictionary)
        
        let ctFont = CTFontCreateWithFontDescriptor(ctFontDesc, stopWatchManager.currentSession.scramble_type == 7 ? (globalGeometrySize.width) / (42.00) * 1.44 : CGFloat(scrambleSize), nil)

        return (Font(ctFont), ctFontDescTimer)
    }
    
    var body: some View {
        let fonts = getFont()
        GeometryReader { geo in
            TimerBackgroundColor()
                .ignoresSafeArea(.all)
            
            
            if inputMode == .typing || targetFocused || manualInputFocused {
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
                TimerTouchView(stopWatchManager: stopWatchManager)
            }
            
            
            if !((inputMode == .typing || showInputField) && !showManualInputFormattedText) {
                VStack(alignment: .center, spacing: 0) {
                    TimerTime(font: fonts.1)
                        .allowsHitTesting(false)
                        
                    if stopWatchManager.mode == .inspecting {
                        if stopWatchManager.inspectionSecs >= 15 {
                            Text(stopWatchManager.inspectionSecs >= 17 ? "DNF" : "+2")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .allowsHitTesting(false)
                        }
                        
                        if showCancelInspection {
                            PenaltyBar(90) {
                                Button {
                                    stopWatchManager.interruptInspection()
                                } label: {
                                    Text("Cancel")
                                        .font(.system(size: 21, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                }
                                .zIndex(100)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            }
            
            
            if (inputMode == .typing || showInputField) && !showManualInputFormattedText {
                Group {
                    TextField("0.00", text: $manualInputTime)
                        .focused($manualInputFocused)
                        .frame(maxWidth: geo.size.width-32)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundColor(stopWatchManager.timerColour)
                        .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black))
                        .modifier(DynamicText())
                        .modifier(TimeMaskTextField(text: $manualInputTime))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            }
            
            if stopWatchManager.mode == .stopped {
                BottomTools(toolType: .drawScramble, parentGeo: geo.size, scrambleSheetStr: $scrambleSheetStr)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.horizontal)
                    .offset(x: 0, y: -(50 + 12 + (SetValues.hasBottomBar ? 0 : 12))) // 50 for tab + 8 for padding + 16/0 for bottom bar gap
                
                
                HStack(alignment: .top, spacing: 6) {
                    if padFloatingLayout && UIDevice.deviceIsPad && UIDevice.deviceIsLandscape(globalGeometrySize) {
                        PadFloatingView(floatingPanelStage: $floatingPanelStage, targetFocused: $targetFocused)
                    } else {
                        TimerHeader(targetFocused: $targetFocused, previewMode: false)
                    }
                    
                    Spacer()
                    
                    LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                        .frame(maxHeight: 35)
                        .padding(.top, SetValues.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
                        .opacity(stopWatchManager.scrambleStr == nil ? 1 : 0)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                
                
                if let scr = stopWatchManager.scrambleStr {
                    Group {
                        Text(scr)
                            .font(fonts.0)
                            .multilineTextAlignment(stopWatchManager.currentSession.scramble_type == 7 ? .leading : .center)
                            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
                            .frame(maxWidth: .infinity, maxHeight: globalGeometrySize.height/3)
                            .onTapGesture {
                                scrambleSheetStr = SheetStrWrapper(str: scr)
                            }
                            .padding(.horizontal)
                            .padding(.leading, floatingPanelStage > 1 ? 400 : 0)
                            .offset(y: 35 + (SetValues.hasBottomBar ? 0 : 8))
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            
            
            if stopWatchManager.scrambleStr != nil && (inputMode == .typing || stopWatchManager.showPenOptions) {
                HStack {
                    let showPlus = stopWatchManager.currentSession.session_type != SessionTypes.multiphase.rawValue && !justManuallyInput && (inputMode != .typing || manualInputTime != "")
                    
                    if stopWatchManager.solveItem != nil && !manualInputFocused {
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
                                .fill(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray4))
                                .frame(width: 1.5, height: 20)
                                .padding(.horizontal, 12)
                        }
                    }
                    
                    
                    if showPlus {
                        if inputMode == .timer {
                            PenaltyBar(manualInputFocused ? 68 : 34) {
                                Button {
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
                        } else if inputMode == .typing {
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
                .disabled(stopWatchManager.scrambleStr == nil)
                .ignoresSafeArea(edges: .all)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .offset(y: 45)
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
    }
}


struct TimeScrambleDetail: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
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
                    SVGView(string: svg)
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
