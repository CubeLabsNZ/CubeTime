import SwiftUI




struct TimeCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    let solve: Solves
    let timeListManager: TimeListManager
    
    @State var formattedTime: String
    @State var pen: PenTypes
    
    @Binding var currentSolve: Solves?
    @Binding var isSelectMode: Bool
    
    @Binding var selectedSolves: [Solves]
    
    @State var isSelected = false
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @Environment(\.sizeCategory) var sizeCategory
    
    private var cardWidth: CGFloat {
        if sizeCategory > ContentSizeCategory.extraLarge {
            return 200
        } else if sizeCategory < ContentSizeCategory.small {
            return 100
        } else {
            return 120
        }
    }
    
    private var cardHeight: CGFloat {
        if sizeCategory > ContentSizeCategory.extraLarge {
            return 60
        } else if sizeCategory < ContentSizeCategory.small {
            return 50
        } else {
            return 55
        }
    }
    
    
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
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color(uiColor: .systemGray4) : colourScheme == .dark ? Color(uiColor: .systemGray6) : Color(uiColor: .systemBackground))
                .frame(maxWidth: cardWidth, minHeight: cardHeight, maxHeight: cardHeight) /// todo check operforamcne of the on tap/long hold gestures on the zstack vs the rounded rectange
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
                    .font(.body.weight(.bold))
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
                pen = .none
                self.solve.penalty = pen.rawValue
                formattedTime = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                try! managedObjectContext.save()
            } label: {
                Label("No Penalty", systemImage: "checkmark.circle")
            }
            
            Button {
                pen = .plustwo
                self.solve.penalty = pen.rawValue
                formattedTime = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                try! managedObjectContext.save()
            } label: {
                Label("+2", image: "+2.label")
            }
            
            Button {
                pen = .dnf
                self.solve.penalty = pen.rawValue
                formattedTime = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                try! managedObjectContext.save()
            } label: {
                Label("DNF", systemImage: "xmark.circle")
            }
            
            Divider()
            
            Button (role: .destructive) {
                managedObjectContext.delete(solve)
                try! managedObjectContext.save()
                stopWatchManager.tryUpdateCurrentSolveth()
                
                withAnimation {
                    timeListManager.delete(solve)
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
