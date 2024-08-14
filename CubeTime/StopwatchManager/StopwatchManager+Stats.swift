import Foundation
import CoreData



extension StopwatchManager {
    static func getCalculatedAverage(forSolves solves: [Solve], name: String, isCompsim: Bool) -> CalculatedAverage? {
        let count = solves.count
        
        if count < 5 {
            return nil
        }
        
        var trim: Int {
            if count <= 12 {
                return 1
            } else {
                return Int(Double(count) * 0.05)
            }
        }
        
        let solvesSorted: [Solve] = solves.sorted(by: Self.sortWithDNFsLast)
        let isDNF = solvesSorted[solvesSorted.endIndex.advanced(by: -(trim + 1))].penalty == Penalty.dnf.rawValue
        let solvesTrimmed: [Solve] = solvesSorted.prefix(trim) + solvesSorted.suffix(trim)
        
        return CalculatedAverage(
            name: "\(name)" + (isCompsim ? "" : "\(count)"),
            average: calculateAverage(forSortedSolves: solvesSorted, count: count, trim: trim),
            accountedSolves: solvesSorted.suffix(count),
            totalPen: isDNF ? .dnf : .none,
            trimmedSolves: solvesTrimmed
        )
    }
    
    static func calculateAverage(forSortedSolves sortedSolves: [Solve], count: Int, trim: Int) -> Double {
        let sum = sortedSolves[trim..<(count-trim)].reduce(0, { $0 + $1.timeIncPen })
        return sum / (Double(count - (trim * 2)))
    }
    
    #warning("todo make generic :quesitopn?")
    static func calculateAverage(forSortedSolves sortedSolves: [SimpleSolve], count: Int, trim: Int) -> Double {
        let sum = sortedSolves[trim..<(count-trim)].reduce(0, { $0 + $1.timeIncPen })
        return sum / (Double(count - (trim * 2)))
    }
    
    
    static func sortWithDNFsLast(_ solve0: Solve, _ solve1: Solve) -> Bool {
        let pen0 = Penalty(rawValue: solve0.penalty)!
        let pen1 = Penalty(rawValue: solve1.penalty)!
        
        // Sort non DNFs or both DNFs by time
        if (pen0 != .dnf && pen1 != .dnf) || (pen0 == .dnf && pen1 == .dnf) {
            return solve0.timeIncPen < solve1.timeIncPen
        // Order non DNFs before DNFs
        } else {
            return pen0 != .dnf && pen1 == .dnf
        }
    }

}

// MARK: - STATS: STANDARD STATS FUNCS
extension StopwatchManager {
    func getMin() -> Solve? {
        if let solve = solvesNoDNFs.first {
            return solve
        } else if let solve = solves.first {
            return solve
        } else {
            return nil
        }
    }
    
    
    func getSessionMean() -> Double? {
        if solvesNoDNFs.count == 0 {
            return nil
        }
        let sum = solvesNoDNFs.reduce(0, {$0 + $1.timeIncPen })
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
        
        let truncatedValues = getTruncatedMinMax(numbers: getDivisions(data: solvesNoDNFs.map { $0.timeIncPen }))
        
        
        if cnt % 2 == 0 {
            let median = Double((solves[cnt/2].timeIncPen + solves[(cnt/2)-1].timeIncPen)/2)
            
            if let truncatedMin = truncatedValues.0, let truncatedMax = truncatedValues.1 {
                
                return (median, ((median-truncatedMin)/(truncatedMax-truncatedMin)))
            }
            
            return (median, nil)
            
            
        } else {
            // I don't know why this is needed
            if !solves.indices.contains(cnt/2) {
                return (nil, nil)
            }
            let median = Double(solves[(cnt/2)].timeIncPen)
            
            if let truncatedMin = truncatedValues.0, let truncatedMax = truncatedValues.1 {
                
                
                return (median, ((median-truncatedMin)/(truncatedMax-truncatedMin)))
            }
            
            return (median, nil)
        }
    }
    
    
    func getCurrentAverage(of period: Int) -> CalculatedAverage? {
        if solvesByDate.count < period {
            return nil
        }
        
        return Self.getCalculatedAverage(forSolves: solvesByDate.suffix(period), name: "current ao", isCompsim: false)
    }
}



// MARK: - STATS: CACHE STATS
extension StopwatchManager {
    func changedTimeListSort() {
        let s: [Solve] = timeListSortBy == .date ? solvesByDate : solves
        timeListSolves = timeListAscending ? s : s.reversed()
        filterTimeList()
    }
    
    
    func filterTimeList() {
        if timeListFilter.isEmpty {
            timeListSolvesFiltered = timeListSolves
        } else {


            timeListSolvesFiltered = timeListSolves.filter{
                let time = if let multiphaseSolve = $0 as? MultiphaseSolve,
                    let phase = timeListShownPhase,
                    let phases = multiphaseSolve.phases,
                    let time = ([0] + phases).chunked().map({ $0[1] - $0[0] })[safe: Int(phase)] {
                        time
                    } else {
                        $0.time
                    }
                
                return formatSolveTime(secs: time).hasPrefix(timeListFilter) ||
                ($0.comment ?? "").lowercased().contains(timeListFilter.lowercased())
            }
        }
        
        if hasPenaltyOnly || hasCommentOnly {
            timeListSolvesFiltered = timeListSolvesFiltered.filter{
                (!hasPenaltyOnly || $0.penalty > 0) &&
                (!hasCommentOnly || !($0.comment?.isEmpty ?? true) )
            }
        }
        
        if scrambleTypeFilter >= 0 {
            timeListSolvesFiltered = timeListSolvesFiltered.filter {$0.scrambleType == Int32(scrambleTypeFilter)}
        }
    }
    
    func delete(solve: Solve) {
        removingSolve(solve: solve, removeFunc: managedObjectContext.delete)
    }
    
    #warning("Remember to update new stats when actually cache stats (if ever)")
    func moveSolve(solve: Solve, to: Session) {
        removingSolve(solve: solve, removeFunc: { solve in
            if let solve = solve as? MultiphaseSolve, (to.sessionType != SessionType.multiphase.rawValue) {
                #warning("Figure out how to cast")
                managedObjectContext.delete(solve)
                let nonMultiSolve = Solve(context: managedObjectContext)
                nonMultiSolve.comment = solve.comment
                nonMultiSolve.date = solve.date
                nonMultiSolve.penalty = solve.penalty
                nonMultiSolve.scramble = solve.scramble
                nonMultiSolve.scrambleType = solve.scrambleType
                nonMultiSolve.time = solve.time
                nonMultiSolve.session = to
            } else {
                solve.session = to
            }
        })
    }
    
    func delete(solveGroup: CompSimSolveGroup) {
        compsimSolveGroups.remove(object: solveGroup)
        managedObjectContext.delete(solveGroup)
        try! managedObjectContext.save()
        
        statsGetFromCache() // TODO not this :sob:
        // so much for cache stats
    }
    
    func removingSolve(solve: Solve, removeFunc: (Solve) -> ()) {
        #warning("TODO:  check best AOs")
        var recalcAO100 = false
        var recalcAO12 = false
        var recalcAO5 = false
        
        if (solvesByDate.suffix(100).contains(solve)) {
            recalcAO100 = true
            if (solvesByDate.suffix(12).contains(solve)) {
                recalcAO12 = true
                if (solvesByDate.suffix(5).contains(solve)) {
                    recalcAO5 = true
                }
            }
        }
        
        
        solves.remove(object: solve)
        solvesByDate.remove(object: solve)
        solvesNoDNFs.remove(object: solve)
        solvesNoDNFsbyDate.remove(object: solve)
        changedTimeListSort()
        
        removeFunc(solve)
        
        bestSingle = getMin() // Get min is super fast anyway
        phases = getAveragePhases()
        sessionMean = getSessionMean()
        
        if recalcAO100 {
            self.currentAo100 = getCurrentAverage(of: 100)
            if recalcAO12 {
                self.currentAo12 = getCurrentAverage(of: 12)
                if recalcAO5 {
                    self.currentAo5 = getCurrentAverage(of: 5)
                }
            }
        }
        
        self.bestAo5 = getBestAverage(of: 5)
        self.bestAo12 = getBestAverage(of: 12)
        self.bestAo100 = getBestAverage(of: 100)
        
        
        if currentSession is CompSimSession {
            let bpaWpa = getBpaWpa()
            self.bpa = bpaWpa.bpa
            self.wpa = bpaWpa.wpa
            self.timeNeededForTarget = getTimeNeededForTarget()
        }
        
        try! managedObjectContext.save()
        
        timerController.secondsStr = formatSolveTime(secs: SettingsManager.standard.showPrevTime ? (self.solvesByDate.last?.time ?? 0) : 0)
    }
    
    func updateCSSolveGroups() {
        if let currentSession = currentSession as? CompSimSession {
            // CSTODO verify order
            compsimSolveGroups = (currentSession.solvegroups!.allObjects as! [CompSimSolveGroup]).sorted(by: {
                // Object with no solves is more recent
                guard let firstSolve = $0.solves?.anyObject() else { return true }
                guard let secondSolve = $1.solves?.anyObject() else { return false }
                return (firstSolve as! CompSimSolve).date! >
                    (secondSolve as! CompSimSolve).date!
            })
        }
    }
        
    func statsGetFromCache() {
        #warning("TODO:  get from cache actually")
        let sessionSolves = currentSession.solves!.allObjects as! [Solve]
        let compSim = currentSession.sessionType == SessionType.compsim.rawValue
        updateCSSolveGroups()
        
        solves = sessionSolves.sorted(by: {$0.timeIncPen < $1.timeIncPen})
        solvesByDate = sessionSolves.sorted(by: {$0.date! < $1.date!})
        
        changedTimeListSort()
        
        solvesNoDNFsbyDate = solvesByDate
        solvesNoDNFsbyDate.removeAll(where: { $0.penalty == Penalty.dnf.rawValue })
        
        solvesNoDNFs = solves
        solvesNoDNFs.removeAll(where: { $0.penalty == Penalty.dnf.rawValue })
        
        if !compSim {
            bestAo5 = getBestAverage(of: 5)
            bestAo12 = getBestAverage(of: 12)
            bestAo100 = getBestAverage(of: 100)
        }
        
        
        currentAo5 = getCurrentAverage(of: 5)
        currentAo12 = getCurrentAverage(of: 12)
        currentAo100 = getCurrentAverage(of: 100)
        
        bestSingle = getMin()
        phases = getAveragePhases()
        sessionMean = getSessionMean()
        
        normalMedian = getNormalMedian()
        
        if compSim {
            compSimCount = getNumberOfAverages()
            reachedTargets = getReachedTargets()
            
            currentCompsimAverage = getCurrentCompsimAverage()
            bestCompsimAverage = getBestCompsimAverageAndArrayOfCompsimAverages().0
            
            
            let bpaWpa = getBpaWpa()
            self.bpa = bpaWpa.bpa
            self.wpa = bpaWpa.wpa
            
            self.timeNeededForTarget = getTimeNeededForTarget()
        }
        
        currentMeanOfTen = getCurrentMeanOfTen()
        bestMeanOfTen = getBestMeanOfTen()
    }
    
    
    func saveCache() {
        
    }
    
    func clearSession() {
        currentSession.solves?.forEach({managedObjectContext.delete($0 as! NSManagedObject)})
        try! managedObjectContext.save()
        statsGetFromCache()
        changedTimeListSort()
    }
    
    
    func updateStats() {
        #warning("TODO:  maybe make these async?")
        
        if currentSession.sessionType == SessionType.compsim.rawValue {
            statsGetFromCache()
            return
        }
        
        
        solvesByDate.append(solveItem)
        // These stats would require severe voodoo to not recalculate (TODO switch to voodoo), and are faily cheap
        self.currentAo5 = getCurrentAverage(of: 5)
        self.currentAo12 = getCurrentAverage(of: 12)
        self.currentAo100 = getCurrentAverage(of: 100)
        
        normalMedian = getNormalMedian()
        
        let bpaWpa = getBpaWpa()
        self.bpa = bpaWpa.bpa
        self.wpa = bpaWpa.wpa
        
        
        self.timeNeededForTarget = getTimeNeededForTarget()
        
        // Update sessionMean
        if solveItem.penalty != Penalty.dnf.rawValue { //TODO test if this really works with inspection
            sessionMean = ((sessionMean ?? 0) * Double(solvesNoDNFs.count) + solveItem.timeIncPen) / Double(solvesNoDNFs.count + 1)
            solvesNoDNFsbyDate.append(solveItem)
            
            let greatersolvenodnfidx = solvesNoDNFs.firstIndex(where: { $0.timeIncPen > solveItem.timeIncPen }) ?? solvesNoDNFs.count
            solvesNoDNFs.insert(solveItem, at: greatersolvenodnfidx)
            #warning("TODO:  use own extension")
            
            #warning("TODO:  update comp sim and phases")
        }
        let greatersolveidx = solves.firstIndex(where: {$0.timeIncPen > solveItem.timeIncPen}) ?? solves.count
        solves.insert(solveItem, at: greatersolveidx)
        
        bestSingle = getMin()
        #warning("TODO:  use optimize this with mean magic")
        phases = getAveragePhases()
        
        changedTimeListSort()
        
        #warning("TODO:  make these a dict instead")
        
        if let currentAo5 = currentAo5 {
            if bestAo5 == nil || ( // best is not set yet (and current is), or:
                    (currentAo5.totalPen, bestAo5!.totalPen) == (Penalty.dnf, Penalty.dnf)
                    || (currentAo5.totalPen, bestAo5!.totalPen) == (Penalty.none, Penalty.none)
                    && currentAo5 < bestAo5! // current is less than current best, and total pen is the same, or:
                )
                || (currentAo5.totalPen, bestAo5!.totalPen) == (Penalty.none, Penalty.dnf) { // current is none and best is dnf
                self.bestAo5 = currentAo5
                self.bestAo5?.name = "best ao5"
                #warning("TODO:  unhardcode")
            }
        }
        if let currentAo12 = currentAo12 {
            if bestAo12 == nil || ( // best is not set yet (and current is), or:
                    (currentAo12.totalPen, bestAo12!.totalPen) == (Penalty.dnf, Penalty.dnf)
                    || (currentAo12.totalPen, bestAo12!.totalPen) == (Penalty.none, Penalty.none)
                    && currentAo12 < bestAo12! // current is less than current best, and total pen is the same, or:
                )
                || (currentAo12.totalPen, bestAo12!.totalPen) == (Penalty.none, Penalty.dnf) { // current is none and best is dnf
                self.bestAo12 = currentAo12
                self.bestAo12?.name = "best ao12"
                #warning("TODO:  unhardcode")
            }
        }
        if let currentAo100 = currentAo100 {
            if bestAo100 == nil || ( // best is not set yet (and current is), or:
                    (currentAo100.totalPen, bestAo100!.totalPen) == (Penalty.dnf, Penalty.dnf)
                    || (currentAo100.totalPen, bestAo100!.totalPen) == (Penalty.none, Penalty.none)
                    && currentAo100 < bestAo100! // current is less than current best, and total pen is the same, or:
                )
                || (currentAo100.totalPen, bestAo100!.totalPen) == (Penalty.none, Penalty.dnf) { // current is none and best is dnf
                self.bestAo100 = currentAo100
                self.bestAo100?.name = "best ao100"
                #warning("TODO:  unhardcode")
            }
        }
        #warning("TODO:  save to cache")
    }
}



// MARK: - STATS: MULTIPHASE
extension StopwatchManager {
    func getAveragePhases() -> [Double]? {
        if currentSession is MultiphaseSession {
            let times = solvesNoDNFs.compactMap({ ($0 as? MultiphaseSolve)?.phases })
            
            var summedPhases = [Double](repeating: 0, count: phaseCount)
            
            for phase in times {
                var paddedPhase = phase
                paddedPhase.insert(0, at: 0)
                
                let mappedPhase = paddedPhase.chunked().map { $0[1] - $0[0] }
                
               
                for i in 0..<phaseCount {
                    summedPhases[i] += mappedPhase[i]
                }
            }
           
            
            return summedPhases.map({ $0 / Double(solvesNoDNFs.count) })
        } else {
            return nil
        }
    }
}



// MARK: - STATS: COMPSIM
extension StopwatchManager {
    func getNumberOfAverages() -> Int {
        return (solves.count / 5)
    }
        
    
    static func calculateAverage(forCompsimGroup group: CompSimSolveGroup) -> Double {
        return Self.calculateAverage(forSortedSolves: group.orderedSolves, count: 5, trim: 1)
    }
    
    func getReachedTargets() -> Int {
        var reached = 0
        
        if let compsimSession = currentSession as? CompSimSession {
            for solvegroup in compsimSolveGroups {
                if solvegroup.solves!.count != 5 { continue }
                
                let average = Self.calculateAverage(forCompsimGroup: solvegroup)
                
                if (average <= compsimSession.target) {
                    reached += 1
                }
            }
        }
        
        return reached
    }
    
    
    func getCurrentCompsimAverage() -> CalculatedAverage? {
        if currentSession is CompSimSession {
            
            let groupCount = compsimSolveGroups!.count
            
            if groupCount == 0 {
                return nil
            } else if groupCount == 1 {
                let groupLastSolve = compsimSolveGroups.first!.solves!.allObjects as! [Solve]
                
                if groupLastSolve.count != 5 {
                    return nil
                } else {
                    return Self.getCalculatedAverage(forSolves: groupLastSolve, name: "current compsim", isCompsim: true)
                }
                
            } else {
                let groupLastTwoSolves = compsimSolveGroups.prefix(2)
                
                let lastInGroup = groupLastTwoSolves.first!.solves!.allObjects as! [Solve]
                
                if lastInGroup.count == 5 {
                    
                    return Self.getCalculatedAverage(forSolves: lastInGroup, name: "current compsim", isCompsim: true)
                } else {
                    
                    return Self.getCalculatedAverage(forSolves: (groupLastTwoSolves.last!.solves!.allObjects as! [Solve]), name: "current compsim", isCompsim: true)
                }
            }
        } else {
            return nil
        }
    }
    
    
    func getBestCompsimAverageAndArrayOfCompsimAverages() -> (CalculatedAverage?, [CalculatedAverage]) {
        var allCompsimAverages: [CalculatedAverage] = []
        
        if let compsimSession = currentSession as? CompSimSession {
            if compsimSession.solvegroups!.count == 0 {
                return (nil, [])
            } else if compsimSession.solvegroups!.count == 1 && compsimSolveGroups.first!.orderedSolves.count != 5  {
                /// && ((compsimSession.solvegroups!.first as AnyObject).solves!.array as! [Solves]).count != 5
                return (nil, [])
            } else {
                var bestAverage: CalculatedAverage?
//                var bestAverage: CalculatedAverage = calculateAverage(((compsimSession.solvegroups!.firstObject as! CompSimSolveGroup).solves!.array as! [Solves]), "Best Compsim", true)!
                
                for solvegroup in compsimSolveGroups {
                    if solvegroup.solves!.allObjects.count == 5 {
                        
                        
                        let currentAvg = Self.getCalculatedAverage(forSolves: solvegroup.solves!.allObjects as! [Solve], name: "best compsim", isCompsim: true)
                        
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
        if currentSession is CompSimSession {
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
        if currentSession is CompSimSession {
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
        
    func calculateMean(of count: Int, for solves: [Solve]) -> Average {
        let penalty: Penalty = solves.contains(where: { Penalty(rawValue: $0.penalty) == .dnf }) ? .dnf : .none
        let average: Double = solves.reduce(0, { $0 + $1.timeIncPen }) / Double(count)
        
        return Average(average: average, penalty: penalty)
    }
    
   
    func getBpaWpa() -> (bpa: Average?, wpa: Average?) {
        if !(currentSession is CompSimSession) { return (nil, nil) }
        
        let solveGroups = compsimSolveGroups!
                    
        if (solveGroups.count == 0) { return (nil, nil) }
        
        guard let lastGroupSolves = (compsimSolveGroups.first?.solves?.allObjects as? [Solve]) else { return (nil, nil) }
        
        if (lastGroupSolves.count == 4) {
            let sortedGroup = lastGroupSolves.sorted(by: Self.sortWithDNFsLast)
            
            let bpa = calculateMean(of: 3, for: Array(sortedGroup.dropLast()))
            let wpa = calculateMean(of: 3, for: Array(sortedGroup.dropFirst()))
            
            return (bpa, wpa)
        }
        
        return (nil, nil)
    }
    
    
    func getTimeNeededForTarget() -> TimeNeededForTarget? {
        if let compsimSession = currentSession as? CompSimSession {
            let solveGroups = compsimSolveGroups!
            
            let target = compsimSession.target
            
            if let bpa = self.bpa, let wpa = self.wpa {
                if wpa.average < target && wpa.penalty != .dnf {
                    return .guaranteed
                } else if bpa.average > target {
                    return .notPossible
                } else {
                    let lastGroupSolves = (solveGroups.first!.solves!.allObjects as! [Solve])
                    let sortedGroup = lastGroupSolves.sorted(by: Self.sortWithDNFsLast)
                    let timeNeededForTarget = (compsimSession as CompSimSession).target * 3 - (sortedGroup.dropFirst().dropLast().reduce(0) {$0 + $1.timeIncPen})
                    return .value(timeNeededForTarget)
                }
            }
        } else { return nil }
        
        return nil
    }
    
    static func getTrimSizeEachEnd(_ n: Int) -> Int {
        return (n <= 12) ? 1 : Int(n / 20)
    }
    
    static func getTrimSizeEachEnd(_ n: Int32) -> Int32 {
        return (n <= 12) ? 1 : Int32(n / 20)
    }
    
    func getBestAverage(of width: Int32) -> CalculatedAverage? {
        let count: Int32 = Int32(solvesByDate.count);
        let solveDoubles = solvesByDate.map{ $0.timeIncPenDNFMax };
        
        let trim: Int32 = Self.getTrimSizeEachEnd(width)
        
        var countedSolvesIndices: [Int32] = Array(repeating: 0, count: Int(width - trim*2))
        var trimmedSolvesIndices: [Int32] = Array(repeating: 0, count: Int(trim*2))
        
        let bestAverage: Double = getBestAverageOf(width, trim, count,
                                                   solveDoubles,
                                                   &countedSolvesIndices, &trimmedSolvesIndices);
        
        if (bestAverage.isNaN) {
            return nil
        } else {
            let trimmedSolves = trimmedSolvesIndices.map({ solvesByDate[Int($0)] })
            let allSolves = trimmedSolves + countedSolvesIndices.map({ solvesByDate[Int($0)] })
            
            if (bestAverage == .infinity) {
                return CalculatedAverage(name: "best ao \(width)",
                                         average: bestAverage,
                                         accountedSolves: allSolves,
                                         totalPen: .dnf,
                                         trimmedSolves: trimmedSolves)
            } else {
                return CalculatedAverage(name: "best ao\(width)",
                                         average: bestAverage,
                                         accountedSolves: allSolves,
                                         totalPen: .none,
                                         trimmedSolves: trimmedSolves)
            }
        }
    }
}
