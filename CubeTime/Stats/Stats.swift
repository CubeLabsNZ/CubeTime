import Foundation
import CoreData
import SwiftUI



class Stats {
    var solves: [Solves]
    var solvesByDate: [Solves]
    var solvesNoDNFs: [Solves]
    var solvesNoDNFsbyDate: [Solves]
    
    var compsimSession: CompSimSession?
    var multiphaseSession: MultiphaseSession?
    
    private let currentSession: Sessions
    
    init (currentSession: Sessions) {
        self.currentSession = currentSession
        
        let sessionSolves = currentSession.solves!.allObjects as! [Solves]
        
        solves = sessionSolves.sorted(by: {timeWithPlusTwoForSolve($0) < timeWithPlusTwoForSolve($1)})
        solvesByDate = sessionSolves.sorted(by: {$0.date! < $1.date!})
        
        solvesNoDNFsbyDate = solvesByDate
        solvesNoDNFsbyDate.removeAll(where: { $0.penalty == PenTypes.dnf.rawValue })
        
        solvesNoDNFs = solves
        solvesNoDNFs.removeAll(where: { $0.penalty == PenTypes.dnf.rawValue })
        
        compsimSession = currentSession as? CompSimSession
        multiphaseSession = currentSession as? MultiphaseSession
    }
    
    /// **HELPER FUNCTIONS**
    

}
