//
//  StatsDetailView.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//

import SwiftUI

struct StatsTimeList: View {
    @Binding var solveDetail: Solve?
    let calculatedAverage: CalculatedAverage
    
    var body: some View {
        ForEach(Array(zip(calculatedAverage.accountedSolves!.indices, calculatedAverage.accountedSolves!.sorted(by: { $0.date! > $1.date! }))), id: \.0) { index, solve in
            
            let isTrimmed = calculatedAverage.trimmedSolves!.contains(solve)
            VStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    Text("\(index+1).")
                        .font(.callout.weight(.bold))
                        .foregroundColor(Color("accent"))
                    
                    if isTrimmed {
                        Text("(" + solve.timeText + ")")
                            .offset(y: 1)
                            .font(.title3.weight(.bold))
                            .foregroundColor(Color("grey"))
                        
                    } else {
                        Text(solve.timeText)
                            .offset(y: 1)
                            .font(.title3.weight(.bold))
                    }
                    
                    
                    Spacer()
                    
                    if let date = solve.date {
                        Text(date, formatter: getSolveDateFormatter(date))
                            .recursiveMono(fontSize: 15, weight: .regular)
                            .foregroundColor(Color("grey"))
                    } else {
                        Text("...")
                            .recursiveMono(fontSize: 15, weight: .regular)
                            .foregroundColor(Color("grey"))
                    }
                }
                .padding(.top, 8)
                
                HStack {
                    if solve.scrambleType == 7 {
                        Text(solve.scramble ?? "Failed to load scramble")
                            .fixedSize(horizontal: true, vertical: false)
                            .multilineTextAlignment(.leading)
                        // WORKAROUND
                            .minimumScaleFactor(0.00001)
                            .scaledToFit()
                    } else {
                        Text(solve.scramble ?? "Failed to load scramble")
                    }
                    
                    Spacer()
                }
                .recursiveMono(fontSize: 17, weight: .regular)
                .padding(.bottom, (index != calculatedAverage.accountedSolves!.indices.last!) ? 8 : 0)
            }
            .onTapGesture {
                solveDetail = solve
            }
        }
    }
}

struct StatsDetailView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    
    @Environment(\.dismiss) var dismiss
    
    @State var solveDetail: Solve?
    
    let solves: CalculatedAverage
    
    
    var body: some View {
        let session = stopwatchManager.currentSession!
        NavigationView {
            ScrollView {
                VStack {
                    VStack(spacing: 4) {
                        HStack(alignment: .bottom) {
                            Text(formatSolveTime(secs: solves.average!, penType: solves.totalPen))
                                .font(.largeTitle.weight(.bold))
                            
                            Spacer()
                            
                            // if playground, show playground, otherwise show puzzle type
                            
                            HStack(alignment: .center) {
                                if (SessionType(rawValue: session.sessionType)! == .playground) {
                                    Text("Playground")
                                        .font(.title3.weight(.semibold))
                                    
                                    Image(systemName: "square.on.square")
                                        .resizable()
                                        .frame(width: 22, height: 22)
                                    
                                } else {
                                    Text(puzzle_types[Int(session.scrambleType)].name)
                                        .font(.title3.weight(.semibold))
                                    
                                    Image(puzzle_types[Int(session.scrambleType)].name)
                                        .resizable()
                                        .frame(width: 22, height: 22)
                                    
                                }
                                
                            }
                            .offset(y: -4)
                        }
                        
                        ThemedDivider()
                        
                        Text(solves.name == "Comp Sim Solve" ? "COMPSIM" : solves.name.uppercased())
                            .recursiveMono(fontSize: 15, weight: .regular)
                            .foregroundColor(Color("grey"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                    .padding(.top)
                    
                    Text("CubeTime.")
                        .recursiveMono(fontSize: 13)
                        .foregroundColor(Color("indent1"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.vertical, -4)
                    
                    let shareStr = getShareStr(solves: solves)
                    
                    HStack(spacing: 8) {
                        CopyButton(toCopy: shareStr, buttonText: "Copy Average")
                        
                        ShareButton(toShare: shareStr, buttonText: "Share Average")
                    }
                    .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TIMES")
                            .font(.subheadline.weight(.semibold))
                        
                        ThemedDivider()
                        
                        StatsTimeList(solveDetail: $solveDetail, calculatedAverage: solves)
                        
                        
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 48)
            }
            .background(
                BackgroundColour()
                    .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DoneButton(onTapRun: {
                        dismiss()
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(solves.name == "Comp Sim Solve" ? "Comp Sim" : solves.name)
            
            .sheet(item: $solveDetail) { item in
                TimeDetailView(for: item, currentSolve: $solveDetail)
            }
        }
    }
}
