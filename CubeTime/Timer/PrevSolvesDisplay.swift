import SwiftUI

struct PrevSolvesDisplay: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    var count: Int?
    
    @State var solve: Solves? = nil
    
    var body: some View {
        HStack {
            ForEach((count != nil)
                    ? stopwatchManager.solvesByDate.suffix(count!)
                    : stopwatchManager.solvesByDate, id: \.self) { solve in
                #warning("TODO:  popup")
                TimeCard(solve: solve, currentSolve: $solve, isSelectMode: .constant(false), selectedSolves: .constant([]))
            }
        }
        .sheet(item: self.$solve) { item in
            TimeDetailView(for: item, currentSolve: $solve)
        }
    }
}
