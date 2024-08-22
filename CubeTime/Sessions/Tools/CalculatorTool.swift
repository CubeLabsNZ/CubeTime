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
    var time: Double
    var penalty: Penalty
    
    var timeIncPen: Double {
        get {
            return self.time + (self.penalty == Penalty.plustwo ? 2 : 0)
        }
    }
    
    public static func < (lhs: SimpleSolve, rhs: SimpleSolve) -> Bool {
        if (lhs.penalty == .dnf) { return false }
        else if (rhs.penalty == .dnf) { return true }
        else {
            return lhs.timeIncPen < rhs.timeIncPen
        }
    }
}

struct CalculatorTool: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Namespace private var namespace
    
    @State private var calculatorType: CalculatorType = .average
    @State private var numberOfSolves: Int = 5
    @State private var currentTime: String = ""
    
    @State private var solves: [SimpleSolve] = []
    @State private var editNumber: Int?
    @State private var showEditFor: Int?
    
    @FocusState private var focused: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                BackgroundColour()
                    .ignoresSafeArea()
                
                VStack {
                    ToolHeader(name: tools[3].name, image: tools[3].iconName) {
                        HStack(spacing: 4) {
                            Picker("", selection: $calculatorType) {
                                ForEach(CalculatorType.allCases, id: \.self) { t in
                                    Text(t.rawValue)
                                        .tag(t)
                                }
                            }
                            
                            TextField("", value: $numberOfSolves, format: .number)
                                .fixedSize()
                                .textFieldStyle(.plain)
                                .keyboardType(.numberPad)
                                .foregroundColor(Color("accent"))
                                .padding(.trailing, 12)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        if (solves.count > 0) {
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(Array(zip(solves.indices, solves)), id: \.0) { index, solve in
                                        HStack {
                                            if (calculatorType == .average && solves.count > 3 && (solve.timeIncPen <= solves.sorted()[StopwatchManager.getTrimSizeEachEnd(numberOfSolves) - 1].timeIncPen || solve.timeIncPen >= solves.sorted()[solves.count - StopwatchManager.getTrimSizeEachEnd(numberOfSolves)].timeIncPen)) {
                                                Text("(" + formatSolveTime(secs: solve.time, penalty: solve.penalty) + ")")
                                                    .font(.body.weight(.semibold))
                                                    .foregroundColor(Color("grey"))
                                            } else {
                                                Text(formatSolveTime(secs: solve.time, penalty: solve.penalty))
                                                    .font(.body.weight(.semibold))
                                                    .foregroundColor(Color("dark"))
                                            }
                                            
                                            Spacer()
                                            
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                    .fill(Color("overlay0"))
                                                    .frame(width: showEditFor != nil && showEditFor == index ? nil : 35, height: 35)
                                                
                                                HStack {
                                                    if (showEditFor != nil && showEditFor == index) {
                                                        CTButton(type: .mono, size: .medium, square: true, hasShadow: false, onTapRun: {
                                                            self.solves[index].penalty = .plustwo
                                                            showEditFor = nil
                                                        }) {
                                                            Image("+2.label")
                                                                .imageScale(.medium)
                                                        }
                                                        
                                                        CTButton(type: .mono, size: .medium, square: true, hasShadow: false, onTapRun: {
                                                            self.solves[index].penalty = .dnf
                                                            showEditFor = nil
                                                        }) {
                                                            Image(systemName: "xmark.circle")
                                                                .imageScale(.medium)
                                                        }
                                                        
                                                        CTButton(type: .mono, size: .medium, square: true, hasShadow: false, onTapRun: {
                                                            self.solves[index].penalty = .none
                                                            showEditFor = nil
                                                        }) {
                                                            Image(systemName: "checkmark.circle")
                                                                .imageScale(.medium)
                                                        }
                                                        
                                                        CTDivider(isHorizontal: false)
                                                            .padding(.vertical, 8)
                                                        
                                                        CTButton(type: .coloured(Color("red")), size: .medium, square: true, hasShadow: false, hasBackground: false, onTapRun: {
                                                            self.solves.remove(at: index)
                                                            showEditFor = nil
                                                        }) {
                                                            Image(systemName: "trash")
                                                                .imageScale(.medium)
                                                        }
                                                    }
                                                    
                                                    CTButton(type: .mono, size: .medium, square: true, hasShadow: false, onTapRun: {
                                                        if (showEditFor != nil && showEditFor == index) {
                                                            editNumber = index
                                                            showEditFor = nil
                                                        } else {
                                                            if (self.showEditFor == index) {
                                                                self.showEditFor = nil
                                                            } else {
                                                                self.showEditFor = index
                                                            }
                                                        }
                                                    }) {
                                                        Image(systemName: "pencil")
                                                            .imageScale(.medium)
                                                    }
                                                }
                                                .padding(.horizontal, 2)
                                            }
                                            .clipped()
                                            .animation(.customDampedSpring, value: showEditFor)
                                            .fixedSize()
                                        }
                                    }
                                    .clipped()
                                }
                                .padding(10)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color("overlay1"))
                            )
                            .padding(.top)
                            .padding(.bottom, 4)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Group {
                                if let editNumber = editNumber {
                                    Text("EDITING SOLVE \(editNumber + 1)")
                                } else {
                                    if (solves.count < numberOfSolves) {
                                        Text("SOLVE \(solves.count + 1)")
                                    } else {
                                        Group {
                                            if (calculatorType == .average) {
                                                Text("= " + formatSolveTime(secs: StopwatchManager.calculateAverage(forSortedSolves: solves.sorted(), count: numberOfSolves, trim: 1),
                                                                            penalty: solves.sorted()[3].penalty == .dnf ? Penalty.dnf : Penalty.none ))
                                            } else {
                                                let mean: Average = StopwatchManager.calculateMean(of: numberOfSolves, for: solves)
                                                
                                                Text("= " + formatSolveTime(secs: mean.average, penalty: mean.penalty))
                                            }
                                        }
                                        .font(.title.weight(.bold))
                                    }
                                }
                            }
                            .foregroundStyle(Color("dark"))
                            .font(.callout.weight(.semibold))
                            .padding(.top, 10)
                            
                            Group {
                                if (solves.count < numberOfSolves || editNumber != nil) {
                                    TextField("0.00", text: $currentTime)
                                        .focused($focused)
                                        .padding(.vertical, 6)
                                        .recursiveMono(size: 20, weight: .semibold)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color("dark"))
                                        .background(Color("indent1"))
                                        .cornerRadius(6)
                                        .modifier(ManualInputTextField(text: $currentTime))
                                } else {
                                    CTButton(type: .coloured(nil), size: .medium, expandWidth: true, onTapRun: {
                                        self.solves = []
                                    }) {
                                        Label("Start Over", systemImage: "arrow.clockwise")
                                            .imageScale(.medium)
                                    }
                                }
                            }
                            .padding([.horizontal, .bottom], 10)
                        }
                        .frame(width: min(geo.size.width / 2, 300))
                        .background(Color("overlay0"))
                        .cornerRadius(8)
                        .shadowDark(x: 0, y: 2)
                        .animation(.customDampedSpring, value: solves.count)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, geo.size.height / 2.25)
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            HStack {
                                Button("Cancel") {
                                    focused = false
                                    self.editNumber = nil
                                }
                                .keyboardShortcut(KeyboardShortcut.cancelAction)
                                
                                Spacer()
                                
                                Button("Done") {
                                    if let time = timeFromStr(currentTime) {
                                        if let editNumber = editNumber {
                                            self.solves[editNumber].time = time
                                        } else {
                                            let solve = SimpleSolve(time: time, penalty: Penalty.none)
                                            self.solves.append(solve)
                                        }
                                        
                                        self.editNumber = nil
                                        currentTime = ""
                                    }
                                }
                                .keyboardShortcut(KeyboardShortcut.defaultAction)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
