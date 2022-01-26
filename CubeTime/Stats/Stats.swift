import Foundation
import CoreData
import SwiftUI


// infix operator <? : ComparisonPrecedence

struct CalculatedAverage: Identifiable/*, Equatable, Comparable*/ {
    let id: String

    //    let discardedIndexes: [Int]
    let average: Double?
    let accountedSolves: [Solves]?
    let totalPen: PenTypes
    let trimmedSolves: [Solves]?
    
    /*
    static func == (lhs: CalculatedAverage, rhs: CalculatedAverage) -> Bool {
        return lhs.average == rhs.average
    }
     */
    
    /*
    static func < (lhs: CalculatedAverage, rhs: CalculatedAverage) -> Bool {
        if let lhs.average = lhs.average, let rhs.average = rhs.average {
            return lhs.average < rhs.average
        } else {
            return false
        }
        
    }
     */
}


func timeWithPlusTwoForSolve(_ solve: Solves) -> Double {
    return solve.time + (solve.penalty == PenTypes.plustwo.rawValue ? 2 : 0)
}

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
    
    func calculateAverage(_ solves: [Solves], _ id: String, _ compsim: Bool) -> CalculatedAverage? {
        let cnt = solves.count
        
        if cnt < 5 {
            return nil
        }
        
        var trim: Int {
            if cnt <= 12 {
                return 1
            } else {
                return Int(Double(cnt) * 0.05)
            }
        }
        
        let solvesSorted: [Solves] = solves.sorted(by: Stats.sortWithDNFsLast)
        let solvesTrimmed: [Solves] = solvesSorted.prefix(trim) + solvesSorted.suffix(trim)
        
        if compsim {
            return CalculatedAverage(
                id: "\(id)",
                average: solvesSorted.dropFirst(trim).dropLast(trim).reduce(0, {$0 + timeWithPlusTwoForSolve($1)}) / Double(cnt-(trim * 2)),
                accountedSolves: solvesSorted.suffix(cnt),
                totalPen: solvesSorted.suffix(cnt).filter {$0.penalty == PenTypes.dnf.rawValue}.count >= trim * 2 ? .dnf : .none,
                trimmedSolves: solvesTrimmed
            )
        } else {
            return CalculatedAverage(
                id: "\(id)\(cnt)",
                average: solvesSorted.dropFirst(trim).dropLast(trim).reduce(0, {$0 + timeWithPlusTwoForSolve($1)}) / Double(cnt-(trim * 2)),
                accountedSolves: solvesSorted.suffix(cnt),
                totalPen: solvesSorted.suffix(cnt).filter {$0.penalty == PenTypes.dnf.rawValue}.count >= trim * 2 ? .dnf : .none,
                trimmedSolves: solvesTrimmed
            )
        }
    }
    
    static func sortWithDNFsLast(_ solve0: Solves, _ solve1: Solves) -> Bool {
        let pen0 = PenTypes(rawValue: solve0.penalty)!
        let pen1 = PenTypes(rawValue: solve1.penalty)!
        
        // Sort non DNFs or both DNFs by time
        if (pen0 != .dnf && pen1 != .dnf) || (pen0 == .dnf && pen1 == .dnf) {
            return timeWithPlusTwoForSolve(solve0) > timeWithPlusTwoForSolve(solve1)
        // Order non DNFs before DNFs
        } else if pen0 == .dnf && pen1 != .dnf {
            return true
        } else {
            return false
        }
    }

    
    /// NORMAL SESSION FUNCTIONS
    func getMin() -> Solves? {
        if solvesNoDNFs.count == 0 {
            return nil
        }
        return solvesNoDNFs[0]
    }
    
    func getSessionMean() -> Double? {
        if solvesNoDNFs.count == 0 {
            return nil
        } 
        let sum = solvesNoDNFs.reduce(0, {$0 + timeWithPlusTwoForSolve($1) })
        return sum / Double(solvesNoDNFs.count)
    }
    
    func getNumberOfSolves() -> Int {
        return solves.count
    }
    
    
    func getNormalMedian() -> (Double?, Double?) {
        let cnt = solvesNoDNFs.count
        
        if cnt == 0 {
            return (nil, nil)
        }
        
        let truncatedValues = getTruncatedMinMax(numbers: getDivisions(data: solvesNoDNFs.map({ $0.time })))
        
        #if DEBUG
        print(truncatedValues)
        print(cnt)
        #endif
            
        
        
        if cnt % 2 == 0 {
            let median = Double((solvesNoDNFs[cnt/2].time + solvesNoDNFs[(cnt/2)-1].time)/2)
            
            if let truncatedMin = truncatedValues.0, let truncatedMax = truncatedValues.1 {
                
                #if DEBUG
                print(truncatedMin)
                print(truncatedMax)
                #endif
                
                
                return (median, ((median-truncatedMin)/(truncatedMax-truncatedMin)))
            }
            
            return (median, nil)
            
            
        } else {
            let median = Double(solvesNoDNFs[(cnt/2)].time)
            
            if let truncatedMin = truncatedValues.0, let truncatedMax = truncatedValues.1 {
                
                #if DEBUG
                print(truncatedMin)
                print(truncatedMax)
                #endif
                
                return (median, ((median-truncatedMin)/(truncatedMax-truncatedMin)))
            }
            
            return (median, nil)
        }
    }
    
    
    
    /// AVERAGE FUNCTIONS
    
    func getCurrentAverageOf(_ period: Int) -> CalculatedAverage? {
        if solvesByDate.count < period {
            return nil
        }
        
        return calculateAverage(solvesByDate.suffix(period), "Current ao", false)
    }
    
    
    func getBestMovingAverageOf(_ period: Int) -> CalculatedAverage? {
        precondition(period > 1)
        if solvesByDate.count < period {
            return nil
        }
        
        let trim = period >= 100 ? 5 : 1
        
        
        var lowestAverage: Double?
        var lowestValues: [Solves]?
        var trimmedSolves: [Solves]?
        
        for i in period..<solves.count+1 {
            var solves = solvesByDate[i - period..<i]
            solves.sort(by: Stats.sortWithDNFsLast)
            
            trimmedSolves = solves.suffix(trim) + solves.prefix(trim)
            
            let trimmed = solves.dropFirst(trim).dropLast(trim)
            
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
        return CalculatedAverage(id: "Best ao\(period)", average: lowestAverage, accountedSolves: lowestValues, totalPen: lowestValues == nil ? .dnf : .none, trimmedSolves: trimmedSolves)
    }

    
    
    
    /// COMP SIM STUFF
    
    func getNumberOfAverages() -> Int {
        return (solves.count / 5)
    }
        
    func getReachedTargets() -> Int {
        var reached = 0
        
        if let compsimSession = compsimSession {
            for solvegroup in compsimSession.solvegroups!.array {
                let x = ((solvegroup as AnyObject).solves!.array as! [Solves]).map {$0.time}.sorted().dropFirst().dropLast()
                if x.count == 3 {
                    if x.reduce(0, +) <= compsimSession.target * 3 {
                        reached += 1
                    }
                }
                
            }
        }
        
        return reached
    }
    
    
    func getCurrentCompsimAverage() -> CalculatedAverage? {
        if let compsimSession = compsimSession {
            
            let groupCount = compsimSession.solvegroups!.count
            
            if groupCount == 0 {
                return nil
            } else if groupCount == 1 {
                let groupLastSolve = ((compsimSession.solvegroups!.lastObject as! CompSimSolveGroup).solves!.array as! [Solves])
                
                if groupLastSolve.count != 5 {
                    return nil
                } else {
                    return calculateAverage(groupLastSolve, "Current Comp Sim", true)
                }
                
            } else {
                let groupLastTwoSolves = (compsimSession.solvegroups!.array as! [CompSimSolveGroup]).suffix(2)
                
                let lastInGroup = groupLastTwoSolves.last!.solves!.array as! [Solves]
                
                if lastInGroup.count == 5 {
                    
                    return calculateAverage(lastInGroup, "Current Comp Sim", true)
                } else {
                    
                    return calculateAverage((groupLastTwoSolves.first!.solves!.array as! [Solves]), "Current Comp Sim", true)
                }
            }
        } else {
            return nil
        }
    }
    
    
    func getBestCompsimAverageAndArrayOfCompsimAverages() -> (CalculatedAverage?, [CalculatedAverage]) {
        var allCompsimAverages: [CalculatedAverage] = []
        
        if let compsimSession = compsimSession {
            if compsimSession.solvegroups!.count == 0 {
                return (nil, [])
            } else if compsimSession.solvegroups!.count == 1 && (((compsimSession.solvegroups!.firstObject as! CompSimSolveGroup).solves!.array as! [Solves]).count != 5)  {
                /// && ((compsimSession.solvegroups!.first as AnyObject).solves!.array as! [Solves]).count != 5
                return (nil, [])
            } else {
                var bestAverage: CalculatedAverage?
//                var bestAverage: CalculatedAverage = calculateAverage(((compsimSession.solvegroups!.firstObject as! CompSimSolveGroup).solves!.array as! [Solves]), "Best Comp Sim", true)!
                
                for solvegroup in compsimSession.solvegroups!.array {
                    if (solvegroup as AnyObject).solves!.array.count == 5 {
                        
                        
                        let currentAvg = calculateAverage((solvegroup as AnyObject).solves!.array as! [Solves], "Best Comp Sim", true)
                        
                        if currentAvg?.totalPen == .dnf {
                            continue
                        }
                        
                        // this will only append the non-dnfed times into the array
                        if let currentAvg = currentAvg {
                            allCompsimAverages.append(currentAvg)
                        }
                        
                        if bestAverage == nil || (currentAvg?.average)! < (bestAverage?.average!)! {
                            bestAverage = currentAvg!
                        }
                    }
                }
                
                if bestAverage == nil {
                    return (getCurrentCompsimAverage(), allCompsimAverages)
                } else {
                    return (bestAverage, allCompsimAverages)
                }
            }
        } else {
            return (nil, [])
        }
    }
    
    
    
    func getCurrentMeanOfTen() -> Double? { // returned calculated average has averages as solves
        if compsimSession != nil {
            let averages = getBestCompsimAverageAndArrayOfCompsimAverages().1
            
            if averages.count >= 10 {
                if averages.suffix(10).contains(where: { $0.totalPen == .dnf }) {
                    return -1
                } else {
                    return (averages.suffix(10).map({ $0.average! }).reduce(0, +) / 10.0)
                }
                
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func getBestMeanOfTen() -> Double? {
        if compsimSession != nil {
            let averages = getBestCompsimAverageAndArrayOfCompsimAverages().1
            let cnt = averages.count
            
            var bestMean: Double?
            
            if cnt == 10 {
                return getCurrentMeanOfTen()
            } else if cnt > 10 {
                for i in 0..<cnt-9 {
                    let tempArr = (averages[i..<i+10])
                    
                    if !(tempArr.contains(where: { $0.totalPen == .dnf})) {
                        let tempMean = (tempArr.map({ $0.average! }).reduce(0, +)) / 10.0
                        
                        if bestMean == nil || tempMean < bestMean! {
                            bestMean = tempMean
                        }
                    }
                }
                
                return bestMean
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func getAveragePhases() -> [Double]? {
        if multiphaseSession != nil {
            let times = (solvesNoDNFs as! [MultiphaseSolve]).map({ $0.phases! })
            
            
            print(times)
            
            
            let phaseCount = multiphaseSession!.phase_count
            
            var summedPhases = [Double](repeating: 0, count: Int(phaseCount))
                        
            
            for phase in times {
                var paddedPhase = phase
                paddedPhase.insert(0, at: 0)
                
                let mappedPhase = paddedPhase.chunked().map { $0[1] - $0[0] }
                
                #if DEBUG
                print(mappedPhase)
                #endif
                
                for i in 0..<Int(phaseCount) {
                    summedPhases[i] += mappedPhase[i]
                }
            }
            
            #if DEBUG
            print(summedPhases)
            #endif
            
            return summedPhases.map({ $0 / Double(solvesNoDNFs.count) })
        } else {
            return nil
        }
    }
    
    
    func getWpaBpa() -> (Double?, Double?) {
        if let compsimSession = compsimSession {
            let solveGroups = (compsimSession.solvegroups!.array as! [CompSimSolveGroup])
            
            if solveGroups.count == 0 { return (nil, nil) } else {
                let lastGroup = solveGroups.last
                
                /*
                 
                 
                 let groupLastSolve = ((compsimSession.solvegroups!.lastObject as! CompSimSolveGroup).solves!.array as! [Solves])
                 
                 if groupLastSolve.count != 5 {
                     return nil
                 } else {
                     return calculateAverage(groupLastSolve, "Current Comp Sim", true)
                 
                 */
                
                
                let lastGroupSolves = (lastGroup!.solves!.array as! [Solves])
                if lastGroupSolves.count == 4 {
                    let sortedGroup = lastGroupSolves.sorted(by: Stats.sortWithDNFsLast)
                    
                    print(sortedGroup.map{$0.time})
                    
                    let bpa = (sortedGroup.dropFirst().reduce(0) {$0 + timeWithPlusTwoForSolve($1)}) / 3.00
                    
                    let wpa = sortedGroup.contains(where: {$0.penalty == PenTypes.dnf.rawValue}) ? -1 : (sortedGroup.dropLast().reduce(0) {$0 + timeWithPlusTwoForSolve($1)}) / 3.00
                    
                    return (bpa, wpa)
                }
            }
        } else { return (nil, nil) }
        
        return (nil, nil)
    }
}

extension Array {
    func chunked() -> [[Element]] {
        return stride(from: 0, to: count-1, by: 1).map {
            Array(self[$0 ..< Swift.min($0 + 2, count)])
        }
    }
}
