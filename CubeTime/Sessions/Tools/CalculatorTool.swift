//
//  AverageCalculatorTool.swift
//  CubeTime
//
//  Created by Tim Xie on 10/03/23.
//

import SwiftUI

enum CalculatorType: String, Equatable, CaseIterable {
    case average = "Average"
    case mean = "Mean"
}

struct SimpleSolve: Comparable, Hashable {
    let time: Double
    let penalty: Penalty
    
    var timeIncPen: Double {
        get {
            return self.time + (self.penalty == Penalty.plustwo ? 2 : 0)
        }
    }
    
    public static func < (lhs: SimpleSolve, rhs: SimpleSolve) -> Bool {
        return lhs.timeIncPen < rhs.timeIncPen
    }
}

struct CalculatorTool: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    
    @State private var calculatorType: CalculatorType = .average
    @State private var currentTime: String = ""
    
    @State private var solves: [SimpleSolve] = []
    @State var editNumber: Int?

    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                BackgroundColour()
                
                VStack {
                    ToolHeader(name: tools[3].name, image: tools[3].iconName, content: {
                        Picker("", selection: $calculatorType) {
                            ForEach(CalculatorType.allCases, id: \.self) { t in
                                Text(t.rawValue)
                                    .tag(t)
                            }
                        }
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    
                    VStack {
                        if (solves.count > 0) {
                            VStack {
                                ForEach(solves, id: \.self) { solve in
                                    if let solve = solve {
                                        HStack {
                                            Text(formatSolveTime(secs: solve.time, penType: solve.penalty))
                                            
                                            Spacer()
                                            
                                            HierarchicalButton(type: .mono, size: .medium, onTapRun: {
                                                
                                            }) {
                                                Image(systemName: "pencil")
                                                    .imageScale(.medium)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if (solves.count == 5) {
                            Text(formatSolveTime(secs: StopwatchManager.calculateAverage(forSortedSolves: solves, count: 5, trim: 1)))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Group {
                                if (solves.count < 5) {
                                    Text("SOLVE \(solves.count)")
                                } else {
                                    Text("NEW AVERAGE?")
                                }
                            }
                            .foregroundStyle(getGradient(gradientSelected: 0, isStaticGradient: true))
                            .font(.footnote.weight(.semibold))
                            .padding(.top, 10)
                            
                            if (solves.count < 5) {
                                TextField("0.00", text: $currentTime)
                                    .padding(.vertical, 6)
                                    .recursiveMono(fontSize: 17, weight: .semibold)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color("dark"))
                                    .background(Color("indent1"))
                                    .cornerRadius(6)
                                    .modifier(TimeMaskTextField(text: $currentTime))
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Button("Done") {
                                                if let time = timeFromStr(currentTime) {
                                                    let solve = SimpleSolve(time: time, penalty: Penalty.none)
                                                    currentTime = ""
                                                }
                                            }
                                        }
                                    }
                                    .padding([.horizontal, .bottom], 10)
                            } else {
                                HierarchicalButton(type: .coloured, size: .medium, expandWidth: true, onTapRun: {
                                    self.solves = []
                                }) {
                                    Label("Start Over", systemImage: "arrow.clockwise")
                                        .imageScale(.medium)
                                }
                            }
                        }
                        .frame(width: geo.size.width / 2)
                        .background(Color("overlay0"))
                        .cornerRadius(8)
                        .shadowDark(x: 0, y: 2)
                        .padding(.bottom, (geo.size.height - 50) / 2)
                    }
                    .padding(.horizontal)
                    .ignoresSafeArea(.keyboard)
                }
            }
        }
    }
}
