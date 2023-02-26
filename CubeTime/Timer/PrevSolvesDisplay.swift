//
//  PrevSolvesDisplay.swift
//  CubeTime
//
//  Created by macos sucks balls on 5/15/22.
//

import SwiftUI

struct PrevSolvesDisplay: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    var count: Int?;
    var body: some View {
        HStack {
            ForEach((count != nil)
                    ? stopwatchManager.solvesByDate.suffix(count!).reversed()
                    : stopwatchManager.solvesByDate.reversed(), id: \.self) { solve in
                #warning("TODO:  popup")
                TimeCard(solve: solve, currentSolve: .constant(nil), isSelectMode: .constant(false), selectedSolves: .constant([]))
            }
        }
    }
}

struct PrevSolvesDisplay_Previews: PreviewProvider {
    static let moc = PersistenceController.shared.container.viewContext
    static let stopwatchManager: StopwatchManager = {
        let session = Sessions(context: moc)
        session.name = "Session"
        session.scramble_type = 3
        session.session_type = SessionTypes.standard.rawValue
        let times = [127.136, 10.421, 4.124]
        let pens: [PenTypes] = [.none, .plustwo, .dnf]
        for i in 0..<3 {
            let solve = Solves(context: moc)
            solve.time = times[i]
            solve.scramble_type = 3
            solve.date = Date().advanced(by: Double(i))
            solve.penalty = pens[i].rawValue
            solve.session = session
            solve.scramble = "R' R' R'"
            solve.scramble_type = 3
            solve.scramble_subtype = 0
        }
        let swm = StopwatchManager(currentSession: session, managedObjectContext: moc)
        return swm
    }()
    static var previews: some View {
        PrevSolvesDisplay()
            .environmentObject(stopwatchManager)
    }
}
