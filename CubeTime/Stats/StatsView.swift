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
                            .font(.system(size: 13, weight: .medium, design: .default))
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
    
    init(_ displayText: String, _ colouredText: Bool, _ colouredBlock: Bool, _ displayDetail: Bool, _ nilCondition: Bool) {
        self.displayText = displayText
        self.colouredText = colouredText
        self.colouredBlock = colouredBlock
        self.displayDetail = displayDetail
        self.nilCondition = nilCondition
    }
    
    var body: some View {
        VStack {
            if !displayDetail {
                Spacer()
            }
            
            HStack {
                if nilCondition {
                    Text(displayText)
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .modifier(DynamicText())
                    
                        .if(!colouredText) { view in
                            view.foregroundColor(Color(uiColor: colouredBlock ? .white : (colourScheme == .light ? .black : .white)))
                        }
                        .if(colouredText) { view in
                            view.gradientForeground(gradientSelected: gradientSelected)
                        }
                } else {
                    VStack {
                        Text("-")
                            .font(.system(size: 28, weight: .medium, design: .default))
                            .foregroundColor(Color(uiColor: .systemGray5))
                            .padding(.top, 20)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .offset(y: displayDetail ? 30 : 0)
            
            if displayDetail {
                Spacer()
            }
            
        }
        .padding(.bottom, 4)
        .padding(.leading, 12)
    }
}

struct StatsBlockDetailText: View {
    @Environment(\.colorScheme) var colourScheme
    let accountedSolves: [Solves]
    let allTimes: [Double]
    let colouredBlock: Bool
    
    init(_ average: CalculatedAverage, _ colouredBlock: Bool) {
        self.accountedSolves = average.accountedSolves!
        self.allTimes = accountedSolves.map{timeWithPlusTwoForSolve($0)}
        self.colouredBlock = colouredBlock
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                ForEach((0...4), id: \.self) { index in
                    let discarded: Bool = (timeWithPlusTwoForSolve(accountedSolves[index]) == allTimes.min() || timeWithPlusTwoForSolve(accountedSolves[index]) == allTimes.max())
                    let time: String = formatSolveTime(secs: accountedSolves[index].time, penType: PenTypes(rawValue: accountedSolves[index].penalty))
                    Text(discarded ? "("+time+")" : time)
                        .font(.system(size: 17, weight: .regular, design: .default))
                        .foregroundColor(discarded ? Color(uiColor: colouredBlock ? .systemGray5 : .systemGray) : colouredBlock ? .white : (colourScheme == .light ? .black : .white))
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
    
    var titles: [String]
    var data: [CalculatedAverage?]
    var checkDNF: Bool
    @Binding var presentedAvg: CalculatedAverage?
    
    init(_ titles: [String], _ data: [CalculatedAverage?], _ presentedAvg: Binding<CalculatedAverage?>, _ checkDNF: Bool) {
        self.titles = titles
        self.data = data
        self._presentedAvg = presentedAvg
        self.checkDNF = checkDNF
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(zip(titles.indices, titles)), id: \.0) { index, title in
                HStack {
                    VStack (alignment: .leading, spacing: -4) {
                        Text(title)
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(Color(uiColor: .systemGray))
                        
                        if let datum = data[index] {
                            Text(formatSolveTime(secs: datum.average ?? 0, penType: datum.totalPen))
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                .modifier(DynamicText())
                        } else {
                            Text("-")
                                .font(.system(size: 20, weight: .medium, design: .default))
                                .foregroundColor(Color(uiColor:.systemGray2))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, 12)
                .contentShape(Rectangle())
                .onTapGesture {
                    if data[index] != nil && (!checkDNF || (data[index]?.totalPen != .dnf)) {
                        presentedAvg = data[index]
                    }
                }
            }
        }
        .padding(.top, 12)
    }
}

struct StatsDivider: View {
    @Environment(\.colorScheme) var colourScheme

    var body: some View {
        Divider()
            .frame(width: UIScreen.screenWidth/2)
            .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
    }
}

struct StatsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    @Binding var currentSession: Sessions
    
    @State var isShowingStatsView: Bool = false
    @State var presentedAvg: CalculatedAverage? = nil
    @State var showBestSinglePopup = false
    
    let stats: Stats
    
    // best averages
    let bestAo5: CalculatedAverage?
    let bestAo12: CalculatedAverage?
    let bestAo100: CalculatedAverage?
    
    // current averages
    let currentAo5: CalculatedAverage?
    let currentAo12: CalculatedAverage?
    let currentAo100: CalculatedAverage?
    
    // other block calculations
    let bestSingle: Solves?
    let sessionMean: Double?
    
    // raw values for graphs
    let timesByDateNoDNFs: [Double]
    let timesBySpeedNoDNFs: [Double]
    
    
    // comp sim stats
    let compSimCount: Int
    let reachedTargets: Int
    
    let allCompsimAveragesByDate: [Double] // has no dnfs!!
    let allCompsimAveragesByTime: [Double]
    
    let bestCompsimAverage: CalculatedAverage?
    let currentCompsimAverage: CalculatedAverage?
    
    let currentMeanOfTen: Double?
    let bestMeanOfTen: Double?
    
    let phases: [Double]?
   
    init(currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext) {
        self._currentSession = currentSession
        stats = Stats(currentSession: currentSession.wrappedValue)
        
        
        self.bestAo5 = stats.getBestMovingAverageOf(5)
        self.bestAo12 = stats.getBestMovingAverageOf(12)
        self.bestAo100 = stats.getBestMovingAverageOf(100)
        
        self.currentAo5 = stats.getCurrentAverageOf(5)
        self.currentAo12 = stats.getCurrentAverageOf(12)
        self.currentAo100 = stats.getCurrentAverageOf(100)
        
        
        self.bestSingle = stats.getMin()
        self.sessionMean = stats.getSessionMean()
        
        // raw values
        self.timesByDateNoDNFs = stats.solvesNoDNFsbyDate.map { timeWithPlusTwoForSolve($0) }
        self.timesBySpeedNoDNFs = stats.solvesNoDNFs.map { timeWithPlusTwoForSolve($0) }
        
        
        // comp sim
        self.compSimCount = stats.getNumberOfAverages()
        self.reachedTargets = stats.getReachedTargets()
       
        self.allCompsimAveragesByDate = stats.getBestCompsimAverageAndArrayOfCompsimAverages().1.map { $0.average! }
        self.allCompsimAveragesByTime = self.allCompsimAveragesByDate.sorted(by: <)
        
        self.currentCompsimAverage = stats.getCurrentCompsimAverage()
        self.bestCompsimAverage = stats.getBestCompsimAverageAndArrayOfCompsimAverages().0
        
        self.currentMeanOfTen = stats.getCurrentMeanOfTen()
        self.bestMeanOfTen = stats.getBestMeanOfTen()
        
        self.phases = stats.getAveragePhases()
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (spacing: 0) {
                        VStack(spacing: 0) {
                            HStack (alignment: .center) {
                                Text(currentSession.name!)
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                                Spacer()
                                
                                switch SessionTypes(rawValue: currentSession.session_type)! {
                                case .standard:
                                    Text(puzzle_types[Int(currentSession.scramble_type)].getDescription())
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                case .multiphase:
                                    HStack(spacing: 2) {
                                        Image(systemName: "square.stack")
                                            .font(.system(size: 14, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                        
                                        Text(puzzle_types[Int(currentSession.scramble_type)].getDescription())
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    }
                                    
                                case .compsim:
                                    HStack(spacing: 2) {
                                        Image(systemName: "globe.asia.australia")
                                            .font(.system(size: 16, weight: .bold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                        
                                        Text(puzzle_types[Int(currentSession.scramble_type)].getDescription())
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    }
                                
                                case .playground:
                                    Text("Playground")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                
                                default:
                                    Text(puzzle_types[Int(currentSession.scramble_type)].getDescription())
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                            }
                        }
                        .padding(.top, -6)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                        let compsim: Bool = SessionTypes(rawValue: currentSession.session_type)! == .compsim
                        
                        /// everything
                        VStack(spacing: 10) {
                            if !compsim {
                                HStack(spacing: 10) {
                                    StatsBlock("CURRENT STATS", 160, false, false) {
                                        StatsBlockSmallText(["AO5", "AO12", "AO100"], [currentAo5, currentAo12, currentAo100], $presentedAvg, false)
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    VStack(spacing: 10) {
                                        StatsBlock("SOLVE COUNT", 75, false, false) {
                                            StatsBlockText("\(stats.getNumberOfSolves())", false, false, false, true)
                                        }
                                        
                                        StatsBlock("SESSION MEAN", 75, false, false) {
                                            if sessionMean != nil {
                                                StatsBlockText(formatSolveTime(secs: sessionMean!), false, false, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                
                                StatsDivider()
                                
                                HStack(spacing: 10) {
                                    VStack (spacing: 10) {
                                        StatsBlock("BEST SINGLE", 75, false, true) {
                                            if bestSingle != nil {
                                                StatsBlockText(formatSolveTime(secs: bestSingle!.time, penType: PenTypes(rawValue: bestSingle!.penalty)!), false, true, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .onTapGesture {
                                            if bestSingle != nil { showBestSinglePopup = true }
                                        }
                                        
                                        StatsBlock("BEST STATS", 130, false, false) {
                                            StatsBlockSmallText(["AO12", "AO100"], [bestAo12, bestAo100], $presentedAvg, true)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    StatsBlock("BEST AO5", 215, false, false) {
                                        if bestAo5 != nil {
                                            StatsBlockText(formatSolveTime(secs: bestAo5?.average ?? 0, penType: bestAo5?.totalPen), true, false, true, true)
                                            
                                            StatsBlockDetailText(bestAo5!, false)
                                        } else {
                                            StatsBlockText("", false, false, false, false)
                                        }
                                    }
                                    .onTapGesture {
                                        if bestAo5 != nil && bestAo5?.totalPen != .dnf {
                                            presentedAvg = bestAo5
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                
                                StatsDivider()
                                
                                if SessionTypes(rawValue: currentSession.session_type)! == .multiphase {
                                    StatsBlock("AVERAGE PHASES", timesBySpeedNoDNFs.count == 0 ? 150 : nil, true, false) {
                                        
                                        let _ = NSLog("\(timesByDateNoDNFs.count)")
                                        
                                        
                                        if timesByDateNoDNFs.count > 0 {
                                            AveragePhases(phaseTimes: phases!)
                                                .padding(.top, 20)
                                        } else {
                                            Text("not enough solves to\ndisplay graph")
                                                .font(.system(size: 17, weight: .medium, design: .monospaced))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(Color(uiColor: .systemGray))
                                        }
                                    }
                                    
                                    StatsDivider()
                                }
                            } else {
                                HStack(spacing: 10) {
                                    VStack(spacing: 10) {
                                        StatsBlock("CURRENT AVG", 215, false, false) {
                                            if currentCompsimAverage != nil {
                                                StatsBlockText(formatSolveTime(secs: currentCompsimAverage?.average ?? 0, penType: currentCompsimAverage?.totalPen), false, false, true, true)
                                                    
                                                StatsBlockDetailText(currentCompsimAverage!, false)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .onTapGesture {
                                            if currentCompsimAverage != nil && currentCompsimAverage?.totalPen != .dnf {
                                                presentedAvg = currentCompsimAverage
                                            }
                                        }
                                        
                                        StatsBlock("AVERAGES", 75, false, false) {
                                            StatsBlockText("\(compSimCount)", false, false, false, true)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    VStack(spacing: 10) {
                                        StatsBlock("BEST SINGLE", 75, false, false) {
                                            if bestSingle != nil {
                                                StatsBlockText(formatSolveTime(secs: bestSingle!.time), true, false, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .onTapGesture {
                                            if bestSingle != nil {
                                                showBestSinglePopup = true
                                            }
                                        }
                                        
                                        StatsBlock("BEST AVG", 215, false, true) {
                                            if bestCompsimAverage != nil {
                                                StatsBlockText(formatSolveTime(secs: bestCompsimAverage?.average ?? 0, penType: bestCompsimAverage?.totalPen), false, true, true, true)
                                                    .onTapGesture {
                                                        if bestCompsimAverage?.totalPen != .dnf {
                                                            presentedAvg = bestCompsimAverage
                                                        }
                                                    }
                                                
                                                StatsBlockDetailText(bestCompsimAverage!, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                
                                StatsDivider()
                                
                                HStack(spacing: 10) {
                                    StatsBlock("TARGET", 75, false, false) {
                                        StatsBlockText(formatSolveTime(secs: (currentSession as! CompSimSession).target, dp: 2), false, false, false, true)
                                    }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    StatsBlock("REACHED", 75, false, false) {
                                        StatsBlockText("\(reachedTargets)/\(compSimCount)", false, false, false, (bestSingle != nil))
                                    }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                
                                
                                StatsBlock("REACHED TARGETS", compSimCount == 0 ? 150 : 50, true, false) {
                                    if compSimCount != 0 {
                                        ReachedTargets(Float(reachedTargets)/Float(compSimCount))
                                            .padding(.horizontal, 12)
                                            .offset(y: 30)
                                    } else {
                                        Text("not enough solves to\ndisplay graph")
                                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    }
                                }
                                
                                StatsDivider()
                                
                                HStack(spacing: 10) {
                                    StatsBlock("CURRENT MO10 AO5", 75, false, false) {
                                        if currentMeanOfTen != nil {
                                            StatsBlockText(formatSolveTime(secs: currentMeanOfTen!, penType: ((currentMeanOfTen == -1) ? .dnf : PenTypes.none)), false, false, false, true)
                                        } else {
                                            StatsBlockText("", false, false, false, false)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    StatsBlock("BEST MO10 AO5", 75, false, false) {
                                        if bestMeanOfTen != nil {
                                            StatsBlockText(formatSolveTime(secs: bestMeanOfTen!, penType: ((bestMeanOfTen == -1) ? .dnf : PenTypes.none)), false, false, false, true)
                                        } else {
                                            StatsBlockText("", false, false, false, false)
                                        }
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                                
                                StatsDivider()
                            }
                            
                            
                            let timeTrendData = (compsim ? allCompsimAveragesByDate : timesByDateNoDNFs)
                            let timeDistributionData = (compsim ? allCompsimAveragesByTime : timesBySpeedNoDNFs)
                            
                            StatsBlock("TIME TREND", (timeTrendData.count < 2 ? 150 : 300), true, false) {
                                TimeTrend(data: timeTrendData, title: nil, style: ChartStyle(.white, .black, Color.black.opacity(0.24)))
                                    .frame(width: UIScreen.screenWidth - (2 * 16) - (2 * 12))
                                    .padding(.horizontal, 12)
                                    .offset(y: -5)
                                    .drawingGroup()
                            }
                            
                            StatsBlock("TIME DISTRIBUTION", (timeDistributionData.count < 4 ? 150 : 300), true, false) {
                                TimeDistribution(currentSession: $currentSession, solves: timeDistributionData)
                                    .drawingGroup()
                            }
                        }
                    }
                }
                .navigationTitle("Your Solves")
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
                .sheet(item: $presentedAvg) { item in
                    StatsDetail(solves: item, session: currentSession)
                }
                .sheet(isPresented: $showBestSinglePopup) {
                    TimeDetail(solve: bestSingle!, currentSolve: nil, timeListManager: nil) // TODO make delete work from here
                    // maybe pass stats object and make it remove min
                }
            }
        }
    }
}
