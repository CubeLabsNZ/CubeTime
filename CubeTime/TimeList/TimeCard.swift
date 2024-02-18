import SwiftUI
import CoreData



struct TimeCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    var solve: Solve
    
    let formattedTime: String
    let pen: Penalty
    
    @Binding var currentSolve: Solve?
    
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
    
    init(solve: Solve, currentSolve: Binding<Solve?>) {
        self.solve = solve
        self.formattedTime = formatSolveTime(secs: solve.time, penalty: Penalty(rawValue: solve.penalty)!)
        self.pen = Penalty(rawValue: solve.penalty)!
        self._currentSolve = currentSolve
    }
    
    var body: some View {
        let sessionType = stopwatchManager.currentSession.sessionType
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color("overlay0"))
                .frame(maxWidth: cardWidth, minHeight: cardHeight, maxHeight: cardHeight)
                
            VStack {
                Text(formattedTime)
                    .font(.body.weight(.bold))
            }
        }
        .frame(maxWidth: cardWidth, minHeight: cardHeight, maxHeight: cardHeight)
        .onTapGesture {
            currentSolve = solve
        }
        .onLongPressGesture {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }

        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 8, style: .continuous))
        .contextMenu {
            Button {
                copySolve(solve: solve)
            } label: {
                Label {
                    Text("Copy")
                } icon: {
                    Image(systemName: "doc.on.doc")
                }
            }
            
            Menu {
                Button {
                    stopwatchManager.changePen(solve: self.solve, pen: .none)
                } label: {
                    Label("No Penalty", systemImage: "checkmark.circle")
                }
                
                Button {
                    stopwatchManager.changePen(solve: self.solve, pen: .plustwo)
                } label: {
                    Label("+2", image: "+2.label")
                }
                
                Button {
                    stopwatchManager.changePen(solve: self.solve, pen: .dnf)
                } label: {
                    Label("DNF", systemImage: "xmark.circle")
                }
            } label: {
                Label("Penalty", systemImage: "exclamationmark.triangle")
            }
            
            if sessionType != SessionType.compsim.rawValue {
                SessionPickerMenu(sessions: sessionType == SessionType.playground.rawValue ? stopwatchManager.sessionsCanMoveToPlayground[Int(solve.scrambleType)] : stopwatchManager.sessionsCanMoveTo) { session in
                    withAnimation(Animation.customDampedSpring) {
                        stopwatchManager.moveSolve(solve: solve, to: session)
                    }
                }
            }
            
            
            Divider()
            
            
            Button(role: .destructive) {
                managedObjectContext.delete(solve)
                try! managedObjectContext.save()
                stopwatchManager.tryUpdateCurrentSolveth()
                
                withAnimation(Animation.customDampedSpring) {
                    stopwatchManager.delete(solve: solve)
                }
            } label: {
                Label {
                    Text("Delete")
                } icon: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}
