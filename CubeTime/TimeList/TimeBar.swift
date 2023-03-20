//
//  TimeBar.swift
//  CubeTime
//
//  Created by Tim Xie on 27/12/21.
//

import SwiftUI

struct TimeBar: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    let solvegroup: CompSimSolveGroup
    
    @State var calculatedAverage: CalculatedAverage?
    
    @Binding var currentCalculatedAverage: CalculatedAverage?
    @Binding var isSelectMode: Bool
    
//    @Binding var selectedSolvegroups: [CompSimSolveGroup]
    
    @State var isSelected = false
    
    @ScaledMetric(wrappedValue: 17, relativeTo: .body) private var attributedStringSize: CGFloat
    
    let current: Bool
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    init(solvegroup: CompSimSolveGroup, currentCalculatedAverage: Binding<CalculatedAverage?>, isSelectMode: Binding<Bool>, current: Bool) {
        self.solvegroup = solvegroup
        self._currentCalculatedAverage = currentCalculatedAverage
        self._isSelectMode = isSelectMode
        self.current = current
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("overlay0"))
                .onTapGesture {
                    if solvegroup.solves!.count == 5 {
                        currentCalculatedAverage = calculatedAverage
                    }
                }
                .onLongPressGesture {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                
                
            HStack {
                VStack(spacing: 0) {
                    if let calculatedAverage = calculatedAverage {
                        HStack {
                            Text(formatSolveTime(secs: calculatedAverage.average!, penType: calculatedAverage.totalPen))
                                .font(.title2.weight(.bold))

                            Spacer()
                        }
                        
                        let displayText: NSMutableAttributedString = {
                            let finalStr = NSMutableAttributedString(string: "")
                            
                            let grey: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGray, .font: UIFont.systemFont(ofSize: attributedStringSize, weight: .medium)]
                            let normal: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: attributedStringSize, weight: .medium)]
                          
                            if let ar = solvegroup.solves {
                                // CSTODO
                                for (index, solve) in Array((ar.allObjects as! [Solve]).enumerated()) {
                                    if calculatedAverage.trimmedSolves!.contains(solve) {
                                        finalStr.append(NSMutableAttributedString(string: "(" + formatSolveTime(secs: solve.time, penType: Penalty(rawValue: solve.penalty)) + ")", attributes: grey))
                                    } else {
                                        finalStr.append(NSMutableAttributedString(string: formatSolveTime(secs: solve.time, penType: Penalty(rawValue: solve.penalty)), attributes: normal))
                                    }
                                    if index < solvegroup.solves!.count-1 {
                                        finalStr.append(NSMutableAttributedString(string: ", "))
                                    }
                                }
                            }
                            
                            return finalStr
                        }()
                                           
                        
                        HStack(spacing: 0) {
                            Text(AttributedString(displayText))
                            
                            Spacer()
                        }
                    } else {
                        if let solves = solvegroup.solves, solves.count < 5 {
                            HStack {
                                Text("Current Average")
                                    .font(.title2.weight(.bold))

                                Spacer()
                            }
                            
                            let displayText: NSMutableAttributedString = {
                                let finalStr = NSMutableAttributedString(string: "")
                                
                                let normal: [NSAttributedString.Key: Any] = [
                                    .font: UIFont.preferredFont(forTextStyle: .body),
                                ]
                                
                                // CSTODO
                                for (index, solve) in Array((solvegroup.solves!.allObjects as! [Solve]).enumerated()) {
                                    finalStr.append(NSMutableAttributedString(string: formatSolveTime(secs: solve.time, penType: Penalty(rawValue: solve.penalty)), attributes: normal))
                                    
                                    if index < solvegroup.solves!.count - 1 {
                                        finalStr.append(NSMutableAttributedString(string: ", "))
                                    }
                                }
                                
                                return finalStr
                            }()

                            
                            
                            
                            
                            
                            HStack(spacing: 0) {
                                Text(AttributedString(displayText))
                                
                                Spacer()
                            }
                        } else {
                            HStack {
                                Text("Loading...")
                                    .font(.title2.weight(.bold))

                                Spacer()
                            }
                        }
                    }
                }
                .padding(.leading, 12)
                // Don't even talk to me
                .onChange(of: solvegroup.solves.debugDescription) { newValue in
                    self.calculatedAverage = getAvgOfSolveGroup(solvegroup)
                }
                .task {
                    let avg = getAvgOfSolveGroup(solvegroup)
                    await MainActor.run {
                        self.calculatedAverage = avg
                    }
                }
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color("AccentColor"))
                        .padding(.trailing, 12)
                }
            }
            .padding(.vertical, 6)
        }
        .onChange(of: isSelectMode) {newValue in
            if !newValue && isSelected {
                withAnimation(Animation.customFastSpring) {
                    isSelected = false
                }
            }
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contextMenu {
            Button (role: .destructive) {
                stopwatchManager.delete(solveGroup: solvegroup)
                
                
                // timeListManager.refilter() /// and delete this im using this temporarily to update
                
                /* enable when sort works
                withAnimation {
                    timeListManager.resort()
                }
                 */
            } label: {
                Label {
                    Text("Delete Solve Group")
                } icon: {
                    Image(systemName: "trash")
                }
            }
            .disabled(current)
        }
    }
}
