import SwiftUI
import CoreData

extension View {
    public func gradientForeground(gradientSelected: Int) -> some View {
        self.overlay(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected))
            .mask(self)
    }
}



@available(iOS 15.0, *)
struct StatsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    let columns = [
        // GridItem(.adaptive(minimum: 112), spacing: 11)
        GridItem(spacing: 10),
        GridItem(spacing: 10)
    ]
    
    @State var isShowingStatsView: Bool = false
    @Binding var currentSession: Sessions
    
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let ao5: CalculatedAverage?
    let ao12: CalculatedAverage?
    let ao100: CalculatedAverage?
    
    let currentAo5: CalculatedAverage?
    let currentAo12: CalculatedAverage?
    let currentAo100: CalculatedAverage?
    
    let timesByDate: [Double]
    
    let bestSingle: Solves?
    let sessionMean: Double?
    
    @State var presentedAvg: CalculatedAverage? = nil
    
    @State var showBestSinglePopup = false
    
    
    let stats: Stats
    init(currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext) {
        self._currentSession = currentSession
        
        stats = Stats(currentSession: currentSession.wrappedValue, managedObjectContext: managedObjectContext)
        
        self.ao5 = stats.getBestMovingAverageOf(5)
        self.ao12 = stats.getBestMovingAverageOf(12)
        self.ao100 = stats.getBestMovingAverageOf(100)
        
        self.currentAo5 = stats.getCurrentAverageOf(5)
        self.currentAo12 = stats.getCurrentAverageOf(12)
        self.currentAo100 = stats.getCurrentAverageOf(100)
        
        self.bestSingle = stats.getMin()
        self.sessionMean = stats.getSessionMean()
        
        self.timesByDate = stats.solvesByDate.map{$0.time}
        
    }
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (spacing: 0) {
                        /// the title
                        VStack(spacing: 0) {
                            HStack (alignment: .center) {
                                Text(currentSession.name!)
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                                Spacer()
                                
                                Text(puzzle_types[Int(currentSession.scramble_type)].name) // TODO playground
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                            }
                        }
                        .padding(.top, -6)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        
                        /// everything
                        VStack(spacing: 10) {
                            /// current averages, number of solves and session mean
                            VStack(spacing: 10) {
                                HStack (spacing: 10) {
                                    VStack {
                                        HStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                VStack (alignment: .leading, spacing: -4) {
                                                    Text("CURRENT STATS")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                        .padding(.leading, 12)
                                                    
                                                        .onTapGesture {
                                                            for _ in 1..<100 {
                                                                let solveItem: Solves!
                                                                
                                                                solveItem = Solves(context: managedObjectContext)
                                                                solveItem.date = Date()
                                                                solveItem.session = currentSession
                                                                solveItem.scramble = "sdlfikj"
                                                                solveItem.scramble_type = 0
                                                                solveItem.scramble_subtype = 0
                                                                solveItem.time = Double.random(in: 1..<100)
                                                                
                                                            }
                                                            do {
                                                                try managedObjectContext.save()
                                                            } catch {
                                                                if let error = error as NSError? {
                                                                    fatalError("Unresolved error \(error), \(error.userInfo)")
                                                                }
                                                            }
                                                        }
                                                    
                                                    Spacer()
                                                    
                                                    Text("AO5")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if let currentAo5 = currentAo5 {
                                                        Text(String(formatSolveTime(secs: currentAo5.average)))
                                                            .font(.system(size: 24, weight: .bold, design: .default))
                                                            .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 20, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor:.systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                }
                                                .onTapGesture {
                                                    if currentAo5 != nil {
                                                        presentedAvg = currentAo5
                                                    }
                                                }
                                                .padding(.bottom, 6)
                                                
                                                VStack (alignment: .leading, spacing: -4) {
                                                    Text("AO12")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if let currentAo12 = currentAo12 {
                                                        Text(String(formatSolveTime(secs: currentAo12.average)))
                                                            .font(.system(size: 24, weight: .bold, design: .default))
                                                            .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 20, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                    
                                                }
                                                .onTapGesture {
                                                    if currentAo12 != nil {
                                                        presentedAvg = currentAo12
                                                    }
                                                }
                                                .padding(.bottom, 6)
                                                
                                                VStack (alignment: .leading, spacing: -4) {
                                                    Text("AO100")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if let currentAo100 = currentAo100 {
                                                        Text(String(formatSolveTime(secs: currentAo100.average)))
                                                            .font(.system(size: 24, weight: .bold, design: .default))
                                                            .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 20, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                    
                                                }
                                                .onTapGesture {
                                                    if currentAo100 != nil {
                                                        presentedAvg = currentAo100
                                                    }
                                                }
                                                .padding(.bottom, 8)
                                                
                                            }
                                            .padding(.top, 10)
                                            
                                            
                                            Spacer()
                                            
                                        }
                                        .frame(height: 160)
                                        
                                        
                                        .background(Color(uiColor: .systemGray5).clipShape(RoundedRectangle(cornerRadius:16)))
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    VStack {
                                        HStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                Text("SOLVE COUNT")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(uiColor: .systemGray))
                                                    .padding(.bottom, 4)
                                                
                                                Text(String(stats.getNumberOfSolves()))
                                                    .font(.system(size: 34, weight: .bold, design: .default))
                                                    .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                            }
                                            .padding(.top)
                                            .padding(.bottom, 12)
                                            .padding(.leading, 12)
                                            
                                            Spacer()
                                        }
                                        .frame(height: 75)
                                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                        
                                        HStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                Text("SESSION MEAN")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(uiColor: .systemGray))
                                                    .padding(.bottom, 4)
                                                
                                                
                                                if sessionMean != nil {
                                                    Text(String(formatSolveTime(secs: sessionMean!)))
                                                        .font(.system(size: 34, weight: .bold, design: .default))
                                                        .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                } else {
                                                    Text("N/A")
                                                        .font(.system(size: 28, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray2))
                                                }
                                                
                                                
                                            }
                                            .padding(.top)
                                            .padding(.bottom, 12)
                                            .padding(.leading, 12)
                                            
                                            Spacer()
                                        }
                                        .frame(height: 75)
                                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                    }
                                    
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                            }
                            
                            Divider()
                                .frame(width: UIScreen.screenWidth/2)
                                .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
                            
                            /// best statistics
                            VStack (spacing: 10) {
                                HStack (spacing: 10) {
                                    VStack (spacing: 10) {
                                        HStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                Text("BEST SINGLE")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(uiColor: .systemGray6))
                                                    .padding(.bottom, 4)

                                                if bestSingle != nil {
                                                    Text(String(formatSolveTime(secs: bestSingle!.time)))
                                                        .font(.system(size: 34, weight: .bold, design: .default))
                                                        .foregroundColor(Color(uiColor: colourScheme == .light ? .white : .black))
                                                } else {
                                                    Text("N/A")
                                                        .font(.system(size: 28, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray5))
                                                }
                                            }
                                            .padding(.top)
                                            .padding(.bottom, 12)
                                            .padding(.leading, 12)
                                            
                                            Spacer()
                                        }
                                        .frame(height: 75)
                                        .background(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected)                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                        .onTapGesture {
                                            if bestSingle != nil {
                                                showBestSinglePopup = true
                                            }
                                        }
                                        
                                        HStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                
                                                VStack (alignment: .leading, spacing: 0) {
                                                    Text("BEST AO12")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if let ao12 = ao12 {
                                                        Text(String(formatSolveTime(secs: ao12.average)))
                                                            .font(.system(size: 34, weight: .bold, design: .default))
                                                            .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 28, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor:.systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                }
                                                .onTapGesture {
                                                    if ao12 != nil {
                                                        presentedAvg = ao12
                                                    }
                                                }
                                                
                                                
                                                Divider()
                                                    .padding(.leading, 12)
                                                    .padding(.vertical, 4)
                                                
                                                
                                                
                                                VStack (alignment: .leading, spacing: 0) {
                                                    Text("BEST AO100")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if let ao100 = ao100 {
                                                        Text(String(formatSolveTime(secs: ao100.average)))
                                                            .font(.system(size: 34, weight: .bold, design: .default))
                                                            .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 28, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                    
                                                }
                                                .onTapGesture {
                                                    if ao100 != nil {
                                                        presentedAvg = ao100
                                                    }
                                                }
                                                
                                                
                                            }
                                            
                                            
                                            Spacer()
                                            
                                        }
                                        .frame(height: 130)
                                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    
                                    VStack (spacing: 10) {
                                        HStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                Text("BEST AO5")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(uiColor: .systemGray))
                                                    .padding(.bottom, 4)
                                                
                                                //                                            Text("6.142")
                                                
                                                
                                                if let ao5 = ao5 {
                                                    Text(formatSolveTime(secs: ao5.average))
                                                        .font(.system(size: 34, weight: .bold, design: .default))
                                                        .gradientForeground(gradientSelected: gradientSelected)
                                                    
                                                    Spacer()
                                                    
                                                    
                                                    ForEach((0...4), id: \.self) { index in
                                                        let alltimes = ao5.accountedSolves.map{$0.time}
                                                        if ao5.accountedSolves[index].time == alltimes.min() || ao5.accountedSolves[index].time == alltimes.max() {
                                                            Text("("+formatSolveTime(secs: ao5.accountedSolves[index].time)+")")
                                                                .font(.system(size: 17, weight: .regular, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray))
                                                                .multilineTextAlignment(.leading)
                                                                .padding(.bottom, 2)
                                                        } else {
                                                            Text(formatSolveTime(secs: ao5.accountedSolves[index].time))
                                                                .font(.system(size: 17, weight: .regular, design: .default))
                                                                .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                                .multilineTextAlignment(.leading)
                                                                .padding(.bottom, 2)
                                                        }
                                                    }
                                                    

                                                    
                                                } else {
                                                    Text("N/A")
                                                        .font(.system(size: 28, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray2))
                                                    
                                                    Spacer()
                                                }
                                            }
                                            .onTapGesture {
                                                if ao5 != nil {
                                                    presentedAvg = ao5
                                                }
                                            }
                                            .padding(.top, 10)
                                            .padding(.bottom, 10)
                                            .padding(.leading, 12)
                                            
                                            
                                            
                                            Spacer()
                                        }
                                        .frame(height: 215)
                                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                        .onTapGesture {
                                            print("best ao5 pressed")
                                        }
                                         
                                    }
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                            }
                            
                            Divider()
                                .frame(width: UIScreen.screenWidth/2)
                                .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
                            
                            /// time trend graph
                            VStack {
                                ZStack {
                                    VStack {
                                        HStack {
                                            Text("TIME TREND")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding([.vertical, .leading], 12)
                                    
                                    TimeTrend(data: timesByDate, title: nil, style: ChartStyle(.white, .black, Color.black.opacity(0.24)))
                                        .frame(width: UIScreen.screenWidth - (2 * 16) - (2 * 12))
                                        .padding(.horizontal, 12)
                                        .drawingGroup()
                                }
                            }
                            .frame(height: 300)
                            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                            .padding(.horizontal)
                            .onTapGesture {
                                print("time trend pressed")
                            }
                            
                            
                            /// time distrbution graph
                            VStack {
                                ZStack {
                                    VStack {
                                        HStack {
                                            Text("TIME DISTRIBUTION")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding([.vertical, .leading], 12)
                                }
                            }
                            .frame(height: 300)
                            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                            .padding(.horizontal)
                            .onTapGesture {
                                print("time distribution pressed")
                            }
                        }
                    }
                    
                }
                .navigationTitle("Your Solves")
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
                .sheet(item: $presentedAvg) {item in
                    StatsDetail(solves: item, session: currentSession)
                }
                .sheet(isPresented: $showBestSinglePopup) {
                    SolvePopupView(solve: bestSingle!, currentSolve: nil, timeListManager: nil) // TODO make delete work from here
                    // maybe pass stats object and make it remove min
                }
            }
        }
    }
}

/*
struct StatsView_Previews: PreviewProvider {
    static let context = PersistenceController.shared.container.viewContext
    @State static var session: Sessions = {
        let item = Sessions(context: context)
        item.name = "Preview Session"
//        for _ in 0..<999 {
//            let solve = Solves(context: context)
//            solve.time = Double.random(in: 10...600)
//            solve.date = Date(timeIntervalSince1970: TimeInterval.random(in: 0...Date().timeIntervalSince1970))
//            solve.session = item
//        }
        return item
    }()
    static var previews: some View {
        StatsView(currentSession: $session, managedObjectContext: context)
            .environment(\.managedObjectContext, context)
    }
}
*/
