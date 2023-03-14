import SwiftUI
import SVGView
import SwiftfulLoadingIndicators

struct BottomTools: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Preference(\.showScramble) private var showScramble
    @Preference(\.showStats) private var showStats
    
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
            
            Spacer(minLength: 0)
            
            if showStats {
                BottomToolContainer {
                    if stopwatchManager.currentSession.sessionType == SessionType.compsim.rawValue {
                        TimerStatsCompSim()
                    } else {
                        if (UIDevice.deviceIsPad && hSizeClass == .regular) {
                            TimerStatsPad()
                        } else {
                            TimerStatsStandard(presentedAvg: $presentedAvg)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .if (UIDevice.deviceIsPad && hSizeClass == .regular) { view in
            view.padding(.bottom, 32)
        }
        .if (!(UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
            view.safeAreaInset(safeArea: .tabBar)
        }
        // 18 = height of drag part
        // 8 = top padding for phone
        .padding(.horizontal)
    }
}

struct BottomToolContainer<Content: View>: View {
    @Environment(\.globalGeometrySize) private var globalGeometrySize: CGSize
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Group {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color("overlay0"))
                
                content
            }
            .frame(maxWidth: min(180, (globalGeometrySize.width - 48)/2))
            .frame(height: 120)
        }
        .frame(maxWidth: min(180, (globalGeometrySize.width - 48)/2))
        .frame(height: 120)
    }
}

struct TimerDrawScramble: View {
    @EnvironmentObject var scrambleController: ScrambleController
    @Binding var scrambleSheetStr: SheetStrWrapper?
    
    var body: some View {
        GeometryReader { geo in
            if let svg = scrambleController.scrambleSVG {
                if let scr = scrambleController.scrambleStr {
                    SVGView(string: svg)
                        .padding(2)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .aspectRatio(contentMode: .fit)
                        .onTapGesture {
                            scrambleSheetStr = SheetStrWrapper(str: scr)
                        }
                }
            } else {
                LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
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
    }
}

struct TimerStat: View {
    let name: String
    let average: CalculatedAverage?
    let value: String?
    let placeholderText: String
    let hasIndividualGesture: Bool
    @Binding var presentedAvg: CalculatedAverage?

    init(name: String, average: CalculatedAverage?, placeholderText: String = "-", presentedAvg: Binding<CalculatedAverage?>, hasIndividualGesture: Bool=true) {
        self.name = name
        self.average = average
        self.placeholderText = placeholderText
        self.hasIndividualGesture = hasIndividualGesture
        self._presentedAvg = presentedAvg
        if let average = average {
            self.value = formatSolveTime(secs: average.average!, penType: average.totalPen)
        } else {
            self.value = nil
        }
    }

    var body: some View {
        if (hasIndividualGesture) {
            TimerStatRaw(name: name, value: value, placeholderText: placeholderText)
                .onTapGesture {
                    if average != nil {
                        presentedAvg = average
                    }
                }
        } else {
            TimerStatRaw(name: name, value: value, placeholderText: placeholderText)
        }
    }
}

struct TimerStatsStandard: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Binding var presentedAvg: CalculatedAverage?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                TimerStat(name: "AO5", average: stopwatchManager.currentAo5, presentedAvg: $presentedAvg)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                TimerStat(name: "AO12", average: stopwatchManager.currentAo12, presentedAvg: $presentedAvg)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
            
            ThemedDivider()
                .padding(.horizontal, 18)
            
            HStack(spacing: 4) {
                TimerStat(name: "AO100", average: stopwatchManager.currentAo100, presentedAvg: $presentedAvg)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                TimerStatRaw(name: "MEAN", value: stopwatchManager.sessionMean == nil ? nil : formatSolveTime(secs: stopwatchManager.sessionMean!), placeholderText: "-")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 6)
    }
}

struct TimerStatsPad: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @State private var showStats: Bool = false
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                TimerStat(name: "AO5", average: stopwatchManager.currentAo5, presentedAvg: .constant(nil), hasIndividualGesture: false)
                    .frame(maxWidth: .infinity)
                TimerStat(name: "AO12", average: stopwatchManager.currentAo12, presentedAvg: .constant(nil), hasIndividualGesture: false)
                    .frame(maxWidth: .infinity)
            }
            
            ThemedDivider()
                .padding(.horizontal, 24)
            
            
            HStack(spacing: 0) {
                TimerStat(name: "AO100", average: stopwatchManager.currentAo100, presentedAvg: .constant(nil), hasIndividualGesture: false)
                    .frame(maxWidth: .infinity)
                TimerStatRaw(name: "MEAN", value: stopwatchManager.sessionMean == nil ? nil : formatSolveTime(secs: stopwatchManager.sessionMean!), placeholderText: "-")
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            self.showStats = true
        }
        .sheet(isPresented: self.$showStats) {
            StatsView()
        }
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
                    .frame(maxWidth: .infinity)
                TimerStatRaw(name: "WPA", value: stopwatchManager.wpa == nil ? nil : formatSolveTime(secs: stopwatchManager.wpa!), placeholderText: "...")
                    .frame(maxWidth: .infinity)
            }
            
            ThemedDivider()
                .padding(.horizontal, 24)
            
            TimerStatRaw(name: "TO REACH TARGET", value: stopwatchManager.wpa == nil ? nil : formatSolveTime(secs: stopwatchManager.wpa!), placeholderText: "...")
                .frame(maxWidth: .infinity)
        }
    }
}
