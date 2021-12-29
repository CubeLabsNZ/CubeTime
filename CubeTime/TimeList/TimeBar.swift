//
//  TimeBar.swift
//  CubeTime
//
//  Created by Tim Xie on 27/12/21.
//

import SwiftUI

struct TimeBar: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    let solve: Solves
    let timeListManager: TimeListManager
    
    @State var formattedTime: String
    @State var pen: PenTypes
    
    @Binding var currentSolve: Solves?
    @Binding var isSelectMode: Bool
    
    @Binding var selectedSolves: [Solves]
    
    @State var isSelected = false
    
    
    init(solve: Solves, timeListManager: TimeListManager, currentSolve: Binding<Solves?>, isSelectMode: Binding<Bool>, selectedSolves: Binding<[Solves]>) {
        self.solve = solve
        self.timeListManager = timeListManager
        self._formattedTime = State(initialValue: formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!))
        self._pen = State(initialValue: PenTypes(rawValue: solve.penalty)!)
        self._currentSolve = currentSolve
        self._isSelectMode = isSelectMode
        self._selectedSolves = selectedSolves
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color(uiColor: .systemGray4) : colourScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .systemBackground))
                .frame(minHeight: 70, maxHeight: 70) /// todo check operforamcne of the on tap/long hold gestures on the zstack vs the rounded rectange
                .onTapGesture {
                    if isSelectMode {
                        withAnimation {
                            if isSelected {
                                isSelected = false
                                if let index = selectedSolves.firstIndex(of: solve) {
                                    selectedSolves.remove(at: index)
                                }
                            } else {
                                isSelected = true
                                selectedSolves.append(solve)
                            }
                        }
                    } else {
                        currentSolve = solve
                    }
                }
                .onLongPressGesture {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                
                
            HStack {
                VStack(spacing: 0){
                    HStack {
                        Text(formattedTime)
                            .font(.system(size: 26, weight: .bold, design: .default))

                        Spacer()
                    }
                    
                    HStack(spacing: 0) {
                        ForEach(0...4, id: \.self) { placeholder in
                            Text("1.69, ")
                                .font(.system(size: 17, weight: .medium))
                        }
                        
                        Spacer()
                    }
                }
                .padding(.leading, 12)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color("AccentColor"))
                        .padding(.trailing, 12)
                }
            }
        }
        .onChange(of: isSelectMode) {newValue in
            if !newValue && isSelected {
                withAnimation {
                    isSelected = false
                }
            }
        }
        .contextMenu {
            Button (role: .destructive) {
                managedObjectContext.delete(solve)
                try! managedObjectContext.save()
                withAnimation {
                    timeListManager.resort()
                }
            } label: {
                Label {
                    Text("Delete Solve")
                        .foregroundColor(Color.red)
                } icon: {
                    Image(systemName: "trash")
                        .foregroundColor(Color.green) /// FIX: colours not working
                }
            }
        }
    }
}
