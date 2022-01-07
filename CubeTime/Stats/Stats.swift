import Foundation
import CoreData
import SwiftUI


struct CalculatedAverage: Identifiable {
    let id: String
    
    let average: Double?
//    let discardedIndexes: [Int]
    let accountedSolves: [Solves]?
    let totalPen: PenTypes
}


func timeWithPlusTwoForSolve(_ solve: Solves) -> Double {
    return solve.time + (solve.penalty == PenTypes.plustwo.rawValue ? 2 : 0)
}

class Stats {
    var solves: [Solves]
    var solvesByDate: [Solves]
    var solvesNoDNFs: [Solves]
    
    var compsimSession: CompSimSession?
    
    private let currentSession: Sessions
    
    init (currentSession: Sessions) {
        self.currentSession = currentSession
        
        let sessionSolves = currentSession.solves!.allObjects as! [Solves]

        solves = sessionSolves.sorted(by: {timeWithPlusTwoForSolve($0) < timeWithPlusTwoForSolve($1)})
        solvesByDate = sessionSolves.sorted(by: {$0.date! < $1.date!})
        solvesNoDNFs = solves
        solvesNoDNFs.removeAll(where: { $0.penalty == PenTypes.dnf.rawValue })
    }
    
    func getMin() -> Solves? {
        if solvesNoDNFs.count == 0 {
            return nil
        }
        return solvesNoDNFs[0]
    }
    
    func getSessionMean() -> Double? {
        if solves.count == 0 {
            return nil
        } 
        let sum = solvesNoDNFs.reduce(0, {$0 + timeWithPlusTwoForSolve($1) })
        return sum / Double(solvesNoDNFs.count)
    }
    
    func getNumberOfSolves() -> Int {
        
        return solves.count
    }
    
    
    
    func getBestMovingAverageOf(_ period: Int) -> CalculatedAverage? {
        precondition(period > 1)
        if solvesByDate.count < period {
            return nil
        }
        
        let trim = period >= 100 ? 5 : 1
        
        
        var lowestAverage: Double?
        var lowestValues: [Solves]?
        
        for i in period..<solves.count+1 {
            let solves = solvesByDate[i - period..<i]
            let trimmed = solves.sorted {
                let pen0 = PenTypes(rawValue: $0.penalty)!
                let pen1 = PenTypes(rawValue: $1.penalty)!
                
                // Sort non DNFs or both DNFs by time
                if (pen0 != .dnf && pen1 != .dnf) || (pen0 == .dnf && pen1 == .dnf) {
                    return timeWithPlusTwoForSolve($0) > timeWithPlusTwoForSolve($1)
                // Order non DNFs before DNFs
                } else if pen0 == .dnf && pen1 != . dnf {
                    return true
                } else {
                    return false
                }
            }.dropFirst(trim).dropLast(trim)
            if trimmed.contains(where: {$0.penalty == PenTypes.dnf.rawValue}) {
                continue
            }
            let sum = trimmed.reduce(0, {$0 + timeWithPlusTwoForSolve($1)})
            
            let result = Double(sum) / Double(period-(trim*2))
            if lowestAverage == nil || result < lowestAverage! {
                lowestValues = solvesByDate[i - period ..< i].sorted(by: {$0.date! > $1.date!})
                lowestAverage = result
            }
        }
        return CalculatedAverage(id: "Best AO\(period)", average: lowestAverage, accountedSolves: lowestValues, totalPen: lowestValues == nil ? .dnf : .none)
    }

    
    
    func getCurrentAverageOf(_ period: Int) -> CalculatedAverage? {
        
        let trim = period >= 100 ? 5 : 1
        
        if solves.count < period {
            return nil
        }
        
        return CalculatedAverage(
            id: "Current AO\(period)",
            average: solvesByDate.suffix(period).sorted {
                $0.penalty == PenTypes.dnf.rawValue || timeWithPlusTwoForSolve($0) > timeWithPlusTwoForSolve($1)
            }.dropFirst().dropLast()
                    .reduce(0, {$0 + timeWithPlusTwoForSolve($1)}) / Double(period-(trim * 2)),
            accountedSolves: solvesByDate.suffix(period),
            totalPen: solvesByDate.suffix(period).filter {$0.penalty == PenTypes.dnf.rawValue}.count >= trim * 2 ? .dnf : .none
        )
    }
    
    /// comp sim
    func getNumberOfAverages() -> Int {
        return (solves.count / 5)
    }
        
    func getReachedTargets() -> Int {
        var reached = 0
        if let compsimSession = compsimSession {
            for solvegroup in compsimSession.solvegroups!.array {
                if ((solvegroup as AnyObject).solves!.array as! [Solves]).map {$0.time}.sorted().dropFirst().dropLast().reduce(0, +) <= compsimSession.target {
                    reached += 1
                }
            }
        }
        
        return reached
    }
    
    
    
    
}
