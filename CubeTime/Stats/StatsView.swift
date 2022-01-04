import SwiftUI
import CoreData


extension View {
    public func gradientForeground(gradientSelected: Int) -> some View {
        self.overlay(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected))
            .mask(self)
    }
}



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
    let timesBySpeed: [Double]
    
    let bestSingle: Solves?
    let sessionMean: Double?
    
    let compSimCount: Int
    
    let reachedTargets: Int
    
    
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
        
        self.timesByDate = stats.solvesByDate.map { $0.time }
        self.timesBySpeed = stats.solves.map { $0.time }
        
        
        self.compSimCount = stats.getNumberOfAverages()
        self.reachedTargets = stats.getReachedTargets()
        
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
                            /// first bunch of blocks
                            if currentSession.session_type != SessionTypes.compsim.rawValue {
                                VStack(spacing: 10) {
                                    HStack (spacing: 10) {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("CURRENT STATS")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                .padding(.leading, 12)
                                                .padding(.top, 10)
                                            
                                            VStack (alignment: .leading, spacing: 6) {
                                                HStack {
                                                    VStack (alignment: .leading, spacing: -4) {
                                                        
                                                        Text("AO5")
                                                            .font(.system(size: 13, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray))
                                                            .padding(.leading, 12)
                                                        
                                                        if let currentAo5 = currentAo5 {
                                                            Text(String(formatSolveTime(secs: currentAo5.average ?? 0, penType: currentAo5.totalPen)))
                                                                .font(.system(size: 24, weight: .bold, design: .default))
                                                                .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                                .padding(.leading, 12)
                                                                .modifier(DynamicText())
                                                            
                                                        } else {
                                                            Text("N/A")
                                                                .font(.system(size: 20, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor:.systemGray2))
                                                                .padding(.leading, 12)
                                                            
                                                        }
                                                    }
                                                    
                                                    Spacer()
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    if currentAo5 != nil {
                                                        presentedAvg = currentAo5
                                                    }
                                                }
                                                
                                                HStack {
                                                    VStack (alignment: .leading, spacing: -4) {
                                                        Text("AO12")
                                                            .font(.system(size: 13, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray))
                                                            .padding(.leading, 12)
                                                        
                                                        if let currentAo12 = currentAo12 {
                                                            Text(String(formatSolveTime(secs: currentAo12.average ?? 0, penType: currentAo12.totalPen)))
                                                                .font(.system(size: 24, weight: .bold, design: .default))
                                                                .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                                .padding(.leading, 12)
                                                                .modifier(DynamicText())
                                                            
                                                            
                                                        } else {
                                                            Text("N/A")
                                                                .font(.system(size: 20, weight: .medium, design: .default))
                                                                .foregroundColor(Color(uiColor: .systemGray2))
                                                                .padding(.leading, 12)
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                    Spacer()
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    if currentAo12 != nil {
                                                        presentedAvg = currentAo12
                                                    }
                                                }
                                                
                                                HStack {
                                                    VStack (alignment: .leading, spacing: -4) {
                                                        Text("AO100")
                                                            .font(.system(size: 13, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray))
                                                            .padding(.leading, 12)
                                                        
                                                        if let currentAo100 = currentAo100 {
                                                            Text(String(formatSolveTime(secs: currentAo100.average ?? 0, penType: currentAo100.totalPen)))
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
                                                    
                                                    
                                                    Spacer()
                                                    
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    if currentAo100 != nil {
                                                        presentedAvg = currentAo100
                                                    }
                                                }
                                            }
                                            .padding(.bottom, 8)
                                        }
                                        .frame(height: 160)
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .background(Color(uiColor: .systemGray5).clipShape(RoundedRectangle(cornerRadius:16)))
                                        
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
                                                            .modifier(DynamicText())
                                                        
                                                        
                                                        
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
                                            
                                            VStack (alignment: .leading, spacing: 0) {
                                                HStack {
                                                    VStack (alignment: .leading, spacing: 0) {
                                                        Text("BEST AO12")
                                                            .font(.system(size: 13, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray))
                                                            .padding(.leading, 12)
                                                        
                                                        if let ao12 = ao12 {
                                                            Text(String(formatSolveTime(secs: ao12.average ?? 0, penType: ao12.totalPen)))
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
                                                    
                                                    Spacer()
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    if ao12 != nil {
                                                        presentedAvg = ao12
                                                    }
                                                }
                                                
                                                Divider()
                                                    .padding(.leading, 12)
                                                    .padding(.vertical, 4)
                                                
                                                HStack {
                                                    VStack (alignment: .leading, spacing: 0) {
                                                        Text("BEST AO100")
                                                            .font(.system(size: 13, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray))
                                                            .padding(.leading, 12)
                                                        
                                                        if let ao100 = ao100 {
                                                            Text(String(formatSolveTime(secs: ao100.average ?? 0, penType: ao100.totalPen)))
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
                                                    
                                                    Spacer()
                                                }
                                                .contentShape(Rectangle())
                                                .onTapGesture {
                                                    if ao100 != nil {
                                                        presentedAvg = ao100
                                                    }
                                                }
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
                                                    
                                                    if let ao5 = ao5 {
                                                        Text(formatSolveTime(secs: ao5.average ?? 0, penType: ao5.totalPen))
                                                            .font(.system(size: 34, weight: .bold, design: .default))
                                                            .gradientForeground(gradientSelected: gradientSelected)
                                                        
                                                        Spacer()
                                                        
                                                        if let accountedSolves = ao5.accountedSolves {
                                                        
                                                            let alltimes = accountedSolves.map{timeWithPlusTwoForSolve($0)}
                                                            ForEach((0...4), id: \.self) { index in
                                                                if timeWithPlusTwoForSolve(accountedSolves[index]) == alltimes.min() || timeWithPlusTwoForSolve(accountedSolves[index]) == alltimes.max() {
                                                                    Text("("+formatSolveTime(secs: accountedSolves[index].time,
                                                                                             penType: PenTypes(rawValue: accountedSolves[index].penalty))+")")
                                                                        .font(.system(size: 17, weight: .regular, design: .default))
                                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                                        .multilineTextAlignment(.leading)
                                                                        .padding(.bottom, 2)
                                                                } else {
                                                                    Text(formatSolveTime(secs: accountedSolves[index].time,
                                                                                         penType: PenTypes(rawValue: accountedSolves[index].penalty)))
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
                                                        
                                                        
                                                        
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 28, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray2))
                                                        
                                                        Spacer()
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
                                                if ao5 != nil {
                                                    presentedAvg = ao5
                                                }
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Divider()
                                    .frame(width: UIScreen.screenWidth/2)
                                    .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
                            } else {
                                VStack (spacing: 10) {
                                    HStack (spacing: 10) {
                                        VStack (spacing: 10) {
                                            HStack {
                                                VStack (alignment: .leading, spacing: 0) {
                                                    Text("CURRENT AVG")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.bottom, 4)
                                                    
                                                    if let ao5 = currentAo5 {
                                                        Text(formatSolveTime(secs: ao5.average ?? 0, penType: ao5.totalPen))
                                                            .font(.system(size: 34, weight: .bold, design: .default))
                                                            .foregroundColor(colourScheme == .light ? .black : .white)
                                                            .modifier(DynamicText())
                                                        
                                                        Spacer()
                                                        
                                                        if let accountedSolves = ao5.accountedSolves {
                                                        
                                                            let alltimes = accountedSolves.map{timeWithPlusTwoForSolve($0)}
                                                            ForEach((0...4), id: \.self) { index in
                                                                if timeWithPlusTwoForSolve(accountedSolves[index]) == alltimes.min() || timeWithPlusTwoForSolve(accountedSolves[index]) == alltimes.max() {
                                                                    Text("("+formatSolveTime(secs: accountedSolves[index].time,
                                                                                             penType: PenTypes(rawValue: accountedSolves[index].penalty))+")")
                                                                        .font(.system(size: 17, weight: .regular, design: .default))
                                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                                        .multilineTextAlignment(.leading)
                                                                        .padding(.bottom, 2)
                                                                } else {
                                                                    Text(formatSolveTime(secs: accountedSolves[index].time,
                                                                                         penType: PenTypes(rawValue: accountedSolves[index].penalty)))
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
                                            
                                            HStack {
                                                VStack (alignment: .leading, spacing: 0) {
                                                    Text("AVERAGES")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.bottom, 4)
                                                    
                                                    
                                                    Text("\(compSimCount)")
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
                                            .onTapGesture {
                                                if bestSingle != nil {
                                                    showBestSinglePopup = true
                                                }
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        
                                        VStack (spacing: 10) {
                                            HStack {
                                                VStack (alignment: .leading, spacing: 0) {
                                                    Text("BEST SINGLE")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.bottom, 4)
                                                    
                                                    if bestSingle != nil {
                                                        Text(String(formatSolveTime(secs: bestSingle!.time)))
                                                            .font(.system(size: 34, weight: .bold, design: .default))
                                                            .gradientForeground(gradientSelected: gradientSelected)
                                                            .modifier(DynamicText())
                                                        
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
                                            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                            .onTapGesture {
                                                if bestSingle != nil {
                                                    showBestSinglePopup = true
                                                }
                                            }
                                            
                                            HStack {
                                                VStack (alignment: .leading, spacing: 0) {
                                                    Text("BEST AVG")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray6))
                                                        .padding(.bottom, 4)
                                                    
                                                    if let ao5 = ao5 {
                                                        Text(formatSolveTime(secs: ao5.average ?? 0, penType: ao5.totalPen))
                                                            .foregroundColor(colourScheme == .light ? .black : .white)
                                                            .font(.system(size: 34, weight: .bold, design: .default))
                                                            .modifier(DynamicText())
                                                        
                                                        Spacer()
                                                        
                                                        
                                                        if let accountedSolves = ao5.accountedSolves {
                                                            let alltimes = accountedSolves.map{timeWithPlusTwoForSolve($0)}
                                                            ForEach((0...4), id: \.self) { index in
                                                                if timeWithPlusTwoForSolve(accountedSolves[index]) == alltimes.min() || timeWithPlusTwoForSolve(accountedSolves[index]) == alltimes.max() {
                                                                    Text("("+formatSolveTime(secs: accountedSolves[index].time,
                                                                                             penType: PenTypes(rawValue: accountedSolves[index].penalty))+")")
                                                                        .font(.system(size: 17, weight: .regular, design: .default))
                                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                                        .multilineTextAlignment(.leading)
                                                                        .padding(.bottom, 2)
                                                                } else {
                                                                    Text(formatSolveTime(secs: accountedSolves[index].time,
                                                                                         penType: PenTypes(rawValue: accountedSolves[index].penalty)))
                                                                        .font(.system(size: 17, weight: .regular, design: .default))
                                                                        .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                                        .multilineTextAlignment(.leading)
                                                                        .padding(.bottom, 2)
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                        
                                                        
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 28, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray2))
                                                        
                                                        Spacer()
                                                    }
                                                }
                                                .padding(.top, 10)
                                                .padding(.bottom, 10)
                                                .padding(.leading, 12)
                                                
                                                
                                                
                                                Spacer()
                                            }
                                            .frame(height: 215)
                                            .background(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected)                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                            .onTapGesture {
                                                if ao5 != nil {
                                                    presentedAvg = ao5
                                                }
                                            }
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        
                                        
                                    }
                                    .padding(.horizontal)
                                }
                                
                                Divider()
                                    .frame(width: UIScreen.screenWidth/2)
                                    .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
                                
                                HStack(spacing: 10) {
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("TARGET")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                                .padding(.bottom, 4)
                                            
                                            Text(formatSolveTime(secs: (currentSession as! CompSimSession).target, dp: 2))
                                                .font(.system(size: 34, weight: .bold, design: .default))
                                                .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                            
                                                .modifier(DynamicText())
                                            
                                        }
                                        .padding(.top)
                                        .padding(.bottom, 12)
                                        .padding(.leading, 12)
                                        
                                        Spacer()
                                    }
                                    .frame(height: 75)
                                    .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                    .onTapGesture {
                                        if bestSingle != nil {
                                            showBestSinglePopup = true
                                        }
                                    }
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("REACHED")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                                .padding(.bottom, 4)
                                            
                                            if bestSingle != nil {
                                                Text("\(reachedTargets)/\(compSimCount)")
                                                    .font(.system(size: 34, weight: .bold, design: .default))
                                                    .foregroundColor(Color(uiColor: colourScheme == .light ? .black : .white))
                                                    .modifier(DynamicText())
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
                                    .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                }
                                .padding(.horizontal)
                                
                                HStack {
                                    VStack {
                                        HStack {
                                            Text("REACHED TARGETS")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                                .padding(.leading, 12)
                                                .padding(.top, 8)
                                            
                                            Spacer()
                                        }
                                        
                                        
                                        ReachedTargets(Float(reachedTargets)/Float(compSimCount))
                                            .padding(.bottom, 8)
                                            .padding(.horizontal, 12)
                                        
                                        Spacer()
                                    }
                                }
                                .frame(height: 55)
                                .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                .onTapGesture {
                                    if bestSingle != nil {
                                        showBestSinglePopup = true
                                    }
                                }
                                .padding(.horizontal)
                                
                                
                                Divider()
                                    .frame(width: UIScreen.screenWidth/2)
                                    .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
                            }
                            
                            
                            /// average phases if multiphase session
                            if SessionTypes(rawValue: currentSession.session_type)! == .multiphase {
                                VStack {
                                    ZStack {
                                        VStack {
                                            HStack {
                                                Text("AVERAGE PHASES")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(uiColor: .systemGray))
                                                Spacer()
                                            }
                                            
                                            if timesBySpeed.count >= 1 {
                                                VStack (spacing: 8) {
                                                    Capsule()
                                                        .frame(height: 10)
                                                    
                                                    ForEach(0...4, id: \.self) { phase in
                                                        HStack (spacing: 16) {
                                                            Circle()
                                                                .frame(width: 10, height: 10)
                                                            
                                                            HStack (spacing: 8) {
                                                                Text("Phase \(phase):")
                                                                    .font(.system(size: 17, weight: .medium))
                                                                
                                                                Text("1.50")
                                                                    .font(.system(size: 17))
                                                                
                                                                Text("(25%)")
                                                                    .foregroundColor(Color(uiColor: .systemGray))
                                                                    .font(.system(size: 17))
                                                            }
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                                }
                                                .padding(.horizontal, 2)
                                                .padding(.top, -2)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(12)
                                        
                                        if timesBySpeed.count == 0 {
                                            Text("not enough solves to\ndisplay graph")
                                                .font(.system(size: 17, weight: .medium, design: .monospaced))
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(Color(uiColor: .systemGray))
                                        }
                                    }
                                }
                                .frame(height: timesBySpeed.count == 0 ? 150 : 200)
                                .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
                                .padding(.horizontal)
                                .onTapGesture {
                                    print("average phases pressed")
                                }
                                
                                Divider()
                                    .frame(width: UIScreen.screenWidth/2)
                                    .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray))
                            }
                            
                            
                            
                            
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
                                        .offset(y: -5)
                                        .drawingGroup()
                                }
                            }
                            .frame(height: timesBySpeed.count < 2 ? 150 : 300)
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
                                    
                                    TimeDistribution(solves: timesBySpeed)
                                        .drawingGroup()
                                }
                            }
                            .frame(height: timesBySpeed.count < 4 ? 150 : 300)
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
                .sheet(item: $presentedAvg) { item in
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
