//
//  StatsDetailView.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//

import SwiftUI

struct StatsDetailView: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager

    @Environment(\.dismiss) var dismiss

    @State var offsetValue: CGFloat = -25

    @State var solveDetail: Solves?

    let solves: CalculatedAverage
    let session: Sessions
    
    private let isCurrentCompSimAverage: Bool

    @State private var showShareSheet: Bool = false
    
    
    init(solves: CalculatedAverage, session: Sessions) {
        self.solves = solves
        self.session = session
        
        self.isCurrentCompSimAverage = solves.name == "Current Average"
    }
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundColour()
                
                GeometryReader { geo in
                    ScrollView {
                        VStack {
                            VStack(spacing: 4) {
                                HStack(alignment: .bottom) {
                                    Text(formatSolveTime(secs: solves.average!, penType: solves.totalPen))
                                        .font(.largeTitle.weight(.bold))
                                    
                                    Spacer()
                                    
                                    // if playground, show playground, otherwise show puzzle type
                                    
                                    HStack(alignment: .center) {
                                        if (SessionType(rawValue: session.session_type)! == .playground) {
                                            Text("Playground")
                                                .font(.title3.weight(.semibold))
                                            
                                            Image(systemName: "square.on.square")
                                                .resizable()
                                                .frame(width: 22, height: 22)

                                        } else {
                                            Text(puzzle_types[Int(session.scramble_type)].name)
                                                .font(.title3.weight(.semibold))
                                            
                                            Image(puzzle_types[Int(session.scramble_type)].name)
                                                .resizable()
                                                .frame(width: 22, height: 22)

                                        }
                                        
                                    }
                                    .offset(y: -4)
                                }
                                
                                ThemedDivider()
                                
                                HStack {
                                    Text(solves.name == "Comp Sim Solve" ? "COMPSIM" : solves.name.uppercased())
                                        .recursiveMono(fontSize: 15, weight: .regular)
                                        .foregroundColor(Color("grey"))
                                    
                                    Spacer()
                                }
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            .padding(.top)
                            
                            HStack {
                                Spacer()
                                
                                Text("CubeTime.")
                                    .recursiveMono(fontSize: 13, weight: .regular)
                                    .foregroundColor(Color("indent0"))
                            }
                            .padding(.vertical, -4)
                            
                            // BUTTONS
                            
                            HStack(spacing: 8) {
                                HierarchicalButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
                                    copySolve(solves: solves)
                                    
                                    withAnimation(Animation.customSlowSpring.delay(0.25)) {
                                        self.offsetValue = 0
                                    }
                                    
                                    withAnimation(Animation.customFastEaseOut.delay(2.25)) {
                                        self.offsetValue = -25
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        ZStack {
                                            if self.offsetValue != 0 {
                                                Image(systemName: "doc.on.doc")
                                                    .font(.subheadline.weight(.medium))
                                                    .foregroundColor(Color("accent"))
                                                   
                                            }
                                            
                                            
                                            Image(systemName: "checkmark")
                                                .font(.subheadline.weight(.semibold))
                                                .clipShape(Rectangle().offset(x: self.offsetValue))
                                        }
                                        .frame(width: 20)
                                        
                                        Text("Copy Average")
                                    }
                                }
                                
                                HierarchicalButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
                                    self.showShareSheet = true
                                }) {
                                    Label("Share Average", systemImage: "square.and.arrow.up")
                                }
                                .background(
                                    ShareSheetViewController(isPresenting: self.$showShareSheet) {
                                        let toShare: String = getShareStr(solves: solves)
                                        
                                        let activityViewController = UIActivityViewController(activityItems: [toShare], applicationActivities: nil)
                                        activityViewController.isModalInPresentation = true
                                        
                                        if (UIDevice.deviceIsPad) {
                                            activityViewController.popoverPresentationController?.sourceView = UIView()
                                        }
                                        
                                        activityViewController.completionWithItemsHandler = { _, _, _, _ in
                                            self.showShareSheet = false
                                        }
                                        
                                        return activityViewController
                                    }
                                )
                            }
                            .padding(.top, 16)
                            
                            // END BUTTONS
                            
                            
                            
                            
                            
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TIMES")
                                    .font(.subheadline.weight(.semibold))
                                
                                ThemedDivider()
                                
                                ForEach(Array(zip(solves.accountedSolves!.indices, solves.accountedSolves!.sorted(by: { $0.date! > $1.date! }))), id: \.0) { index, solve in
                                    VStack(spacing: 0) {
                                        HStack(alignment: .bottom) {
                                            Text("\(index+1).")
                                                .font(.callout.weight(.bold))
                                                .foregroundColor(Color("accent"))
                                            
                                            if solves.trimmedSolves!.contains(solve) {
                                                Text("(" + formatSolveTime(secs: solve.time, penType: Penalty(rawValue: solve.penalty)!) + ")")
                                                    .offset(y: 1)
                                                    .font(.title3.weight(.bold))
                                                    .foregroundColor(Color("grey"))
                                                
                                            } else {
                                                Text(formatSolveTime(secs: solve.time, penType: Penalty(rawValue: solve.penalty)!))
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
                                            if solve.scramble_type == 7 {
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
                                        .padding(.top, 4)
                                        .recursiveMono(fontSize: 17, weight: .regular)
                                        .padding(.bottom, (index != solves.accountedSolves!.indices.last!) ? 8 : 0)
                                    }
                                    .onTapGesture {
                                        solveDetail = solve
                                    }
                                }

                                
                                
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color("overlay1")))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 48)
                    }
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
    }
}
