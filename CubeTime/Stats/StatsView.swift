import SwiftUI
import CoreData

struct StatsBlock<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let dataView: Content
    let title: String
    let blockHeight: CGFloat?
    let bigBlock: Bool
    let coloured: Bool
    
    
    init(_ title: String, _ blockHeight: CGFloat?, _ bigBlock: Bool, _ coloured: Bool, @ViewBuilder _ dataView: () -> Content) {
        self.dataView = dataView()
        self.title = title
        self.bigBlock = bigBlock
        self.coloured = coloured
        self.blockHeight = blockHeight
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Text(title)
                            .font(.footnote.weight(.medium))
                            .foregroundColor(Color(uiColor: title == "CURRENT STATS" ? (colourScheme == .light ? .black : .white) : (coloured ? (colourScheme == .light ? .systemGray5 : .white) : .systemGray)))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, 9)
                .padding(.leading, 12)
                
                dataView
            }
        }
        .frame(height: blockHeight)
        .if(coloured) { view in
            view.background(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected)                                        .clipShape(RoundedRectangle(cornerRadius:16)))
        }
        .if(!coloured) { view in
            view.background(Color(uiColor: title == "CURRENT STATS" ? .systemGray5 : (colourScheme == .light ? .white : .systemGray6)).clipShape(RoundedRectangle(cornerRadius:16)))
        }
        .if(bigBlock) { view in
            view.padding(.horizontal)
        }
    }
}



struct StatsBlockText: View {
    @Environment(\.colorScheme) var colourScheme
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let displayText: String
    let colouredText: Bool
    let colouredBlock: Bool
    let displayDetail: Bool
    let nilCondition: Bool
    
    @ScaledMetric private var blockHeightSmall = 75
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                (scene as? UIWindowScene)?.keyWindow
                            }).first?.frame.size
    
    init(_ displayText: String, _ colouredText: Bool, _ colouredBlock: Bool, _ displayDetail: Bool, _ nilCondition: Bool) {
        self.displayText = displayText
        self.colouredText = colouredText
        self.colouredBlock = colouredBlock
        self.displayDetail = displayDetail
        self.nilCondition = nilCondition
    }
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                
                HStack {
                    if nilCondition {
                        Text(displayText)
                            .font(.largeTitle.weight(.bold))
                            .frame(minWidth: 0, maxWidth: UIScreen.screenWidth/2 - 42, alignment: .leading)
                            .modifier(DynamicText())
                            .padding(.bottom, 2)
                        
                            .if(!colouredText) { view in
                                view.foregroundColor(Color(uiColor: colouredBlock ? .white : (colourScheme == .light ? .black : .white)))
                            }
                            .if(colouredText) { view in
                                view.gradientForeground(gradientSelected: gradientSelected)
                            }
                        
                            
                        
                    } else {
                        VStack {
                            Text("-")
                                .font(.title.weight(.medium))
                                .foregroundColor(Color(uiColor: .systemGray5))
                                .padding(.top, 20)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.bottom, 4)
            .padding(.leading, 12)
            .frame(height: blockHeightSmall)
//            .background(Color.red)
            
            
            if displayDetail {
                Spacer()
            }
        }
    }
}

struct StatsBlockDetailText: View {
    @Environment(\.colorScheme) var colourScheme
    let calculatedAverage: CalculatedAverage
    let colouredBlock: Bool
    
    var body: some View {
        let _ = NSLog("calculated average : \(calculatedAverage.name)")
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                ForEach(calculatedAverage.accountedSolves!, id: \.self) { solve in
                    let discarded = calculatedAverage.trimmedSolves!.contains(solve)
                    let time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                    Text(discarded ? "("+time+")" : time)
                        .font(.body)
                        .foregroundColor(discarded ? Color(uiColor: colouredBlock ? .systemGray5 : .systemGray) : (colouredBlock ? .white : (colourScheme == .light ? .black : .white)))
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 2)
                }
            }
            Spacer()
        }
        .padding(.bottom, 9)
        .padding(.leading, 12)
    }
}

struct StatsBlockSmallText: View {
    @Environment(\.colorScheme) var colourScheme
    @ScaledMetric private var bigSpacing: CGFloat = 2
    @ScaledMetric private var spacing: CGFloat = -6
        
    var titles: [String]
    var data: [CalculatedAverage?]
    @Binding var presentedAvg: CalculatedAverage?
    
    init(_ titles: [String], _ data: [CalculatedAverage?], _ presentedAvg: Binding<CalculatedAverage?>) {
        self.titles = titles
        self.data = data
        self._presentedAvg = presentedAvg
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: bigSpacing) {
            ForEach(Array(zip(titles.indices, titles)), id: \.0) { index, title in
                HStack {
                    VStack (alignment: .leading, spacing: spacing) {
                        Text(title)
                            .font(.footnote.weight(.medium))
                            .foregroundColor(Color(uiColor: .systemGray))
                        
                        if let datum = data[index] {
                            Text(formatSolveTime(secs: datum.average ?? 0, penType: datum.totalPen))
                                .font(.title2.weight(.bold))
                                .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                .modifier(DynamicText())
                        } else {
                            Text("-")
                                .font(.title3.weight(.medium))
                                .foregroundColor(Color(uiColor:.systemGray2))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, 12)
                .contentShape(Rectangle())
                .onTapGesture {
                    if data[index] != nil {
                        presentedAvg = data[index]
                    }
                }
            }
        }
        .padding(.top, 16)
    }
}

struct StatsDivider: View {
    @Environment(\.colorScheme) var colourScheme
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                (scene as? UIWindowScene)?.keyWindow
                            }).first?.frame.size

    var body: some View {
        Divider()
            .frame(width: windowSize!.width / 2)
            .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
    }
}

struct StatsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    // Accessibility Scaling
    @ScaledMetric var blockHeightSmall = 75
    @ScaledMetric var blockHeightMedium = 130
    @ScaledMetric var blockHeightLarge = 160
    @ScaledMetric var blockHeightExtraLarge = 215
    
    @ScaledMetric var blockHeightReachedTargets = 50
    @ScaledMetric var offsetReachedTargets = 30
    
    
    @State var isShowingStatsView: Bool = false
    @State var presentedAvg: CalculatedAverage? = nil
    @State var showBestSinglePopup = false
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                (scene as? UIWindowScene)?.keyWindow
                            }).first?.frame.size
    

//        // comp sim
//        self.compSimCount = stats.getNumberOfAverages()
//        self.reachedTargets = stats.getReachedTargets()
//
//        self.allCompsimAveragesByDate = stats.getBestCompsimAverageAndArrayOfCompsimAverages().1.map { $0.average! }
//        self.allCompsimAveragesByTime = self.allCompsimAveragesByDate.sorted(by: <)
//
//        self.currentCompsimAverage = stats.getCurrentCompsimAverage()
//        self.bestCompsimAverage = stats.getBestCompsimAverageAndArrayOfCompsimAverages().0
//
//        self.currentMeanOfTen = stats.getCurrentMeanOfTen()
//        self.bestMeanOfTen = stats.getBestMeanOfTen()
//
//        self.phases = stats.getAveragePhases()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (spacing: 0) {
                        SessionBar(name: stopWatchManager.currentSession.name!, session: stopWatchManager.currentSession)
                            .padding(.top, -6)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        let compsim: Bool = SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! == .compsim
                        
                        /// everything
                        VStack(spacing: 10) {
                            if !compsim {
                                HStack(spacing: 10) {
                                    StatsBlock("CURRENT STATS", blockHeightLarge, false, false) {
                                        StatsBlockSmallText(["AO5", "AO12", "AO100"], [stopWatchManager.currentAo5, stopWatchManager.currentAo12, stopWatchManager.currentAo100], $presentedAvg)
                                    }
                                    .padding(.top, 2)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    VStack(spacing: 10) {
                                        StatsBlock("SOLVE COUNT", blockHeightSmall, false, false) {
                                            StatsBlockText("\(stopWatchManager.getNumberOfSolves())", false, false, false, true)
                                        }
                                        
                                        StatsBlock("SESSION MEAN", blockHeightSmall, false, false) {
                                            if let sessionMean = stopWatchManager.sessionMean {
                                                StatsBlockText(formatSolveTime(secs: sessionMean), false, false, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.leading)
                                .padding(.trailing, 10)
                                
                                StatsDivider()
                                
                                HStack(spacing: 10) {
                                    VStack (spacing: 10) {
                                        StatsBlock("BEST SINGLE", blockHeightSmall, false, true) {
                                            if let bestSingle = stopWatchManager.bestSingle {
                                                StatsBlockText(formatSolveTime(secs: bestSingle.time, penType: PenTypes(rawValue: bestSingle.penalty)!), false, true, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .onTapGesture {
                                            if stopWatchManager.bestSingle != nil { showBestSinglePopup = true }
                                        }
                                        
                                        StatsBlock("BEST STATS", blockHeightMedium, false, false) {
                                            StatsBlockSmallText(["AO12", "AO100"], [stopWatchManager.bestAo12, stopWatchManager.bestAo100], $presentedAvg)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    StatsBlock("BEST AO5", blockHeightExtraLarge, false, false) {
                                        if let bestAo5 = stopWatchManager.bestAo5 {
                                            StatsBlockText(formatSolveTime(secs: bestAo5.average ?? 0, penType: bestAo5.totalPen), true, false, true, true)
                                            
                                            StatsBlockDetailText(calculatedAverage: bestAo5, colouredBlock: false)
                                        } else {
                                            StatsBlockText("", false, false, false, false)
                                        }
                                    }
                                    .onTapGesture {
                                        if let bestAo5 = stopWatchManager.bestAo5 {
                                            presentedAvg = bestAo5
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.leading)
                                .padding(.trailing, 10)
                                
//                                        StatsDivider()
                                
                                if SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! == .multiphase {
                                    StatsDivider()
                                    
                                    StatsBlock("AVERAGE PHASES", stopWatchManager.solvesNoDNFs.count == 0 ? 150 : nil, true, false) {
                                        
                                        if stopWatchManager.solvesNoDNFsbyDate.count > 0 {
                                            AveragePhases(phaseTimes: stopWatchManager.phases!)
                                                .padding(.top, 20)
                                        } else {
                                            Text("not enough solves to\ndisplay graph")
                                                .font(.system(size: 17, weight: .medium, design: .monospaced))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(Color(uiColor: .systemGray))
                                        }
                                    }
                                }
                            } else {
                                HStack(spacing: 10) {
                                    VStack(spacing: 10) {
                                        StatsBlock("CURRENT AVG", blockHeightExtraLarge, false, false) {
                                            if let currentCompsimAverage = stopWatchManager.currentCompsimAverage {
                                                StatsBlockText(formatSolveTime(secs: currentCompsimAverage.average ?? 0, penType: currentCompsimAverage.totalPen), false, false, true, true)
                                                    
                                                StatsBlockDetailText(calculatedAverage: currentCompsimAverage, colouredBlock: false)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .onTapGesture {
                                            if stopWatchManager.currentCompsimAverage != nil && stopWatchManager.currentCompsimAverage?.totalPen != .dnf {
                                                presentedAvg = stopWatchManager.currentCompsimAverage
                                            }
                                        }
                                        
                                        StatsBlock("AVERAGES", blockHeightSmall, false, false) {
                                            StatsBlockText(String(describing: stopWatchManager.compSimCount!), false, false, false, true)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    VStack(spacing: 10) {
                                        StatsBlock("BEST SINGLE", blockHeightSmall, false, false) {
                                            if let bestSingle = stopWatchManager.bestSingle {
                                                StatsBlockText(formatSolveTime(secs: bestSingle.time), true, false, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .onTapGesture {
                                            if stopWatchManager.bestSingle != nil {
                                                showBestSinglePopup = true
                                            }
                                        }
                                        
                                        StatsBlock("BEST AVG", blockHeightExtraLarge, false, true) {
                                            if let bestCompsimAverage = stopWatchManager.bestCompsimAverage {
                                                StatsBlockText(formatSolveTime(secs: bestCompsimAverage.average ?? 0, penType: bestCompsimAverage.totalPen), false, true, true, true)
                                                
                                                StatsBlockDetailText(calculatedAverage: bestCompsimAverage, colouredBlock: true)

                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .onTapGesture {
                                            if stopWatchManager.bestCompsimAverage?.totalPen != .dnf {
                                                presentedAvg = stopWatchManager.bestCompsimAverage
                                            }
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.leading)
                                .padding(.trailing, 10)
                                
                                StatsDivider()
                                
                                HStack(spacing: 10) {
                                    StatsBlock("TARGET", blockHeightSmall, false, false) {
                                        StatsBlockText(formatSolveTime(secs: (stopWatchManager.currentSession as! CompSimSession).target, dp: 2), false, false, false, true)
                                    }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    StatsBlock("REACHED", blockHeightSmall, false, false) {
                                       
                                        
                                        StatsBlockText(String(describing: stopWatchManager.reachedTargets!) + "/" + String(describing: stopWatchManager.compSimCount!), false, false, false, (stopWatchManager.bestSingle != nil))
                                    }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                #warning("TODO: check this, was .leading and .trailing, 10 in ipados branch")
                                
                                
                                StatsBlock("REACHED TARGETS", stopWatchManager.compSimCount == 0 ? 150 : 50, true, false) {
                                    if stopWatchManager.compSimCount != 0 {
                                        ReachedTargets(Float(stopWatchManager.reachedTargets)/Float(stopWatchManager.compSimCount))
                                            .padding(.horizontal, 12)
                                            .offset(y: offsetReachedTargets)
                                    } else {
                                        Text("not enough solves to\ndisplay graph")
                                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    }
                                }
                                
                                StatsDivider()
                                
                                HStack(spacing: 10) {
                                    StatsBlock("CURRENT MO10 AO5", blockHeightSmall, false, false) {
                                        if let currentMeanOfTen = stopWatchManager.currentMeanOfTen {
                                            StatsBlockText(formatSolveTime(secs: currentMeanOfTen, penType: ((currentMeanOfTen == -1) ? .dnf : PenTypes.none)), false, false, false, true)
                                            StatsBlockText("", false, false, false, false)
                                        } else {
                                            StatsBlockText("", false, false, false, false)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    StatsBlock("BEST MO10 AO5", blockHeightSmall, false, false) {
                                        if let bestMeanOfTen = stopWatchManager.bestMeanOfTen {
                                            StatsBlockText(formatSolveTime(secs: bestMeanOfTen, penType: ((bestMeanOfTen == -1) ? .dnf : PenTypes.none)), false, false, false, true)
                                        } else {
                                            StatsBlockText("", false, false, false, false)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                
                                StatsDivider()
                            }
                            
                            let allCompsimAveragesByDate: [CalculatedAverage] = stopWatchManager.getBestCompsimAverageAndArrayOfCompsimAverages().1
                            
                            /*
                            let timeTrendData = (compsim
                                                 ? allCompsimAveragesByDate.map { $0.average! }
                                                 : stopWatchManager.solvesNoDNFsbyDate.map { timeWithPlusTwoForSolve($0) })
                             */
                            
                            let timeDistributionData = (compsim
                                                        ? allCompsimAveragesByDate.map{ $0.average! }.sorted(by: <)
                                                        : stopWatchManager.solvesNoDNFs.map { timeWithPlusTwoForSolve($0) })
                            
                            /*
                            StatsBlock("TIME TREND", (timeTrendData.count < 2 ? 150 : 310), true, false) {
                                
                                TimeTrend(data: timeTrendData, title: nil, style: ChartStyle(.white, .black, Color.black.opacity(0.24)))
                                    .frame(width: UIScreen.screenWidth - (2 * 16) - (2 * 12))
                                    .padding(.horizontal, 12)
                                    .offset(y: -4)
                                    .drawingGroup()
                            }
                            */
                             
                            StatsBlock("TIME DISTRIBUTION", (timeDistributionData.count < 4 ? 150 : 310), true, false) {
                                TimeDistribution(solves: timeDistributionData)
                                    .drawingGroup()
                                    .frame(height: timeDistributionData.count < 4 ? 150 : 300)
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
                .navigationTitle("Your Solves")
                
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $presentedAvg) { item in
            StatsDetail(solves: item, session: stopWatchManager.currentSession)
        }
        .sheet(isPresented: $showBestSinglePopup) {
            TimeDetail(solve: stopWatchManager.bestSingle!, currentSolve: nil)
        }
    }
}
