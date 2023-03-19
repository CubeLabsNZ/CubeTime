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
                        TimerStatsStandard(presentedAvg: $presentedAvg)
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
    let average: StatResult
    let placeholderText: String
    let hasIndividualGesture: Bool
    @Binding var presentedAvg: CalculatedAverage?

    init(name: String, average: StatResult, placeholderText: String = "-", presentedAvg: Binding<CalculatedAverage?>, hasIndividualGesture: Bool=true) {
        self.name = name
        self.average = average
        self.placeholderText = placeholderText
        self.hasIndividualGesture = hasIndividualGesture
        self._presentedAvg = presentedAvg
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(name)
                .font(.system(size: 13, weight: .medium))
            
            switch average {
            case .loading:
                LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
            case .notEnoughDetail:
                Text(placeholderText)
                    .font(.system(size: 24, weight: .medium, design: .default))
                    .foregroundColor(Color("grey"))
            case .error(let error):
                Text(error.localizedDescription)
                    .font(.system(size: 24, weight: .bold))
                    .modifier(DynamicText())
            case .value(let statValue):
                Text(statValue.formatted)
                    .font(.system(size: 24, weight: .bold))
                    .modifier(DynamicText())
            }
        }
        .if(hasIndividualGesture) { view in
            view
                .onTapGesture {
                    if average != nil {
                        //                            presentedAvg = average
                    }
                }
        }
    }
}

struct TimerStatsStandard: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @State private var showStats: Bool = false
    @Binding var presentedAvg: CalculatedAverage?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                TimerStat(name: "AO5", average: stopwatchManager.stats["currentAo5"]!.result, presentedAvg: $presentedAvg, hasIndividualGesture: !UIDevice.deviceIsPad)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                TimerStat(name: "AO12", average: stopwatchManager.stats["currentAo12"]!.result, presentedAvg: $presentedAvg, hasIndividualGesture: !UIDevice.deviceIsPad)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
            
            ThemedDivider()
                .padding(.horizontal, 18)
            
            HStack(spacing: 6) {
                TimerStat(name: "AO100", average: stopwatchManager.stats["currentAo100"]!.result, presentedAvg: $presentedAvg, hasIndividualGesture: !UIDevice.deviceIsPad)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                TimerStat(name: "MEAN", average: stopwatchManager.stats["mean"]!.result, presentedAvg: $presentedAvg, hasIndividualGesture: !UIDevice.deviceIsPad)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.horizontal, 6)
        .if(UIDevice.deviceIsPad) { view in
            view
                .onTapGesture {
                    self.showStats = true
                }
                .sheet(isPresented: self.$showStats) {
                    StatsView()
                }
        }
    }
}


struct TimerStatsCompSim: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @State private var showStats: Bool = false
    
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
    
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                TimerStatRaw(name: "BPA", value: stopwatchManager.bpa == nil ? nil : formatSolveTime(secs: stopwatchManager.bpa!.average, penType: stopwatchManager.bpa!.penalty), placeholderText: "...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                TimerStatRaw(name: "WPA", value: stopwatchManager.wpa == nil ? nil : formatSolveTime(secs: stopwatchManager.wpa!.average, penType: stopwatchManager.wpa!.penalty), placeholderText: "...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            ThemedDivider()
                .padding(.horizontal, 18)
            
            TimerStatRaw(name: "TO REACH TARGET", value: timeNeededText, placeholderText: "...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 6)
        .contentShape(Rectangle())
        .if (UIDevice.deviceIsPad && hSizeClass == .regular) { view in
            view
                .onTapGesture {
                    self.showStats = true
                }
                .sheet(isPresented: self.$showStats) {
                    StatsView()
                }
        }
    }
}
