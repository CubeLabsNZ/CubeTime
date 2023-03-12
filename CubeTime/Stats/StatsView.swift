import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var gradientManager: GradientManager
    
    
    // Accessibility Scaling
    @ScaledMetric var blockHeightSmall = 75
    @ScaledMetric var blockHeightMedium = 130
    @ScaledMetric var blockHeightLarge = 160
    @ScaledMetric var blockHeightExtraLarge = 215
    
    @ScaledMetric var blockHeightReachedTargets = 50
    
    
    @ScaledMetric var blockGraphEmpty = 150
    @ScaledMetric var blockGraphTimeTrend = 310
    @ScaledMetric var blockGraphTimeDistribution = 300
    
    
    @ScaledMetric(relativeTo: .body) var monospacedFontSizeBody: CGFloat = 17

    
    @State var isShowingStatsView: Bool = false
    @State var presentedAvg: CalculatedAverage? = nil
    @State var showBestSinglePopup = false
    
    
    @State var showTimeTrendModal: Bool = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    BackgroundColour()
                    
                    ScrollView {
                        VStack {
                            SessionHeader()
                                .padding(.horizontal)
                                #if DEBUG
                                .onTapGesture {
                                    for _ in 0..<10000 {
                                        let solve: Solves = Solves(context: managedObjectContext)
                                        solve.time = Double.random(in: 0...10)
                                        solve.scramble = "sdlfkjsdlfksdjf"
                                        solve.date = Date()
                                        solve.scramble_type = 2
                                        solve.penalty = Penalty.none.rawValue
                                        solve.scramble_subtype = 0
                                        solve.session = stopwatchManager.currentSession
                                        
                                        try! managedObjectContext.save()
                                    }
                                    NSLog("finished")
                                }
                                #endif

                            let compsim: Bool = SessionType(rawValue: stopwatchManager.currentSession.session_type)! == .compsim
                            
                            /// everything
                            VStack(spacing: 10) {
                                if !compsim {
                                    HStack(spacing: 10) {
                                        StatsBlock(title: "CURRENT STATS", blockHeight: blockHeightLarge) {
                                            StatsBlockSmallText(titles: ["AO5", "AO12", "AO100"], data: [stopwatchManager.currentAo5, stopwatchManager.currentAo12, stopwatchManager.currentAo100], presentedAvg: $presentedAvg, blockHeight: blockHeightLarge)
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        VStack(spacing: 10) {
                                            StatsBlock(title: "SOLVE COUNT", blockHeight: blockHeightSmall, isTappable: false) {
                                                StatsBlockText(displayText: "\(stopwatchManager.getNumberOfSolves())", nilCondition: true)
                                            }
                                            
                                            StatsBlock(title: "SESSION MEAN", blockHeight: blockHeightSmall, isTappable: false) {
                                                if let sessionMean = stopwatchManager.sessionMean {
                                                    StatsBlockText(displayText: formatSolveTime(secs: sessionMean), nilCondition: true)
                                                } else {
                                                    StatsBlockText(displayText: "", nilCondition: false)
                                                }
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                    
                                    
                                    HStack(spacing: 10) {
                                        VStack (spacing: 10) {
                                            StatsBlock(title: "BEST SINGLE", blockHeight: blockHeightSmall, background: .coloured) {
                                                if let bestSingle = stopwatchManager.bestSingle {
                                                    StatsBlockText(displayText: formatSolveTime(secs: bestSingle.time, penType: Penalty(rawValue: bestSingle.penalty)!), colouredBlock: true, displayDetail: false, nilCondition: true)
                                                } else {
                                                    StatsBlockText(displayText: "", colouredBlock: true, nilCondition: false)
                                                }
                                            }
                                            .onTapGesture {
                                                if stopwatchManager.bestSingle != nil { showBestSinglePopup = true }
                                            }
                                            
                                            StatsBlock(title: "BEST STATS", blockHeight: blockHeightMedium) {
                                                StatsBlockSmallText(titles: ["AO12", "AO100"], data: [stopwatchManager.bestAo12, stopwatchManager.bestAo100], presentedAvg: $presentedAvg, blockHeight: blockHeightMedium)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        ZStack(alignment: .topLeading) {
                                            if let bestAo5 = stopwatchManager.bestAo5 {
                                                StatsBlock(title: "", blockHeight: blockHeightExtraLarge) {
                                                    StatsBlockDetailText(calculatedAverage: bestAo5, colouredBlock: false)
                                                }
                                                
                                                StatsBlock(title: "BEST AO5", blockHeight: blockHeightSmall) {
                                                    StatsBlockText(displayText: formatSolveTime(secs: bestAo5.average ?? 0, penType: bestAo5.totalPen), colouredText: true, displayDetail: true, nilCondition: true, blockHeight: blockHeightSmall)
                                                }
                                                
                                                
                                            } else {
                                                StatsBlock(title: "", blockHeight: blockHeightExtraLarge) {
                                                    HStack {
                                                        Text("")
                                                        Spacer()
                                                    }
                                                }
                                                
                                                StatsBlock(title: "BEST AO5", blockHeight: blockHeightSmall) {
                                                    StatsBlockText(displayText: "", nilCondition: false)
                                                }
                                            }
                                        }
                                        .onTapGesture {
                                            if let bestAo5 = stopwatchManager.bestAo5 {
                                                presentedAvg = bestAo5
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                    
                                    
                                    if SessionType(rawValue: stopwatchManager.currentSession.session_type)! == .multiphase {
                                        StatsBlock(title: "AVERAGE PHASES", blockHeight: stopwatchManager.solvesNoDNFs.count == 0 ? blockGraphEmpty : nil, isBigBlock: true) {
                                                AveragePhases(phaseTimes: stopwatchManager.phases!, count: stopwatchManager.solvesNoDNFsbyDate.count)
                                        }
                                    }
                                } else {
                                    HStack(spacing: 10) {
                                        VStack(spacing: 10) {
                                            ZStack(alignment: .topLeading) {
                                                if let currentCompsimAverage = stopwatchManager.currentCompsimAverage {
                                                    StatsBlock(title: "", blockHeight: blockHeightExtraLarge) {
                                                        StatsBlockDetailText(calculatedAverage: currentCompsimAverage, colouredBlock: false)
                                                    }
                                                    
                                                    StatsBlock(title: "CURRENT COMPSIM", blockHeight: blockHeightSmall) {
                                                        StatsBlockText(displayText: formatSolveTime(secs: currentCompsimAverage.average ?? 0, penType: currentCompsimAverage.totalPen), displayDetail: true, nilCondition: true, blockHeight: blockHeightSmall)
                                                    }
                                                } else {
                                                    StatsBlock(title: "", blockHeight: blockHeightExtraLarge) {
                                                        HStack {
                                                            Text("")
                                                            Spacer()
                                                        }
                                                    }
                                                    
                                                    StatsBlock(title: "CURRENT COMPSIM", blockHeight: blockHeightSmall) {
                                                        StatsBlockText(displayText: "", nilCondition: false)
                                                    }

                                                }
                                            }
                                            .onTapGesture {
                                                if stopwatchManager.currentCompsimAverage != nil && stopwatchManager.currentCompsimAverage?.totalPen != .dnf {
                                                    presentedAvg = stopwatchManager.currentCompsimAverage
                                                }
                                            }
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            StatsBlock(title: "AVERAGES", blockHeight: blockHeightSmall) {
                                                StatsBlockText(displayText: String(describing: stopwatchManager.compSimCount!), nilCondition: true)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        VStack(spacing: 10) {
                                            StatsBlock(title: "BEST SINGLE", blockHeight: blockHeightSmall) {
                                                if let bestSingle = stopwatchManager.bestSingle {
                                                    StatsBlockText(displayText: formatSolveTime(secs: bestSingle.time), colouredText: true, nilCondition: true)
                                                } else {
                                                    StatsBlockText(displayText: "", nilCondition: false)
                                                }
                                            }
                                            .onTapGesture {
                                                if stopwatchManager.bestSingle != nil {
                                                    showBestSinglePopup = true
                                                }
                                            }
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            ZStack(alignment: .topLeading) {
                                                if let bestCompsimAverage = stopwatchManager.bestCompsimAverage {
                                                    StatsBlock(title: "", blockHeight: blockHeightExtraLarge, background: .coloured) {
                                                        StatsBlockDetailText(calculatedAverage: bestCompsimAverage, colouredBlock: true)
                                                    }
                                                    
                                                    StatsBlock(title: "BEST COMPSIM", blockHeight: blockHeightSmall, background: .clear) {
                                                        StatsBlockText(displayText: formatSolveTime(secs: bestCompsimAverage.average ?? 0, penType: bestCompsimAverage.totalPen), colouredBlock: true, displayDetail: true, nilCondition: true, blockHeight: blockHeightSmall)
                                                    }
                                                } else {
                                                    StatsBlock(title: "", blockHeight: blockHeightExtraLarge) {
                                                        HStack {
                                                            Text("")
                                                            Spacer()
                                                        }
                                                    }
                                                    
                                                    StatsBlock(title: "BEST COMPSIM", blockHeight: blockHeightSmall) {
                                                        StatsBlockText(displayText: "", nilCondition: false)
                                                    }

                                                }
                                            }
                                            .onTapGesture {
                                                if stopwatchManager.bestCompsimAverage?.totalPen != .dnf {
                                                    presentedAvg = stopwatchManager.bestCompsimAverage
                                                }
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                    
                                    
                                    HStack(spacing: 10) {
                                        StatsBlock(title: "TARGET", blockHeight: blockHeightSmall) {
                                            StatsBlockText(displayText: formatSolveTime(secs: (stopwatchManager.currentSession as! CompSimSession).target, dp: 2), nilCondition: true)
                                        }
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        StatsBlock(title: "REACHED", blockHeight: blockHeightSmall) {
                                            if (stopwatchManager.compSimCount == 0) {
                                                StatsBlockText(displayText: "", nilCondition: false)
                                            } else {
                                                StatsBlockText(displayText: String(describing: stopwatchManager.reachedTargets!) + "/" + String(describing: stopwatchManager.compSimCount!), nilCondition: (stopwatchManager.bestSingle != nil))
                                            }
                                        }
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    
                                    
                                    StatsBlock(title: "REACHED TARGETS", blockHeight: 50, isBigBlock: true) {
                                        ReachedTargets(reachedCount: stopwatchManager.reachedTargets, totalCount: stopwatchManager.compSimCount)
                                    }
                                    .padding(.bottom, 8)
                                    
                                    
                                    HStack(spacing: 10) {
                                        StatsBlock(title: "CURRENT MO10 AO5", blockHeight: blockHeightSmall) {
                                            if let currentMeanOfTen = stopwatchManager.currentMeanOfTen {
                                                StatsBlockText(displayText: formatSolveTime(secs: currentMeanOfTen, penType: ((currentMeanOfTen == -1) ? .dnf : Penalty.none)), nilCondition: true)
                                                StatsBlockText(displayText: "", nilCondition: false)
                                            } else {
                                                StatsBlockText(displayText: "", nilCondition: false)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        StatsBlock(title: "BEST MO10 AO5", blockHeight: blockHeightSmall) {
                                            if let bestMeanOfTen = stopwatchManager.bestMeanOfTen {
                                                StatsBlockText(displayText: formatSolveTime(secs: bestMeanOfTen, penType: ((bestMeanOfTen == -1) ? .dnf : Penalty.none)), nilCondition: true)
                                            } else {
                                                StatsBlockText(displayText: "", nilCondition: false)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                }
                                
                                let allCompsimAveragesByDate: [CalculatedAverage] = stopwatchManager.getBestCompsimAverageAndArrayOfCompsimAverages().1
                                
                                let timeTrendData = (compsim
                                                     ? allCompsimAveragesByDate.map { $0.average! }
                                                     : stopwatchManager.solvesNoDNFsbyDate.map { $0.timeIncPen })
                                
//                                let timeDistributionData = (compsim
//                                                            ? allCompsimAveragesByDate.map{ $0.average! }.sorted(by: <)
//                                                            : stopwatchManager.solvesNoDNFs.map { $0.timeIncPen })
                                
                                
                                #warning("TODO: add settings customisation to choose how many solves to show")
                                StatsBlock(title: "TIME TREND", blockHeight: (timeTrendData.count < 2 ? blockGraphEmpty : blockGraphTimeTrend), isBigBlock: true) {
                                    TimeTrend(data: Array(timeTrendData.prefix(80)), title: nil)
                                        .drawingGroup()
                                }
                                #warning("TODO: enable for v2.1")
//                                .onTapGesture {
//                                    self.showTimeTrendModal = true
//                                }
                                 
                                
//                                StatsBlock("TIME DISTRIBUTION", (timeDistributionData.count < 4 ? blockGraphEmpty : blockGraphTimeDistribution), true, false) {
//                                    TimeDistribution(solves: timeDistributionData)
//                                        .drawingGroup()
//                                        .frame(height: timeDistributionData.count < 4 ? 150 : 300)
//                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
                    }
                    .environmentObject(gradientManager)
                    .navigationTitle("Stats")
                    .navigationBarTitleDisplayMode((UIDevice.deviceIsPad && hSizeClass == .regular) ? .inline : .large)
                    .safeAreaInset(safeArea: .tabBar)
                    .if((UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
                        view
                            .toolbar {
                                ToolbarItemGroup(placement: .navigationBarTrailing) {
                                    DoneButton(onTapRun: {
                                        dismiss()
                                    })
                                }
                            }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $presentedAvg) { item in
            StatsDetailView(solves: item, session: stopwatchManager.currentSession)
                .tint(Color("accent"))
        }
        .sheet(isPresented: $showBestSinglePopup) {
            TimeDetailView(for: stopwatchManager.bestSingle!, currentSolve: nil)
                .tint(Color("accent"))
        }
        .sheet(isPresented: self.$showTimeTrendModal) {
            let timesOnly = stopwatchManager.solvesNoDNFsbyDate.map { $0.timeIncPen }
            DetailTimeTrend(rawDataPoints: timesOnly,
                            limits: (timesOnly.max()!, timesOnly.min()!),
                            averageValue: stopwatchManager.sessionMean!)
                .tint(Color("accent"))
        }
    }
}
