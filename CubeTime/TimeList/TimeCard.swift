import SwiftUI




struct TimeCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @StateObject var solve: Solves // Must be stateobject so that stopwatchmanager can send objectwillsend
    
    let formattedTime: String
    let pen: PenTypes
    
    @Binding var currentSolve: Solves?
    @Binding var isSelectMode: Bool
    
    @Binding var selectedSolves: [Solves]
    
    @State var isSelected = false
    
    
    init(solve: Solves, currentSolve: Binding<Solves?>, isSelectMode: Binding<Bool>, selectedSolves: Binding<[Solves]>) {
        self._solve = StateObject(wrappedValue: solve)
        self.formattedTime = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
        self.pen = PenTypes(rawValue: solve.penalty)!
        self._currentSolve = currentSolve
        self._isSelectMode = isSelectMode
        self._selectedSolves = selectedSolves
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color(uiColor: .systemGray4) : colourScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .systemBackground))
                .frame(maxWidth: 120, minHeight: 55, maxHeight: 55) /// todo check operforamcne of the on tap/long hold gestures on the zstack vs the rounded rectange
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
                
                
            VStack {
                Text(formattedTime)
                    .font(.system(size: 17, weight: .bold, design: .default))
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(accentColour)
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
//            Button {
//            } label: {
//                Label("Move To", systemImage: "arrow.up.forward.circle")
//            }
//
//            Divider()
            
            Button {
                stopWatchManager.changePen(solve: self.solve, pen: .none)
            } label: {
                Label("No Penalty", systemImage: "checkmark.circle") /// TODO: add custom icons because no good icons
            }
            
            Button {
                stopWatchManager.changePen(solve: self.solve, pen: .plustwo)
            } label: {
                Label("+2", image: "+2.label") /// TODO: add custom icons because no good icons
            }
            
            Button {
                stopWatchManager.changePen(solve: self.solve, pen: .dnf)
            } label: {
                Label("DNF", systemImage: "xmark.circle") /// TODO: add custom icons because no good icons
            }
            
            Divider()
            
            Button (role: .destructive) {
                withAnimation {
                    stopWatchManager.delete(solve: solve)
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
