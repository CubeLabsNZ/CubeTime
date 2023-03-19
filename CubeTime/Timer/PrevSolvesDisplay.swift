import SwiftUI

struct PrevSolvesDisplay: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    var count: Int?
    
    @State var solve: Solve? = nil
    
    var body: some View {
        if (SessionType(rawValue: stopwatchManager.currentSession.sessionType) == .compsim) {
            if let currentSolveGroup = stopwatchManager.compsimSolveGroups.first {
                TimeBar(solvegroup: currentSolveGroup, currentCalculatedAverage: .constant(nil), isSelectMode: .constant(false), current: true)
                    .frame(height: 55)
            }
        } else {
            HStack {
                ForEach((count != nil)
                        ? stopwatchManager.solvesByDate.suffix(count!)
                        : stopwatchManager.solvesByDate, id: \.self) { solve in
                    
                    TimeCard(solve: solve, currentSolve: $solve)
                }
            }
            .sheet(item: self.$solve) { item in
                TimeDetailView(for: item, currentSolve: $solve)
            }
        }
    }
}
