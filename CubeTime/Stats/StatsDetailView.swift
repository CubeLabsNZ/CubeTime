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
                        .font(.callout.weight(.semibold))
                        .foregroundColor(Color("accent"))
                    
                    
                    Group {
                        if isTrimmed {
                            Text("(" + solve.timeText + ")")
                                .offset(y: 1)
                                .foregroundColor(Color("grey"))
                            
                        } else {
                            Text(solve.timeText)
                                .offset(y: 1)
                        }
                    }
                    .recursiveMono(style: .title3, weight: .bold)
                    
                    
                    Spacer()
                    
                    if let date = solve.date {
                        Text(date, formatter: getSolveDateFormatter(date))
                            .font(.subheadline)
                            .foregroundColor(Color("grey"))
                    } else {
                        Text("...")
                            .font(.subheadline)
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
                .recursiveMono(size: 16, weight: .regular)
                .padding(.top, 4)
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
                            Text(formatSolveTime(secs: solves.average!, penalty: solves.totalPen))
                                .recursiveMono(style: .largeTitle, weight: .bold)
                            
                            Spacer()
                        }
                        
                        CTDivider()
                        
                        HStack {
                            HStack(alignment: .center, spacing: 4) {
                                if (SessionType(rawValue: session.sessionType)! == .playground) {
                                    Text("Playground")
                                    
                                    Image(systemName: "square.on.square")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                    
                                } else {
                                    Image(PUZZLE_TYPES[Int(session.scrambleType)].imageName)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                    
                                    Text(PUZZLE_TYPES[Int(session.scrambleType)].name)
                                }
                            }
                            
                            Text("|")
                                .offset(y: -1)  // slight offset of bar
                            
                            Text(solves.name == "Comp Sim Solve" ? "compsim" : solves.name.lowercased())

                            
                            Spacer()
                        }
                        .font(.subheadline.weight(.medium))
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                    .padding(.top)
                    
                    Text("CubeTime")
                        .recursiveMono(size: 13)
                        .foregroundColor(Color("grey").opacity(0.36))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.vertical, -4)
                    
                    let shareStr = getShareStr(solves: solves)
                    
                    HStack(spacing: 8) {
                        CTCopyButton(toCopy: shareStr, buttonText: "Copy Average")
                        
                        CTShareButton(toShare: shareStr, buttonText: "Share Average")
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TIMES")
                            .font(.subheadline.weight(.semibold))
                        
                        CTDivider()
                        
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
                    CTDoneButton(onTapRun: {
                        dismiss()
                    })
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Stats Detail")
            
            .sheet(item: $solveDetail) { item in
                TimeDetailView(for: item, currentSolve: $solveDetail)
            }
        }
    }
}
