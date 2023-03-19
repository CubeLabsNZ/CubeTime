import Foundation
import Combine


enum StatValue {
    case average(Average)
    case averageOf(AverageOf)
    case double(Double)
    case count(Int)
    
    var doubleValue: Double {
        switch self {
        case .average(let average):
            return average.average
        case .averageOf(let averageOf):
            return averageOf.average
        case .double(let double):
            return double
        case .count(let int):
            return Double(int)
        }
    }
    
    var penalty: Penalty? {
        switch self {
        case .average(let average):
            return average.penalty
        case .averageOf(let averageOf):
            return averageOf.penalty
        default:
            return nil
        }
    }
    
    var formatted: String {
        formatSolveTime(secs: self.doubleValue, penType: penalty)
    }
}

enum StatResult {
    case loading
    case notEnoughDetail
    case error(Error)
    case value(StatValue)
}

protocol Stat {
    var result: StatResult { get }
    
//    init(swm: StopwatchManager)
    
    func firstCalculate() async
    func poppedSolve(solve: Solve) async
    func pushedSolve(solve: Solve) async
    func solveRemoved(solve: Solve) async
    func solvePenChanged(solve: Solve, from: Penalty) async
}

class StatSolveCount: Stat {
    var result: StatResult = .loading
    
    let swm: StopwatchManager
    
    init(swm: StopwatchManager) {
        self.swm = swm
    }
    
    func firstCalculate() async {
        result = .value(.count(swm.solves.count))
    }
    
    func poppedSolve(solve _: Solve) async {
        result = .value(.count(swm.solves.count))
    }
    
    func pushedSolve(solve _: Solve) async {
        result = .value(.count(swm.solves.count))
    }
    
    func solveRemoved(solve _: Solve) async {
        result = .value(.count(swm.solves.count))
    }
    
    func solvePenChanged(solve: Solve, from: Penalty) async {
        
    }
}

class StatMean: Stat {
    var result: StatResult = .loading
    
    let swm: StopwatchManager
    var sum: Double!
    
    init(swm: StopwatchManager) {
        self.swm = swm
    }
    
    func firstCalculate() async {
        if swm.solvesNoDNFs.count == 0 {
            result = .notEnoughDetail
            return
        }
        result = .loading
        sum = swm.solvesNoDNFs.reduce(0, {$0 + $1.timeIncPen })
        result = .value(.double(sum / Double(swm.solvesNoDNFs.count)))
    }
    
    func poppedSolve(solve: Solve) async {
        await solveRemoved(solve: solve)
    }
    
    func pushedSolve(solve: Solve) async {
        sum += solve.timeIncPen
        result = .value(.double(sum / Double(swm.solvesNoDNFs.count)))
    }
    
    func solveRemoved(solve: Solve) async {
        if swm.solvesNoDNFs.count == 0 {
            result = .notEnoughDetail
            return
        }
        sum -= solve.timeIncPen
        result = .value(.double(sum / Double(swm.solvesNoDNFs.count)))
    }
    
    func solvePenChanged(solve: Solve, from oldPen: Penalty) async {
        let newPen = Penalty(rawValue: solve.penalty)!
        if newPen == oldPen {
            return
        }
        result = .loading
        if newPen == .dnf {
            await solveRemoved(solve: solve)
        } else if oldPen == .dnf {
            await pushedSolve(solve: solve)
        } else if newPen == .plustwo {
            sum += 2
            result = .value(.double(sum / Double(swm.solvesNoDNFs.count)))
        } else if oldPen == .plustwo {
            sum -= 2
            result = .value(.double(sum / Double(swm.solvesNoDNFs.count)))
        }
    }
}

class StatCurrentAOn: Stat {
    var result: StatResult = .loading
    
    let swm: StopwatchManager
    let n: Int
    
    init(swm: StopwatchManager, n: Int) {
        self.swm = swm
        self.n = n
    }
    
    func firstCalculate() async {
        if swm.solves.count < n {
            result = .notEnoughDetail
            return
        }
        result = .loading
        let avg = Self.getCalculatedAverage(forSolves: swm.solvesByDate.suffix(n))
        result = .value(.averageOf(avg))
    }
    
    #warning("TODO: make these incremental instead of recalculating")
    func poppedSolve(solve _: Solve) async {
        if swm.solves.count < n {
            result = .notEnoughDetail
            return
        }
        result = .loading
        let avg = Self.getCalculatedAverage(forSolves: swm.solvesByDate.suffix(n))
        result = .value(.averageOf(avg))
    }
    
    func pushedSolve(solve _: Solve) async {
        NSLog("Pushed solve, n = \(n    )")
        if swm.solves.count < n {
            NSLog("not enough solves!")
            return
        }
        result = .loading
        NSLog("getting avg...!")
        let avg = Self.getCalculatedAverage(forSolves: swm.solvesByDate.suffix(n))
        NSLog("avg is \(avg)")
        result = .value(.averageOf(avg))
    }
    
    #warning("TODO: are trimmedsolves in accountedsolves?")
    func solveRemoved(solve: Solve) async {
        if swm.solves.count < n {
            result = .notEnoughDetail
            return
        } else if case let .value(val) = result,
                  case let .averageOf(avg) = val,
                  !avg.accountedSolves.contains(solve) && !avg.trimmedSolves.contains(solve) {
            return
        }
        result = .loading
        let avg = Self.getCalculatedAverage(forSolves: swm.solvesByDate.suffix(n))
        result = .value(.averageOf(avg))
    }
    
    func solvePenChanged(solve: Solve, from: Penalty) async {
        if swm.solves.count < n {
            return
        } else if !swm.solvesByDate.suffix(n).contains(solve) {
            return
        }
        result = .loading
        let avg = Self.getCalculatedAverage(forSolves: swm.solvesByDate.suffix(n))
        result = .value(.averageOf(avg))
    }
    
    static func getCalculatedAverage(forSolves solves: [Solve]) -> AverageOf {
        let count = solves.count
        var trim: Int {
            if count <= 12 {
                return 1
            } else {
                return Int(Double(count) * 0.05)
            }
        }
        
        let solvesSorted: [Solve] = solves.sorted(by: StopwatchManager.sortWithDNFsLast)
        let isDNF = solvesSorted[solvesSorted.endIndex.advanced(by: -(trim + 1))].penalty == Penalty.dnf.rawValue
        let solvesTrimmed: [Solve] = solvesSorted.prefix(trim) + solvesSorted.suffix(trim)
        
        let sum = solvesSorted[trim..<(count-trim)].reduce(0, { $0 + $1.timeIncPen })
        let avg = sum / (Double(count - (trim * 2)))
        
        return AverageOf(
            average: avg, penalty: isDNF ? .dnf : .none,
            accountedSolves: solvesSorted.suffix(count),
            trimmedSolves: solvesTrimmed
        )
    }
}
