//
//  SessionsView.swift
//  txmer
//
//  Created by Reagan Bohan on 11/25/21.
//

import SwiftUI
import CoreData

import SwiftUICharts



extension View {
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(LinearGradient(gradient: .init(colors: colors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
            .mask(self)
    }
}


@available(iOS 15.0, *)
struct StatsView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let gradientColour: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 236/255, green: 74/255, blue: 134/255), Color(red: 136/255, green: 94/255, blue: 191/255)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing)
    
    let columns = [
        // GridItem(.adaptive(minimum: 112), spacing: 11)
        GridItem(spacing: 10),
        GridItem(spacing: 10)
    ]
    
     
    
    @Binding var currentSession: Sessions?
    
    
//    let stats = Stats(currentSession: $currentSession, managedObjectContext: managedObjectContext)
//        .environment(\.managedObjectContext, managedObjectContext)
    
    let ao5: (Double, ArraySlice<Solves>)?
    let ao12: (Double, ArraySlice<Solves>)?
    let ao100: (Double, ArraySlice<Solves>)?
    
    
    let bestSingle: Solves?
    let sessionMean: Double?
    
    
    let stats: Stats
    init(currentSession: Binding<Sessions?>, managedObjectContext: NSManagedObjectContext) {
        self._currentSession = currentSession
        
        
        stats = Stats(currentSession: currentSession.wrappedValue!, managedObjectContext: managedObjectContext)
        
        self.ao5 = stats.getBestMovingAverageOf(5)
        self.ao12 = stats.getBestMovingAverageOf(12)
        self.ao100 = stats.getBestMovingAverageOf(100)
        self.bestSingle = stats.getMin()
        self.sessionMean = stats.getSessionMean()
    }
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                
                
                
                
                ScrollView() {
                    
                    LineChart()
                        .data([1, 2, 3, 4, 5, 60])
                        .chartStyle(ChartStyle(backgroundColor: .white,
                                                           foregroundColor: [ColorGradient(.blue, .purple),
                                                                             ColorGradient(.orange, .red)]))
                    
                    
                    
                    
                    
                    
//                    ForEach(stats.solves, id: \.self) { solve in
//                        Text(formatSolveTime(secs: solve.time))
//                    }
                    
                    
//                    Text("generate random")
//                        .onTapGesture {
//                            for _ in 1..<100000 {
//                                let solveItem: Solves!
//
//                                solveItem = Solves(context: managedObjectContext)
//                                solveItem.date = Date()
//                                solveItem.session = currentSession
//                                solveItem.scramble = "sdlfikj"
//                                solveItem.scramble_type = 0
//                                solveItem.scramble_subtype = 0
//                                solveItem.time = Double.random(in: 1..<100)
//
//                            }
//                            do {
//                                try managedObjectContext.save()
//                            } catch {
//                                if let error = error as NSError? {
//                                    fatalError("Unresolved error \(error), \(error.userInfo)")
//                                }
//                            }
//
//
//                        }
//
//                    Text("stats button")
//                        .onTapGesture {
//                            print(stats.getMin().time)
//                            print(stats.getSessionMean())
//                            print(stats.getNumberOfSolves())
//                            print("\n\n\n")
//                            print(stats.getBestMovingAverageOf(5))
//                        }
                    
                    
                    /// this whole section make lazyvgrid because performance currently :trend_dwoin::"
                    VStack {
                        
                       
                        
                        VStack (spacing: 0) {
                            HStack (alignment: .center) {
                                Text(currentSession!.name!)
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                    .foregroundColor(Color(UIColor.systemGray))
                                Spacer()
                                
                                Text(puzzle_types[Int(currentSession!.scramble_type)].name) // TODO playground
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(UIColor.systemGray))
                            }
                        }
                        .padding(.top, -6)
                        .padding(.bottom, -2)
                        
                        VStack (spacing: 10) {
                            
                            HStack (spacing: 10) {
                                VStack (spacing: 10) {
                                    
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("BEST SINGLE")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(UIColor.systemGray6))
                                                .padding(.bottom, 4)
                                            
//                                            Text("88:88:888")
                                            
                                            if bestSingle != nil {
                                                Text(String(formatSolveTime(secs: bestSingle!.time)))
                                                    .font(.system(size: 34, weight: .bold, design: .default))
                                                    .foregroundColor(.white)
                                            } else {
                                                Text("N/A")
                                                    .font(.system(size: 28, weight: .medium, design: .default))
                                                    .foregroundColor(Color(UIColor.systemGray5))
                                            }
                                            
                                            
                                        }
                                        .padding(.top)
                                        .padding(.bottom, 12)
                                        .padding(.leading, 12)
                                        
                                        Spacer()
                                    }
                                    .frame(height: 75)
                                    .background(gradientColour                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                    .onTapGesture {
                                        print("best single pressed!")
                                    }
                                    
                                    
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            
                                            VStack {
                                                Text("BEST AO12")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(UIColor.systemGray))
                                                    .padding(.leading, 12)
                                                
                                                if ao12 != nil {
                                                    Text(String(formatSolveTime(secs: ao12!.0)))
                                                    .font(.system(size: 34, weight: .bold, design: .default))
                                                    .foregroundColor(.black)
                                                    .padding(.leading, 12)
                                                } else {
                                                    Text("N/A")
                                                        .font(.system(size: 28, weight: .medium, design: .default))
                                                        .foregroundColor(Color(UIColor.systemGray2))
//                                                        .padding(.leading, -16)
                                                    
                                                }
                                            }
                                            .onTapGesture {
                                                print("best ao12 pressed")
                                            }
                                            
                                            
                                            Divider()
                                                .padding(.leading, 12)
                                                .padding(.bottom, 4)
                                            
                                            
                                            
                                            VStack {
                                                Text("BEST AO100")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(UIColor.systemGray))
                                                    .padding(.leading, 12)
                                                
                                                if ao100 != nil {
                                                    Text(String(formatSolveTime(secs: ao100!.0)))
                                                        .font(.system(size: 34, weight: .bold, design: .default))
                                                        .foregroundColor(.black)
                                                        .padding(.leading, 12)
                                                } else {
                                                    Text("N/A")
                                                        .font(.system(size: 28, weight: .medium, design: .default))
                                                        .foregroundColor(Color(UIColor.systemGray2))
//                                                        .padding(.leading, -16)
                                                        
                                                }
                                                
                                            }
                                            .onTapGesture {
                                                print("best ao100 pressed")
                                            }
                                            
                                            
                                        }
                                        
                                        
                                        Spacer()
                                        
                                    }
                                    .frame(height: 130)
                                    .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("SESSION MEAN")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(UIColor.systemGray))
                                                .padding(.bottom, 4)
                                            
                                            
                                            if sessionMean != nil {
                                                Text(String(formatSolveTime(secs: sessionMean!)))
                                                    .font(.system(size: 34, weight: .bold, design: .default))
                                                    .foregroundColor(.black)
                                            } else {
                                                Text("N/A")
                                                    .font(.system(size: 28, weight: .medium, design: .default))
                                                    .foregroundColor(Color(UIColor.systemGray2))
                                            }
                                            
                                            
                                        }
                                        .padding(.top)
                                        .padding(.bottom, 12)
                                        .padding(.leading, 12)
                                        
                                        Spacer()
                                    }
                                    .frame(height: 75)
                                    .background(Color.white                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                                .frame(minWidth: 0, maxWidth: .infinity)
                                
                                VStack (spacing: 10) {
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("BEST AO5")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(UIColor.systemGray))
                                                .padding(.bottom, 4)
                                            
//                                            Text("6.142")
                                            
                                            
                                            if ao5 != nil {
                                                Text(String(formatSolveTime(secs: ao5!.0)))
                                                    .font(.system(size: 34, weight: .bold, design: .default))
                                                    .gradientForeground(colors: [Color(red: 236/255, green: 74/255, blue: 134/255), Color(red: 136/255, green: 94/255, blue: 191/255)])
                                                
                                                Spacer()
                                                
                                                
                                                ForEach((0...4), id: \.self) {
                                                    Text(String(formatSolveTime(secs: ao5!.1[$0].time)))
                                                        .font(.system(size: 17, weight: .regular, design: .default))
                                                        .foregroundColor(.black)
                                                        .multilineTextAlignment(.leading)
                                                }
                                                
                                            } else {
                                                Text("N/A")
                                                    .font(.system(size: 28, weight: .medium, design: .default))
                                                    .foregroundColor(Color(UIColor.systemGray2))
                                                
                                                Spacer()
                                            }
                                            
                                            
                                            
                                            //                                        gradientColour.mask(Text("6.142").font(.system(size: 34, weight: .bold, design: .default)))
                                            
                                            

                                            
                                            /// TODO: make text gray when they are () and AUTO BRACKET
                                                
                                            
                                        }
                                        //                                    .padding(.top)
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                                        .padding(.leading, 12)
                                        
                                        
                                        
                                        Spacer()
                                    }
                                    .frame(height: 215)
                                    .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                                    .onTapGesture {
                                        print("best ao5 pressed")
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("NUMBER OF SOLVES")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(UIColor.systemGray))
                                                .padding(.bottom, 4)
                                            
                                            Text(String(stats.getNumberOfSolves()))
                                                .font(.system(size: 34, weight: .bold, design: .default))
                                                .foregroundColor(.black)
                                        }
                                        .padding(.top)
                                        .padding(.bottom, 12)
                                        .padding(.leading, 12)
                                        
                                        Spacer()
                                    }
                                    .frame(height: 75)
                                    .background(Color.white                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                                .frame(minWidth: 0, maxWidth: .infinity)
                                
                                
                            }
                                                    
                            //                        LazyVGrid(columns: columns, spacing: 10) {
                            //                            Text("yes")
                            //                        }
                            
                            
                            
                            
                            
                            
                            
                            VStack {
                                VStack {
                                    
                                    
                                    
                                    ZStack {
                                        HStack {
                                            Text("TIME TREND")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(UIColor.systemGray))
                                                .padding(.bottom, 4)
                                            
                                            Spacer()
                                        }
                                        
                                                                                    
                                        
                                    }
                                    
                                    
                                    
                                    /*
                                    MultiLineChartView(data: [([8,32,11,23,40,28], GradientColors.green), ([90,99,78,111,70,60,77], GradientColors.purple), ([34,56,72,38,43,100,50], GradientColors.orngPink)], title: "Title")
                                     */
                                     // legend is optional
//                                    BarChart()
//                                            .data([1, 2, 3, 4, 5, 6])
//                                            .chartStyle(ChartStyle(backgroundColor: .white,
//                                                                   foregroundColor: ColorGradient(.blue, .purple)))
                                    
//                                        .data(stats.solves.sorted(by: { $0.date! < $1.date! }).map { $0.time })
                                        
                                 
                                    
//                                    Spacer()
                                    
                                }
                                .padding(.top, 12)
                                .padding(.bottom, 12)
                                .padding(.leading, 12)
                                .padding(.trailing, 12)
                            }
                            .frame(height: 200)
                            .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                            .onTapGesture {
                                print("time trend pressed")
                            }
                            
                            
                            
                            
                            VStack {
                                VStack {
                                    HStack {
                                        Text("TIME DISTRIBUTION")
                                            .font(.system(size: 13, weight: .medium, design: .default))
                                            .foregroundColor(Color(UIColor.systemGray))
                                            .padding(.bottom, 4)
                                        
                                        Spacer()
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .padding(.top, 12)
                                .padding(.bottom, 12)
                                .padding(.leading, 12)
                            }
                            .frame(height: 200)
                            .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                            .padding(.bottom, 16)
                            .onTapGesture {
                                print("time distribution pressed")
                            }
                            
                            
                            
                            
                        }
                        .navigationTitle("Your Solves")
//                        .padding(.leading)
//                        .padding(.trailing)
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .frame(height: 50)
                        
                }
            }
        }
    }
}

