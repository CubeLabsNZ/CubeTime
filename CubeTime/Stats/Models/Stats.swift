import Foundation
import Combine

typealias Mean = Average

enum StatValue {
    case average(Average)
    case averageOf(AverageOf)
    
    case mean(Mean)
    case solve(Solve)
    
    var doubleValue: Double {
        switch self {
        case .average(let average):
            return average.average
            
        case .averageOf(let averageOf):
            return averageOf.average
            
        case .mean(let mean):
            return mean.average
            
        case .solve(let solve):
            return solve.timeIncPen
            
        }
    }
    
    var penalty: Penalty? {
        switch self {
        case .average(let average):
            return average.penalty
            
        case .mean(let mean):
            return mean.penalty
            
        case .averageOf(let averageOf):
            return averageOf.penalty
            
        case .solve(let solve):
            return Penalty(rawValue: solve.penalty)
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
    
    func initialiseStatistic() async
    func poppedSolve(solve: Solve) async
    func pushedSolve(solve: Solve) async
    func solveRemoved(solve: Solve) async
    func solvePenChanged(solve: Solve, from oldPen: Penalty) async
}

class StatMean: Stat {
    var result: StatResult = .loading
    
    let stopwatchManager: StopwatchManager
    var sum: Double!
    var dnfCount: Int!
    
    init(stopwatchManager: StopwatchManager) {
        self.stopwatchManager = stopwatchManager
    }
    
    func initialiseStatistic() async {
        if stopwatchManager.solvesNoDNFs.count == 0 {
            result = .notEnoughDetail
            return
        }
        
        result = .loading
        
        // merge into one loop
        self.sum = stopwatchManager.solvesNoDNFs.reduce(0, {$0 + $1.timeIncPen })
        
        // for some reason this is run TWICE and so if i directly increment self.dnfCount it will duplicate the count
        var tempDnfCount = 0
        stopwatchManager.solves.forEach({ solve in
            if (Penalty(rawValue: solve.penalty) == .dnf) {
                tempDnfCount += 1
            }
        })
        self.dnfCount = tempDnfCount
        
        result = .value(.mean(Mean(average: sum / Double(stopwatchManager.solvesNoDNFs.count), penalty: dnfCount == 0 ? .none : .dnf)))
    }
    
    func poppedSolve(solve: Solve) async {
        await solveRemoved(solve: solve)
    }
    
    func pushedSolve(solve: Solve) async {
        sum += solve.timeIncPen
        dnfCount += (Penalty(rawValue: solve.penalty) == .dnf ? 1 : 0)
        
        result = .value(.mean(Mean(average: sum / Double(stopwatchManager.solvesNoDNFs.count), penalty: dnfCount == 0 ? .none : .dnf)))
    }
    
    func solveRemoved(solve: Solve) async {
        if stopwatchManager.solvesNoDNFs.count == 0 {
            result = .notEnoughDetail
            return
        }
        sum -= solve.timeIncPen
        dnfCount -= (Penalty(rawValue: solve.penalty) == .dnf ? 1 : 0)
        
        result = .value(.mean(Mean(average: sum / Double(stopwatchManager.solvesNoDNFs.count), penalty: dnfCount == 0 ? .none : .dnf)))
    }
    
    func solvePenChanged(solve: Solve, from oldPen: Penalty) async {
        let newPen = Penalty(rawValue: solve.penalty)!
        if newPen == oldPen {
            return
        }
        
        
        result = .loading
        
        switch (newPen) {
        case .dnf:
            if (oldPen == .plustwo) {
                sum -= 2
            }
            dnfCount += 1
            
        case .none:
            if (oldPen == .dnf) {
                dnfCount -= 1
            } else {
                sum -= 2
            }
        
        case .plustwo:
            if (oldPen == .dnf) {
                dnfCount -= 1
            }
            
            sum += 2
        }
        
        result = .value(.mean(Mean(average: sum / Double(stopwatchManager.solvesNoDNFs.count), penalty: dnfCount == 0 ? .none : .dnf)))
    }
}

class StatCurrentAverage: Stat {
    var result: StatResult = .loading
    
    let stopwatchManager: StopwatchManager
    let x: Int
    
    init(of x: Int, stopwatchManager: StopwatchManager) {
        self.x = x
        self.stopwatchManager = stopwatchManager
    }
    
    func initialiseStatistic() async {
        if stopwatchManager.solves.count < x {
            result = .notEnoughDetail
            return
        }
        result = .loading
        let avg = Self.getCalculatedAverage(forSolves: stopwatchManager.solvesByDate.suffix(x))
        result = .value(.averageOf(avg))
    }
    
    #warning("TODO: make these incremental instead of recalculating")
    func poppedSolve(solve _: Solve) async {
        if stopwatchManager.solves.count < x {
            result = .notEnoughDetail
            return
        }
        result = .loading
        let avg = Self.getCalculatedAverage(forSolves: stopwatchManager.solvesByDate.suffix(x))
        result = .value(.averageOf(avg))
    }
    
    func pushedSolve(solve _: Solve) async {
        NSLog("Pushed solve, n = \(x    )")
        if stopwatchManager.solves.count < x {
            NSLog("not enough solves!")
            return
        }
        result = .loading
        NSLog("getting avg...!")
        let avg = Self.getCalculatedAverage(forSolves: stopwatchManager.solvesByDate.suffix(x))
        NSLog("avg is \(avg)")
        result = .value(.averageOf(avg))
    }
    
    #warning("TODO: are trimmedsolves in accountedsolves?")
    func solveRemoved(solve: Solve) async {
        if stopwatchManager.solves.count < x {
            result = .notEnoughDetail
            return
        } else if case let .value(val) = result,
                  case let .averageOf(avg) = val,
                  !avg.accountedSolves.contains(solve) && !avg.trimmedSolves.contains(solve) {
            return
        }
        result = .loading
        let avg = Self.getCalculatedAverage(forSolves: stopwatchManager.solvesByDate.suffix(x))
        result = .value(.averageOf(avg))
    }
    
    func solvePenChanged(solve: Solve, from oldPen: Penalty) async {
        if stopwatchManager.solves.count < x {
            return
        } else if !stopwatchManager.solvesByDate.suffix(x).contains(solve) {
            return
        }
        result = .loading
        let avg = Self.getCalculatedAverage(forSolves: stopwatchManager.solvesByDate.suffix(x))
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
