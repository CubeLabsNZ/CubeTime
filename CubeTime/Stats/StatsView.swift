import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    
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
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Color("base")
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack {
                            SessionHeader()
                                .padding(.horizontal)
                                .padding(.top, -6)
                                #if DEBUG
                                .onTapGesture {
                                    for _ in 0..<10000 {
                                        let solve: Solves = Solves(context: managedObjectContext)
                                        solve.time = Double.random(in: 0...10)
                                        solve.scramble = "sdlfkjsdlfksdjf"
                                        solve.date = Date()
                                        solve.scramble_type = 2
                                        solve.penalty = PenTypes.none.rawValue
                                        solve.scramble_subtype = 0
                                        solve.session = stopwatchManager.currentSession
                                        
                                        try! managedObjectContext.save()
                                    }
                                    print("finished")
                                }
                                #endif

                            let compsim: Bool = SessionTypes(rawValue: stopwatchManager.currentSession.session_type)! == .compsim
                            
                            /// everything
                            VStack(spacing: 10) {
                                if !compsim {
                                    HStack(spacing: 10) {
                                        StatsBlock("CURRENT STATS", blockHeightLarge, false, false) {
                                            StatsBlockSmallText(["AO5", "AO12", "AO100"], [stopwatchManager.currentAo5, stopwatchManager.currentAo12, stopwatchManager.currentAo100], $presentedAvg)
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        VStack(spacing: 10) {
                                            StatsBlock("SOLVE COUNT", blockHeightSmall, false, false) {
                                                StatsBlockText("\(stopwatchManager.getNumberOfSolves())", false, false, false, true)
                                            }
                                            .offset(y: 1)
                                            
                                            StatsBlock("SESSION MEAN", blockHeightSmall, false, false) {
                                                if let sessionMean = stopwatchManager.sessionMean {
                                                    StatsBlockText(formatSolveTime(secs: sessionMean), false, false, false, true)
                                                } else {
                                                    StatsBlockText("", false, false, false, false)
                                                }
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                    
                                    
                                    HStack(spacing: 10) {
                                        VStack (spacing: 10) {
                                            StatsBlock("BEST SINGLE", blockHeightSmall, false, true) {
                                                if let bestSingle = stopwatchManager.bestSingle {
                                                    StatsBlockText(formatSolveTime(secs: bestSingle.time, penType: PenTypes(rawValue: bestSingle.penalty)!), false, true, false, true)
                                                } else {
                                                    StatsBlockText("", false, true, false, false)
                                                }
                                            }
                                            .onTapGesture {
                                                if stopwatchManager.bestSingle != nil { showBestSinglePopup = true }
                                            }
                                            
                                            StatsBlock("BEST STATS", blockHeightMedium, false, false) {
                                                StatsBlockSmallText(["AO12", "AO100"], [stopwatchManager.bestAo12, stopwatchManager.bestAo100], $presentedAvg)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        StatsBlock("BEST AO5", blockHeightExtraLarge, false, false) {
                                            if let bestAo5 = stopwatchManager.bestAo5 {
                                                StatsBlockText(formatSolveTime(secs: bestAo5.average ?? 0, penType: bestAo5.totalPen), true, false, true, true)
                                                
                                                StatsBlockDetailText(calculatedAverage: bestAo5, colouredBlock: false)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
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
                                    
                                    
                                    if SessionTypes(rawValue: stopwatchManager.currentSession.session_type)! == .multiphase {
                                        StatsBlock("AVERAGE PHASES", stopwatchManager.solvesNoDNFs.count == 0 ? 150 : nil, true, false) {
                                            
                                            if stopwatchManager.solvesNoDNFsbyDate.count > 0 {
                                                AveragePhases(phaseTimes: stopwatchManager.phases!)
                                                    .padding(.top, 20)
                                            } else {
                                                Text("not enough solves to\ndisplay graph")
                                                    .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDesc, 17, nil)))
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(Color("grey"))
                                            }
                                        }
                                    }
                                } else {
                                    HStack(spacing: 10) {
                                        VStack(spacing: 10) {
                                            StatsBlock("CURRENT AVG", blockHeightExtraLarge, false, false) {
                                                if let currentCompsimAverage = stopwatchManager.currentCompsimAverage {
                                                    StatsBlockText(formatSolveTime(secs: currentCompsimAverage.average ?? 0, penType: currentCompsimAverage.totalPen), false, false, true, true)
                                                        
                                                    StatsBlockDetailText(calculatedAverage: currentCompsimAverage, colouredBlock: false)
                                                } else {
                                                    StatsBlockText("", false, false, false, false)
                                                }
                                            }
                                            .onTapGesture {
                                                if stopwatchManager.currentCompsimAverage != nil && stopwatchManager.currentCompsimAverage?.totalPen != .dnf {
                                                    presentedAvg = stopwatchManager.currentCompsimAverage
                                                }
                                            }
                                            
                                            StatsBlock("AVERAGES", blockHeightSmall, false, false) {
                                                StatsBlockText(String(describing: stopwatchManager.compSimCount!), false, false, false, true)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        VStack(spacing: 10) {
                                            StatsBlock("BEST SINGLE", blockHeightSmall, false, false) {
                                                if let bestSingle = stopwatchManager.bestSingle {
                                                    StatsBlockText(formatSolveTime(secs: bestSingle.time), true, false, false, true)
                                                } else {
                                                    StatsBlockText("", false, false, false, false)
                                                }
                                            }
                                            .onTapGesture {
                                                if stopwatchManager.bestSingle != nil {
                                                    showBestSinglePopup = true
                                                }
                                            }
                                            
                                            StatsBlock("BEST AVG", blockHeightExtraLarge, false, true) {
                                                if let bestCompsimAverage = stopwatchManager.bestCompsimAverage {
                                                    StatsBlockText(formatSolveTime(secs: bestCompsimAverage.average ?? 0, penType: bestCompsimAverage.totalPen), false, true, true, true)
                                                    
                                                    StatsBlockDetailText(calculatedAverage: bestCompsimAverage, colouredBlock: true)

                                                } else {
                                                    StatsBlockText("", false, false, false, false)
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
                                        StatsBlock("TARGET", blockHeightSmall, false, false) {
                                            StatsBlockText(formatSolveTime(secs: (stopwatchManager.currentSession as! CompSimSession).target, dp: 2), false, false, false, true)
                                        }
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        StatsBlock("REACHED", blockHeightSmall, false, false) {
                                           
                                            
                                            StatsBlockText(String(describing: stopwatchManager.reachedTargets!) + "/" + String(describing: stopwatchManager.compSimCount!), false, false, false, (stopwatchManager.bestSingle != nil))
                                        }
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                    
                                    
                                    StatsBlock("REACHED TARGETS", stopwatchManager.compSimCount == 0 ? 150 : 50, true, false) {
                                        if stopwatchManager.compSimCount != 0 {
                                            ReachedTargets(Float(stopwatchManager.reachedTargets)/Float(stopwatchManager.compSimCount))
                                                .padding(.horizontal, 12)
                                                .offset(y: offsetReachedTargets)
                                        } else {
                                            Text("not enough solves to\ndisplay graph")
                                                .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDesc, 17, nil)))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(Color("grey"))
                                        }
                                    }
                                    .padding(.bottom, 8)
                                    
                                    
                                    HStack(spacing: 10) {
                                        StatsBlock("CURRENT MO10 AO5", blockHeightSmall, false, false) {
                                            if let currentMeanOfTen = stopwatchManager.currentMeanOfTen {
                                                StatsBlockText(formatSolveTime(secs: currentMeanOfTen, penType: ((currentMeanOfTen == -1) ? .dnf : PenTypes.none)), false, false, false, true)
                                                StatsBlockText("", false, false, false, false)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        StatsBlock("BEST MO10 AO5", blockHeightSmall, false, false) {
                                            if let bestMeanOfTen = stopwatchManager.bestMeanOfTen {
                                                StatsBlockText(formatSolveTime(secs: bestMeanOfTen, penType: ((bestMeanOfTen == -1) ? .dnf : PenTypes.none)), false, false, false, true)
                                            } else {
                                                StatsBlockText("", false, false, false, false)
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
                                StatsBlock("TIME TREND", (timeTrendData.count < 2 ? 150 : 310), true, false) {
                                    TimeTrend(data: Array(timeTrendData.prefix(80)), title: nil)
                                        .padding(.horizontal, 12)
                                        .offset(y: -4)
                                        .drawingGroup()
                                }
                                 
                                
//                                StatsBlock("TIME DISTRIBUTION", (timeDistributionData.count < 4 ? 150 : 310), true, false) {
//                                    TimeDistribution(solves: timeDistributionData)
//                                        .drawingGroup()
//                                        .frame(height: timeDistributionData.count < 4 ? 150 : 300)
//                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                        }
                    }
                    .navigationTitle("Your Solves")
                    .safeAreaInset(safeArea: .tabBar)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $presentedAvg) { item in
            StatsDetail(solves: item, session: stopwatchManager.currentSession)
        }
        .sheet(isPresented: $showBestSinglePopup) {
            TimeDetailView(for: stopwatchManager.bestSingle!, currentSolve: nil)
        }
    }
}
