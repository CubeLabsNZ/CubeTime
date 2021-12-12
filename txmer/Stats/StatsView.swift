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
        self.overlay(getGradient(gradientArray: CustomGradientColours.gradientColours))
            .mask(self)
    }
}



@available(iOS 15.0, *)
struct StatsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let columns = [
        // GridItem(.adaptive(minimum: 112), spacing: 11)
        GridItem(spacing: 10),
        GridItem(spacing: 10)
    ]
    
    @Binding var currentSession: Sessions
    
    
    //    let stats = Stats(currentSession: $currentSession, managedObjectContext: managedObjectContext)
    //        .environment(\.managedObjectContext, managedObjectContext)
    
    let ao5: (Double, [Solves])?
    let ao12: (Double, [Solves])?
    let ao100: (Double, [Solves])?
    
    let currentAo5: (Double, [Solves])?
    
    let timesByDate: [Double]
    
    let bestSingle: Solves?
    let sessionMean: Double?
    
    
    let stats: Stats
    init(currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext) {
        self._currentSession = currentSession
        
        
        stats = Stats(currentSession: currentSession.wrappedValue, managedObjectContext: managedObjectContext)
        
        self.ao5 = stats.getBestMovingAverageOf(5)
        self.ao12 = stats.getBestMovingAverageOf(12)
        self.ao100 = stats.getBestMovingAverageOf(100)
        
        self.currentAo5 = stats.getCurrentAverageOf(5)
        
        self.bestSingle = stats.getMin()
        self.sessionMean = stats.getSessionMean()
        
        self.timesByDate = stats.solvesByDate.map{$0.time}
        
    }
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
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
                                                    Text("CURRENT AVERAGES")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(.black)
                                                        .padding(.leading, 12)
                                                    
                                                    Spacer()
                                                    
                                                    Text("AO5")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if ao12 != nil {
                                                        Text(String(formatSolveTime(secs: currentAo5!.0)))
//                                                        Text("HI")
                                                            .font(.system(size: 24, weight: .bold, design: .default))
                                                            .foregroundColor(.black)
                                                            .padding(.leading, 12)
                                                            .onTapGesture {
                                                                print(stats.solvesByDate)
                                                            }
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 20, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor:.systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                }
                                                .onTapGesture {
                                                    print("current ao5")
                                                }
                                                .padding(.bottom, 6)
                                                
                                                VStack (alignment: .leading, spacing: -4) {
                                                    Text("AO12")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if ao100 != nil {
                                                        Text(String(formatSolveTime(secs: ao100!.0)))
                                                            .font(.system(size: 24, weight: .bold, design: .default))
                                                            .foregroundColor(.black)
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 20, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                    
                                                }
                                                .onTapGesture {
                                                    print("current ao12")
                                                }
                                                .padding(.bottom, 6)
                                                
                                                
                                                VStack (alignment: .leading, spacing: -4) {
                                                    Text("AO100")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if ao100 != nil {
                                                        Text(String(formatSolveTime(secs: ao100!.0)))
                                                            .font(.system(size: 24, weight: .bold, design: .default))
                                                            .foregroundColor(.black)
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 20, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                    
                                                }
                                                .onTapGesture {
                                                    print("current ao100")
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
                                                Text("NUMBER OF SOLVES")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(uiColor: .systemGray))
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
                                        
                                        HStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                Text("SESSION MEAN")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(uiColor: .systemGray))
                                                    .padding(.bottom, 4)
                                                
                                                
                                                if sessionMean != nil {
                                                    Text(String(formatSolveTime(secs: sessionMean!)))
                                                        .font(.system(size: 34, weight: .bold, design: .default))
                                                        .foregroundColor(.black)
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
                                        .background(Color.white                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                    }
                                    
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                            }
                            
                            Divider()
                                .frame(width: UIScreen.screenWidth/2)
                            
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
                                                        .foregroundColor(.white)
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
                                        .background(getGradient(gradientArray: CustomGradientColours.gradientColours)                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                        .onTapGesture {
                                            print("best single pressed!")
                                        }
                                        
                                        HStack {
                                            VStack (alignment: .leading, spacing: 0) {
                                                
                                                VStack (alignment: .leading, spacing: 0) {
                                                    Text("BEST AO12")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if ao12 != nil {
                                                        Text(String(formatSolveTime(secs: ao12!.0)))
                                                            .font(.system(size: 34, weight: .bold, design: .default))
                                                            .foregroundColor(.black)
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 28, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor:.systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                }
                                                .onTapGesture {
                                                    print("best ao12 pressed")
                                                }
                                                
                                                
                                                Divider()
                                                    .padding(.leading, 12)
                                                    .padding(.vertical, 4)
                                                
                                                
                                                
                                                VStack (alignment: .leading, spacing: 0) {
                                                    Text("BEST AO100")
                                                        .font(.system(size: 13, weight: .medium, design: .default))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                        .padding(.leading, 12)
                                                    
                                                    if ao100 != nil {
                                                        Text(String(formatSolveTime(secs: ao100!.0)))
                                                            .font(.system(size: 34, weight: .bold, design: .default))
                                                            .foregroundColor(.black)
                                                            .padding(.leading, 12)
                                                    } else {
                                                        Text("N/A")
                                                            .font(.system(size: 28, weight: .medium, design: .default))
                                                            .foregroundColor(Color(uiColor: .systemGray2))
                                                            .padding(.leading, 12)
                                                        
                                                    }
                                                    
                                                }
                                                .onTapGesture {
                                                    print("best ao100 pressed")
                                                }
                                                
                                                
                                            }
                                            
                                            
                                            Spacer()
                                            
                                        }
                                        .frame(height: 130)
                                        .background(Color(uiColor: .white).clipShape(RoundedRectangle(cornerRadius:16)))
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
                                        
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
                                                
                                                
                                                if ao5 != nil {
                                                    Text(formatSolveTime(secs: ao5!.0))
                                                        .font(.system(size: 34, weight: .bold, design: .default))
                                                        .gradientForeground(colors: [Color(red: 236/255, green: 74/255, blue: 134/255), Color(red: 136/255, green: 94/255, blue: 191/255)])
                                                    
                                                    Spacer()
                                                    
                                                    
                                                    ForEach((0...4), id: \.self) {
                                                            Text(formatSolveTime(secs: ao5!.1[$0].time))
                                                                .font(.system(size: 17, weight: .regular, design: .default))
                                                                .foregroundColor(.black)
                                                                .multilineTextAlignment(.leading)
                                                                .padding(.bottom, 2)
                                                        }
                                                    .onTapGesture {
                                                        
                                                        for thing in ao5!.1 {
                                                            print(thing.time)
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
                                        .background(Color(uiColor: .white).clipShape(RoundedRectangle(cornerRadius:16)))
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
                                    
                                    LineView(data: timesByDate, title: nil, style: ChartStyle(backgroundColor: .white, accentColor: getGradientColours(gradientArray: CustomGradientColours.gradientColours)[1], secondGradientColor: getGradientColours(gradientArray: CustomGradientColours.gradientColours)[0], textColor: .black, legendTextColor: .gray, dropShadowColor: Color.black.opacity(0.24)), legendSpecifier: "%.2g")
                                        .frame(width: UIScreen.screenWidth - (2 * 16) - (2 * 12))
                                        .padding(.horizontal, 12)
                                }
                            }
                            .frame(height: 300)
                            .background(Color(uiColor: .white).clipShape(RoundedRectangle(cornerRadius:16)))
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
                            .background(Color(uiColor: .white).clipShape(RoundedRectangle(cornerRadius:16)))
                            .padding(.horizontal)
                            .onTapGesture {
                                print("time distribution pressed")
                            }
                        }
                    }
                    
                }
                .navigationTitle("Your Solves")
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
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
