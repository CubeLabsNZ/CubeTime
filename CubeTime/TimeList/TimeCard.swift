import SwiftUI
import CoreData



struct TimeCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
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
        self.formattedTime = formatSolveTime(secs: solve.time, penType: Penalty(rawValue: solve.penalty)!)
        self.pen = Penalty(rawValue: solve.penalty)!
        self._currentSolve = currentSolve
    }
    
    var body: some View {
        let sess_type = stopwatchManager.currentSession.sessionType
        ZStack {
            #warning("TODO:  check operforamcne of the on tap/long hold gestures on the zstack vs the rounded rectangle")
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color("overlay0"))
                .frame(maxWidth: cardWidth, minHeight: cardHeight, maxHeight: cardHeight)

                .onTapGesture {
                    currentSolve = solve
                }
                .onLongPressGesture {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                
                
            VStack {
                Text(formattedTime)
                    .font(.body.weight(.bold))
            }
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
            
            if sess_type != SessionType.compsim.rawValue {
                SessionPickerMenu(sessions: sess_type == SessionType.playground.rawValue ? stopwatchManager.sessionsCanMoveToPlayground[Int(solve.scrambleType)] : stopwatchManager.sessionsCanMoveTo) { session in
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
