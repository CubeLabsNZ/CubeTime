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
            if !displayDetail {
                Spacer()
            }
            
            HStack {
                if nilCondition {
                    Text(displayText)
                        .font(.system(size: 34, weight: .bold, design: .default))
                        .frame(minWidth: 0, maxWidth: windowSize!.width/2 - 42, alignment: .leading)
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
                            .font(.system(size: 28, weight: .medium, design: .default))
                            .foregroundColor(Color(uiColor: .systemGray5))
                            .padding(.top, 20)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
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
    let calculatedAverage: CalculatedAverage
    let colouredBlock: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                ForEach(calculatedAverage.accountedSolves!, id: \.self) { solve in
                    let discarded = calculatedAverage.trimmedSolves!.contains(solve)
                    let time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                    Text(discarded ? "("+time+")" : time)
                        .font(.system(size: 17, weight: .regular, design: .default))
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
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                (scene as? UIWindowScene)?.keyWindow
                            }).first?.frame.size

    var body: some View {
        Divider()
            .frame(width: windowSize!.width/(hSizeClass == .regular ? 4 : 2))
            .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
    }
}

struct StatsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
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
                        
                        #if DEBUG
                        Button {
                            for _ in 0..<1000 {
                                let solveItem: Solves!

                                solveItem = Solves(context: managedObjectContext)
                                solveItem.date = Date()
                                solveItem.session = stopWatchManager.currentSession
                                solveItem.scramble = "R U R' F' D D' D F B B "
                                solveItem.scramble_type = 1
                                solveItem.scramble_subtype = 0
                                solveItem.time = Double.random(in: 6..<11)
                                
                                do {
                                    try managedObjectContext.save()
                                } catch {
                                    if let error = error as NSError? {
                                        fatalError("Unresolved error \(error), \(error.userInfo)")
                                    }
                                }
                            }
                        } label: {
                            Text("sdfsdf")
                        }
                        #endif
                        
                        /// TOP INFO
                        VStack(spacing: 0) {
                            HStack (alignment: .center) {
                                Text(stopWatchManager.currentSession.name!)
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                                Spacer()
                                
                                switch SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! {
                                case .standard:
                                    Text(puzzle_types[Int(stopWatchManager.currentSession.scramble_type)].name)
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                case .multiphase:
                                    HStack(spacing: 2) {
                                        Image(systemName: "square.stack")
                                            .font(.system(size: 14, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                        
                                        Text(puzzle_types[Int(stopWatchManager.currentSession.scramble_type)].name)
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    }
                                    
                                case .compsim:
                                    HStack(spacing: 2) {
                                        Image(systemName: "globe.asia.australia")
                                            .font(.system(size: 16, weight: .bold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                        
                                        Text(puzzle_types[Int(stopWatchManager.currentSession.scramble_type)].name)
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    }
                                
                                case .playground:
                                    Text("Playground")
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                
                                default:
                                    Text(puzzle_types[Int(stopWatchManager.currentSession.scramble_type)].name)
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                            }
                        }
                        .padding(.top, -6)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                        let compsim: Bool = SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! == .compsim
                        
                        /// everything
                        HStack(alignment: .top, spacing: 0) {
                            VStack(spacing: 10) {
                                if !compsim {
                                    HStack(spacing: 10) {
                                        StatsBlock("CURRENT STATS", 160, false, false) {
                                            StatsBlockSmallText(["AO5", "AO12", "AO100"], [stopWatchManager.currentAo5, stopWatchManager.currentAo12, stopWatchManager.currentAo100], $presentedAvg, false)
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        VStack(spacing: 10) {
                                            StatsBlock("SOLVE COUNT", 75, false, false) {
                                                StatsBlockText("\(stopWatchManager.getNumberOfSolves())", false, false, false, true)
                                            }
                                            
                                            StatsBlock("SESSION MEAN", 75, false, false) {
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
                                            StatsBlock("BEST SINGLE", 75, false, true) {
                                                if let bestSingle = stopWatchManager.bestSingle {
                                                    StatsBlockText(formatSolveTime(secs: bestSingle.time, penType: PenTypes(rawValue: bestSingle.penalty)!), false, true, false, true)
                                                } else {
                                                    StatsBlockText("", false, false, false, false)
                                                }
                                            }
                                            .onTapGesture {
                                                if stopWatchManager.bestSingle != nil { showBestSinglePopup = true }
                                            }
                                            
                                            StatsBlock("BEST STATS", 130, false, false) {
                                                StatsBlockSmallText(["AO12", "AO100"], [stopWatchManager.bestAo12, stopWatchManager.bestAo100], $presentedAvg, true)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        StatsBlock("BEST AO5", 215, false, false) {
                                            if let bestAo5 = stopWatchManager.bestAo5 {
                                                StatsBlockText(formatSolveTime(secs: bestAo5.average ?? 0, penType: bestAo5.totalPen), true, false, true, true)
                                                
                                                StatsBlockDetailText(calculatedAverage: bestAo5, colouredBlock: false)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .onTapGesture {
                                            if stopWatchManager.bestAo5 != nil && stopWatchManager.bestAo5?.totalPen != .dnf {
                                                presentedAvg = stopWatchManager.bestAo5
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.leading)
                                    .padding(.trailing, 10)
                                    
//                                        StatsDivider()
                                    
                                    if SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! == .multiphase {
                                        StatsDivider()
                                        
                                        StatsBlock("AVERAGE PHASES", stopWatchManager.timesBySpeedNoDNFs.count == 0 ? 150 : nil, true, false) {
                                            
                                            if stopWatchManager.timesByDateNoDNFs.count > 0 {
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
                                            StatsBlock("CURRENT AVG", 215, false, false) {
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
                                            
                                            StatsBlock("AVERAGES", 75, false, false) {
                                                StatsBlockText("\(stopWatchManager.compSimCount)", false, false, false, true)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        VStack(spacing: 10) {
                                            StatsBlock("BEST SINGLE", 75, false, false) {
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
                                            
                                            StatsBlock("BEST AVG", 215, false, true) {
                                                if let bestCompsimAverage = stopWatchManager.bestCompsimAverage {
                                                    StatsBlockText(formatSolveTime(secs: bestCompsimAverage.average ?? 0, penType: bestCompsimAverage.totalPen), false, true, true, true)
                                                        .onTapGesture {
                                                            if bestCompsimAverage.totalPen != .dnf {
                                                                presentedAvg = bestCompsimAverage
                                                            }
                                                        }
                                                    
                                                    StatsBlockDetailText(calculatedAverage: bestCompsimAverage, colouredBlock: true)

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
                                        StatsBlock("TARGET", 75, false, false) {
                                            StatsBlockText(formatSolveTime(secs: (stopWatchManager.currentSession as! CompSimSession).target, dp: 2), false, false, false, true)
                                        }
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        StatsBlock("REACHED", 75, false, false) {
                                            StatsBlockText("\(stopWatchManager.reachedTargets)/\(stopWatchManager.compSimCount)", false, false, false, (stopWatchManager.bestSingle != nil))
                                        }
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.leading)
                                    .padding(.trailing, 10)
                                    
                                    
                                    StatsBlock("REACHED TARGETS", stopWatchManager.compSimCount == 0 ? 150 : 50, true, false) {
                                        if stopWatchManager.compSimCount != 0 {
                                            ReachedTargets(Float(stopWatchManager.reachedTargets)/Float(stopWatchManager.compSimCount))
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
                                            if let currentMeanOfTen = stopWatchManager.currentMeanOfTen {
                                                StatsBlockText(formatSolveTime(secs: currentMeanOfTen, penType: ((currentMeanOfTen == -1) ? .dnf : PenTypes.none)), false, false, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        StatsBlock("BEST MO10 AO5", 75, false, false) {
                                            if let bestMeanOfTen = stopWatchManager.bestMeanOfTen {
                                                StatsBlockText(formatSolveTime(secs: bestMeanOfTen, penType: ((bestMeanOfTen == -1) ? .dnf : PenTypes.none)), false, false, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.leading)
                                    .padding(.trailing, 10)
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            
                            VStack(spacing: 10) {
                                let timeTrendData = (compsim ? stopWatchManager.allCompsimAveragesByDate : stopWatchManager.timesByDateNoDNFs)!
                                let timeDistributionData = (compsim ? stopWatchManager.allCompsimAveragesByTime : stopWatchManager.timesBySpeedNoDNFs)!
                                
                                StatsBlock("TIME TREND", (timeTrendData.count < 2 ? 150 : 300), true, false) {
                                    
                                    TimeTrend(data: timeTrendData, title: nil, style: ChartStyle(.white, .black, Color.black.opacity(0.24)))
                                        .frame(width: windowSize!.width / 2 - (2 * 16) - (2 * 12))
                                        .padding(.leading, 12)
                                        .padding(.trailing)
                                        .offset(y: -5)
                                        .drawingGroup()
                                }
                                
                                StatsBlock("TIME DISTRIBUTION", (timeDistributionData.count < 4 ? 150 : 300), true, false) {
                                    TimeDistribution(stopWatchManager: stopWatchManager, solves: timeDistributionData)
                                        .drawingGroup()
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
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
            TimeDetail(solve: stopWatchManager.bestSingle!, currentSolve: nil) // TODO make delete work from here
            // maybe pass stats object and make it remove min
        }
    }
}
