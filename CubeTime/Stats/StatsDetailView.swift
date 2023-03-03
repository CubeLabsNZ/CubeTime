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

    @State var showSolve = false
    @State var solveToShow: Solves?

    let solves: CalculatedAverage
    let session: Sessions
    
    private let detailDateFormat: DateFormatter
    
    private let isCurrentCompSimAverage: Bool

    
    init(solves: CalculatedAverage, session: Sessions) {
        self.solves = solves
        self.session = session
        
        self.detailDateFormat = DateFormatter()
        detailDateFormat.locale = Locale(identifier: "en_US_POSIX")
        detailDateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        detailDateFormat.dateFormat = "h:mm a, dd/MM/yyyy"
        
        self.isCurrentCompSimAverage = solves.name == "Current Average"
    }
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("base")
                    .ignoresSafeArea()
                
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
                                        if (SessionTypes(rawValue: session.session_type)! == .playground) {
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
                                        .font(FontManager.mono15)
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
                                    .font(FontManager.mono13)
                                    .foregroundColor(Color("indent0"))
                            }
                            .padding(.vertical, -4)
                            
                            // BUTTONS
                            
                            HStack(spacing: 8) {
                                HierarchialButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
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
                                                    .foregroundColor(Color.accentColor)
                                                   
                                            }
                                            
                                            
                                            Image(systemName: "checkmark")
                                                .font(.subheadline.weight(.semibold))
                                                .clipShape(Rectangle().offset(x: self.offsetValue))
                                        }
                                        .frame(width: 20)
                                        
                                        Text("Copy Average")
                                    }
                                }
                                
                                HierarchialButton(type: .coloured, size: .large, expandWidth: true, onTapRun: {
//                                    shareSolve(solve: solve)
                                }) {
                                    Label("Share Average", systemImage: "square.and.arrow.up")
                                }
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
                                                .font(.subheadline.weight(.bold))
                                                .foregroundColor(Color.accentColor)
                                            
                                            if solves.trimmedSolves!.contains(solve) {
                                                Text("(" + formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!) + ")")
                                                    .font(.body.weight(.bold))
                                                    .foregroundColor(Color("grey"))
                                                
                                            } else {
                                                Text(formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!))
                                                    .font(.body.weight(.bold))
                                            }
                                            
                                            Spacer()
                                            
                                            
                                            Text(solve.date ?? Date(timeIntervalSince1970: 0), formatter: detailDateFormat)
                                                .font(FontManager.mono15)
                                                .foregroundColor(Color("grey"))
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
                                        .font(FontManager.mono16)
                                        .padding(.bottom, (index != solves.accountedSolves!.indices.last!) ? 8 : 0)
                                    }
                                    .onTapGesture {
                                        solveToShow = solve
                                        showSolve = true
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
                            Button {
                                dismiss()
                            } label: {
                                Text("Done")
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(solves.name == "Comp Sim Solve" ? "Comp Sim" : solves.name)
                }
            }
        }
    }
}
