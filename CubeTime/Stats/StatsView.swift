import SwiftUI
import CoreData

struct StatsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
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
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Color("base")
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack {
                            SessionTypeHeader()
                                .padding(.horizontal)
                                .padding(.top, -6)

                            let compsim: Bool = SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! == .compsim
                            
                            /// everything
                            VStack(spacing: 10) {
                                if !compsim {
                                    HStack(spacing: 10) {
                                        StatsBlock("CURRENT STATS", blockHeightLarge, false, false) {
                                            StatsBlockSmallText(["AO5", "AO12", "AO100"], [stopWatchManager.currentAo5, stopWatchManager.currentAo12, stopWatchManager.currentAo100], $presentedAvg)
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        VStack(spacing: 10) {
                                            StatsBlock("SOLVE COUNT", blockHeightSmall, false, false) {
                                                StatsBlockText("\(stopWatchManager.getNumberOfSolves())", false, false, false, true)
                                            }
                                            .offset(y: 1)
                                            
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
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                    
                                    
                                    HStack(spacing: 10) {
                                        VStack (spacing: 10) {
                                            StatsBlock("BEST SINGLE", blockHeightSmall, false, true) {
                                                if let bestSingle = stopWatchManager.bestSingle {
                                                    StatsBlockText(formatSolveTime(secs: bestSingle.time, penType: PenTypes(rawValue: bestSingle.penalty)!), false, true, false, true)
                                                } else {
                                                    StatsBlockText("", false, true, false, false)
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
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                    
                                    
                                    if SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! == .multiphase {
                                        StatsBlock("AVERAGE PHASES", stopWatchManager.solvesNoDNFs.count == 0 ? 150 : nil, true, false) {
                                            
                                            if stopWatchManager.solvesNoDNFsbyDate.count > 0 {
                                                AveragePhases(phaseTimes: stopWatchManager.phases!)
                                                    .padding(.top, 20)
                                            } else {
                                                Text("not enough solves to\ndisplay graph")
                                                    .font(Font(CTFontCreateWithFontDescriptor(stopWatchManager.ctFontDesc, 17, nil)))
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
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                    
                                    
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
                                    
                                    
                                    StatsBlock("REACHED TARGETS", stopWatchManager.compSimCount == 0 ? 150 : 50, true, false) {
                                        if stopWatchManager.compSimCount != 0 {
                                            ReachedTargets(Float(stopWatchManager.reachedTargets)/Float(stopWatchManager.compSimCount))
                                                .padding(.horizontal, 12)
                                                .offset(y: offsetReachedTargets)
                                        } else {
                                            Text("not enough solves to\ndisplay graph")
                                                .font(Font(CTFontCreateWithFontDescriptor(stopWatchManager.ctFontDesc, 17, nil)))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(Color(uiColor: .systemGray))
                                        }
                                    }
                                    .padding(.bottom, 8)
                                    
                                    
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
                                    .padding(.bottom, 8)
                                }
                                
                                let allCompsimAveragesByDate: [CalculatedAverage] = stopWatchManager.getBestCompsimAverageAndArrayOfCompsimAverages().1
                                
                                let timeTrendData = (compsim
                                                     ? allCompsimAveragesByDate.map { $0.average! }
                                                     : stopWatchManager.solvesNoDNFsbyDate.map { timeWithPlusTwoForSolve($0) })
                                
                                let timeDistributionData = (compsim
                                                            ? allCompsimAveragesByDate.map{ $0.average! }.sorted(by: <)
                                                            : stopWatchManager.solvesNoDNFs.map { timeWithPlusTwoForSolve($0) })
                                
                                StatsBlock("TIME TREND", (timeTrendData.count < 2 ? 150 : 310), true, false) {
                                    TimeTrend(data: timeTrendData, title: nil, style: ChartStyle(.white, .black, Color.black.opacity(0.24)))
//                                        .frame(width: geo.size.width)
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
            StatsDetail(solves: item, session: stopWatchManager.currentSession)
        }
        .sheet(isPresented: $showBestSinglePopup) {
            TimeDetail(solve: stopWatchManager.bestSingle!, currentSolve: nil)
        }
    }
}
