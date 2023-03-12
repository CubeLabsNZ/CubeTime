import Foundation
import CoreData

extension StopwatchManager {
    static func getCalculatedAverage(forSolves solves: [Solves], name: String, isCompsim: Bool) -> CalculatedAverage? {
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
        
        let solvesSorted: [Solves] = solves.sorted(by: Self.sortWithDNFsLast)
        let isDNF = solvesSorted[solvesSorted.endIndex.advanced(by: -(trim + 1))].penalty == Penalty.dnf.rawValue
        let solvesTrimmed: [Solves] = solvesSorted.prefix(trim) + solvesSorted.suffix(trim)
        
        return CalculatedAverage(
            name: "\(name)" + (isCompsim ? "" : "\(count)"),
            average: calculateAverage(forSortedSolves: solvesSorted, count: count, trim: trim),
            accountedSolves: solvesSorted.suffix(count),
            totalPen: isDNF ? .dnf : .none,
            trimmedSolves: solvesTrimmed
        )
    }
    
    
    static func calculateAverage(forSortedSolves sortedSolves: [Solves], count: Int, trim: Int) -> Double {
        let sum = sortedSolves[trim..<(count-trim)].reduce(0, { $0 + $1.timeIncPen })
        return sum / (Double(count - (trim * 2)))
    }
    
    #warning("todo make generic :quesitopn?")
    static func calculateAverage(forSortedSolves sortedSolves: [SimpleSolve], count: Int, trim: Int) -> Double {
        let sum = sortedSolves[trim..<(count-trim)].reduce(0, { $0 + $1.timeIncPen })
        return sum / (Double(count - (trim * 2)))
    }
    
    
    static func sortWithDNFsLast(_ solve0: Solves, _ solve1: Solves) -> Bool {
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
    func getMin() -> Solves? {
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
        
        let truncatedValues = getTruncatedMinMax(numbers: getDivisions(data: solvesNoDNFs.map { timeWithPlusTwoForSolve($0) }))
        
        
        if cnt % 2 == 0 {
            let median = Double((solves[cnt/2].timeIncPen + solves[(cnt/2)-1].timeIncPen)/2)
            
            if let truncatedMin = truncatedValues.0, let truncatedMax = truncatedValues.1 {
                
                return (median, ((median-truncatedMin)/(truncatedMax-truncatedMin)))
            }
            
            return (median, nil)
            
            
        } else {
            let median = Double(solves[(cnt/2)].timeIncPen)
            
            if let truncatedMin = truncatedValues.0, let truncatedMax = truncatedValues.1 {
                
                
                return (median, ((median-truncatedMin)/(truncatedMax-truncatedMin)))
            }
            
            return (median, nil)
        }
    }
    
    
    func getCurrentAverageOf(_ period: Int) -> CalculatedAverage? {
        if solvesByDate.count < period {
            return nil
        }
        
        return Self.getCalculatedAverage(forSolves: solvesByDate.suffix(period), name: "Current ao", isCompsim: false)
    }
}



// MARK: - STATS: CACHE STATS
extension StopwatchManager {
    func changedTimeListSort() {
        let s: [Solves] = timeListSortBy == .date ? solvesByDate : solves
        timeListSolves = timeListAscending ? s : s.reversed()
        filterTimeList()
    }
    
    
    func filterTimeList() {
        if timeListFilter.isEmpty {
            timeListSolvesFiltered = timeListSolves
        } else {
            timeListSolvesFiltered = timeListSolves.filter{ formatSolveTime(secs: $0.time).hasPrefix(timeListFilter) }
        }
        
        if hasPenaltyOnly || hasCommentOnly {
            timeListSolvesFiltered = timeListSolvesFiltered.filter{
                (!hasPenaltyOnly || $0.penalty > 0) &&
                (!hasCommentOnly || !($0.comment?.isEmpty ?? true) )
            }
        }
        
        if scrambleTypeFilter >= 0 {
            timeListSolvesFiltered = timeListSolvesFiltered.filter {$0.scramble_type == Int32(scrambleTypeFilter)}
        }
    }
    
    func delete(solve: Solves) {
        removingSolve(solve: solve, removeFunc: managedObjectContext.delete)
    }
    
    #warning("Remember to update new stats when actually cache stats (if ever)")
    func moveSolve(solve: Solves, to: Sessions) {
        removingSolve(solve: solve, removeFunc: { solve in
            if let solve = solve as? MultiphaseSolve, (to.session_type != SessionType.multiphase.rawValue) {
                #warning("Figure out how to cast")
                managedObjectContext.delete(solve)
                let nonMultiSolve = Solves(context: managedObjectContext)
                nonMultiSolve.comment = solve.comment
                nonMultiSolve.date = solve.date
                nonMultiSolve.penalty = solve.penalty
                nonMultiSolve.scramble = solve.scramble
                nonMultiSolve.scramble_subtype = solve.scramble_subtype
                nonMultiSolve.scramble_type = solve.scramble_type
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
    
    func removingSolve(solve: Solves, removeFunc: (Solves) -> ()) {
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
        
        if recalcAO100 {
            self.currentAo100 = getCurrentAverageOf(100)
            if recalcAO12 {
                self.currentAo12 = getCurrentAverageOf(12)
                if recalcAO5 {
                    self.currentAo5 = getCurrentAverageOf(5)
                }
            }
        }
        
        self.bestAo5 = getBestAverage(of: 5)
        self.bestAo12 = getBestAverage(of: 12)
        self.bestAo100 = getBestAverage(of: 100)
        
        try! managedObjectContext.save()
        
        timerController.secondsStr = formatSolveTime(secs: SettingsManager.standard.showPrevTime ? (self.solvesByDate.last?.time ?? 0) : 0)
    }
    
        
    func statsGetFromCache() {
        #warning("TODO:  get from cache actually")
        let sessionSolves = currentSession.solves!.allObjects as! [Solves]
        var compSim = false
        if let currentSession = currentSession as? CompSimSession {
            compSim = true
            compsimSolveGroups = (currentSession.solvegroups!.array as! [CompSimSolveGroup])
        }
        
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
        
        
        currentAo5 = getCurrentAverageOf(5)
        currentAo12 = getCurrentAverageOf(12)
        currentAo100 = getCurrentAverageOf(100)
        
        bestSingle = getMin()
        phases = getAveragePhases()
        sessionMean = getSessionMean()
        
        normalMedian = getNormalMedian()
        
        if compSim {
            compSimCount = getNumberOfAverages()
            reachedTargets = getReachedTargets()
            
            currentCompsimAverage = getCurrentCompsimAverage()
            bestCompsimAverage = getBestCompsimAverageAndArrayOfCompsimAverages().0
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
        
        if currentSession.session_type == SessionType.compsim.rawValue {
            statsGetFromCache()
            return
        }
        
        
        solvesByDate.append(solveItem)
        // These stats would require severe voodoo to not recalculate (TODO switch to voodoo), and are faily cheap
        self.currentAo5 = getCurrentAverageOf(5)
        self.currentAo12 = getCurrentAverageOf(12)
        self.currentAo100 = getCurrentAverageOf(100)
        
        normalMedian = getNormalMedian()
        
        let bpawpa = getWpaBpa()
        self.bpa = bpawpa.0
        self.wpa = bpawpa.1
        
        self.timeNeededForTarget = getTimeNeededForTarget()
        
        // Update sessionMean
        if solveItem.penalty != Penalty.dnf.rawValue { //TODO test if this really works with inspection
            sessionMean = ((sessionMean ?? 0) * Double(solvesNoDNFs.count) + timeWithPlusTwoForSolve(solveItem)) / Double(solvesNoDNFs.count + 1)
            solvesNoDNFsbyDate.append(solveItem)
            
            let greatersolvenodnfidx = solvesNoDNFs.firstIndex(where: {timeWithPlusTwoForSolve($0) > timeWithPlusTwoForSolve(solveItem)}) ?? solvesNoDNFs.count
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
                self.bestAo5?.name = "Best ao5"
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
                self.bestAo12?.name = "Best ao12"
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
                self.bestAo100?.name = "Best ao100"
                #warning("TODO:  unhardcode")
            }
        }
        #warning("TODO:  save to cache")
    }
}



// MARK: - STATS: MULTIPHASE
extension StopwatchManager {
    func getAveragePhases() -> [Double]? {
        if let multiphaseSession = currentSession as? MultiphaseSession {
            let times = (solvesNoDNFs as! [MultiphaseSolve]).map({ $0.phases! })
            
            
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
        print(solves.count)
        return (solves.count / 5)
    }
        
    
    static func calculateAverage(forCompsimGroup group: Any) -> Double {
        let solves = ((group as AnyObject).solves!?.array as! [Solves]).sorted()
        
        return Self.calculateAverage(forSortedSolves: solves, count: 5, trim: 1)
    }
    
    func getReachedTargets() -> Int {
        var reached = 0
        
        if let compsimSession = currentSession as? CompSimSession {
            for solvegroup in compsimSession.solvegroups!.array {
                if (((solvegroup as AnyObject).solves!?.array as! [Solves]).count != 5) { continue }
                
                let average = Self.calculateAverage(forCompsimGroup: solvegroup)
                
                if (average <= compsimSession.target) {
                    reached += 1
                }
            }
        }
        
        return reached
    }
    
    
    func getCurrentCompsimAverage() -> CalculatedAverage? {
        if let compsimSession = currentSession as? CompSimSession {
            
            let groupCount = compsimSession.solvegroups!.count
            
            if groupCount == 0 {
                return nil
            } else if groupCount == 1 {
                let groupLastSolve = ((compsimSession.solvegroups!.lastObject as! CompSimSolveGroup).solves!.array as! [Solves])
                
                if groupLastSolve.count != 5 {
                    return nil
                } else {
                    return Self.getCalculatedAverage(forSolves: groupLastSolve, name: "Current Comp Sim", isCompsim: true)
                }
                
            } else {
                let groupLastTwoSolves = (compsimSession.solvegroups!.array as! [CompSimSolveGroup]).suffix(2)
                
                let lastInGroup = groupLastTwoSolves.last!.solves!.array as! [Solves]
                
                if lastInGroup.count == 5 {
                    
                    return Self.getCalculatedAverage(forSolves: lastInGroup, name: "Current Comp Sim", isCompsim: true)
                } else {
                    
                    return Self.getCalculatedAverage(forSolves: (groupLastTwoSolves.first!.solves!.array as! [Solves]), name: "Current Comp Sim", isCompsim: true)
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
            } else if compsimSession.solvegroups!.count == 1 && (((compsimSession.solvegroups!.firstObject as! CompSimSolveGroup).solves!.array as! [Solves]).count != 5)  {
                /// && ((compsimSession.solvegroups!.first as AnyObject).solves!.array as! [Solves]).count != 5
                return (nil, [])
            } else {
                var bestAverage: CalculatedAverage?
//                var bestAverage: CalculatedAverage = calculateAverage(((compsimSession.solvegroups!.firstObject as! CompSimSolveGroup).solves!.array as! [Solves]), "Best Comp Sim", true)!
                
                for solvegroup in compsimSession.solvegroups!.array {
                    if (solvegroup as AnyObject).solves!.array.count == 5 {
                        
                        
                        let currentAvg = Self.getCalculatedAverage(forSolves: (solvegroup as AnyObject).solves!.array as! [Solves], name: "Best Comp Sim", isCompsim: true)
                        
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
        
    
    func getWpaBpa() -> (Double?, Double?) {
        if let compsimSession = currentSession as? CompSimSession {
            let solveGroups = (compsimSession.solvegroups!.array as! [CompSimSolveGroup])
            
            if solveGroups.count == 0 { return (nil, nil) } else {
                let lastGroupSolves = (solveGroups.last!.solves!.array as! [Solves])
                if lastGroupSolves.count == 4 {
                    let sortedGroup = lastGroupSolves.sorted(by: Self.sortWithDNFsLast)
                    
                    let bpa = (sortedGroup.dropFirst().reduce(0) {$0 + $1.timeIncPen}) / 3.00
                    
                    let wpa = sortedGroup.contains(where: {$0.penalty == Penalty.dnf.rawValue}) ? -1 : (sortedGroup.dropLast().reduce(0) {$0 + $1.timeIncPen}) / 3.00
                    
                    return (bpa, wpa)
                }
            }
        } else { return (nil, nil) }
        
        return (nil, nil)
    }
    
    
    func getTimeNeededForTarget() -> TimeNeededForTarget? {
        if let compsimSession = currentSession as? CompSimSession {
            let solveGroups = (compsimSession.solvegroups!.array as! [CompSimSolveGroup])
            
            if solveGroups.count == 0 { return nil } else {
                let lastGroupSolves = (solveGroups.last!.solves!.array as! [Solves])
                if lastGroupSolves.count == 4 {
                    let sortedGroup = lastGroupSolves.sorted(by: Self.sortWithDNFsLast)
                    
                    let timeNeededForTarget = (compsimSession as CompSimSession).target * 3 - (sortedGroup.dropFirst().dropLast().reduce(0) {$0 + $1.timeIncPen})
                    
                    if timeNeededForTarget < sortedGroup.last!.time {
                        return .notPossible
                    } else if timeNeededForTarget > sortedGroup.first!.time && !sortedGroup.contains(where: {$0.penalty == Penalty.dnf.rawValue}) {
                        return .guaranteed
                    } else {
                        return .value(timeNeededForTarget)
                    }
                }
            }
        } else { return nil }
        
        return nil
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    /*
    func getBestAverage(of width: Int) -> CalculatedAverage? {
        precondition(width >= 5)
        
        if (solvesByDate.count < width) {
            return nil
        }
        
        var bestAverage: Double = Double.greatestFiniteMagnitude

        var sum: Double = 0
        var multiset: SortedBag<Solves> = SortedBag<Solves>()
        
        var accountedSolves: SortedBag<Solves> = SortedBag<Solves>()
        var minTrimmedSolves: SortedBag<Solves> = SortedBag<Solves>()
        var maxTrimmedSolves: SortedBag<Solves> = SortedBag<Solves>()
        
        let trimSize: Int = getTrimSizeEachEnd(width)
        
        // width of window - 1
        let beginWidth: Int = (width - 1)
        
        for i in 0 ..< beginWidth {
            sum += solvesByDate[i].timeIncPen
            multiset.insert(solvesByDate[i])
        }

        // rest of solves
        for i in beginWidth ..< solvesByDate.count {
            sum += solvesByDate[i].timeIncPen
            multiset.insert(solvesByDate[i])
            
            var sumTrimmed: Double = 0
            
            // if after trim, includes dnf => entire average dnf
            if (multiset[width - trimSize - 1].penalty == Penalty.dnf.rawValue) {
                return CalculatedAverage(name: "Best ao\(width)",
                                         average: nil,
                                         accountedSolves: nil,
                                         totalPen: Penalty.dnf,
                                         trimmedSolves: nil)
            }
            
            let tempMinTrim = multiset.prefix(trimSize)
            let tempMaxTrim = multiset.suffix(trimSize)
            
            // for ao5, ao12
            if (trimSize == 1) {
                sumTrimmed = multiset.first!.timeIncPen + multiset.last!.timeIncPen
            } else {  // for ao>12
                tempMinTrim.forEach({
                    sumTrimmed += $0.timeIncPen
                })
                tempMaxTrim.forEach({
                    sumTrimmed += $0.timeIncPen
                })
            }
            
            // todo add error checking
            let average: Double = (sum - sumTrimmed) / Double(width - (trimSize * 2))
            
            // if updates
            if (average < bestAverage) {
                bestAverage = average
                accountedSolves = multiset.suffix(solvesByDate.count - trimSize).prefix(solvesByDate.count - trimSize*2)
                minTrimmedSolves = tempMinTrim
                maxTrimmedSolves = tempMaxTrim
            }
            
            sum -= solvesByDate[i - width + 1].timeIncPen
            multiset.remove(solvesByDate[i - width + 1])
        }
        
        return CalculatedAverage(name: "Best ao\(width)",
                                 average: bestAverage,
                                 accountedSolves: Array(accountedSolves),
                                 totalPen: .none,
                                 trimmedSolves: Array(minTrimmedSolves) + Array(maxTrimmedSolves))
    }
     */
    
    static func getTrimSizeEachEnd(_ n: Int32) -> Int32 {
        return (n <= 12) ? 1 : Int32(n / 20)
    }
    
    func getBestAverage(of width: Int32) -> CalculatedAverage? {
        let count: Int32 = Int32(solvesByDate.count);
        let solveDoubles = solvesByDate.map{ $0.timeIncPenDNFMax };
        
        let trim: Int32 = Self.getTrimSizeEachEnd(width)
        
        var countedSolvesIndices: [Int32] = Array(repeating: 0, count: Int(width - trim*2))
        var trimmedSolvesIndices: [Int32] = Array(repeating: 0, count: Int(trim*2))
        
        // getBestAverageOf(width:,trim:,solvesCount:,solves:
        //                  [return into] accountedSolves:,trimmedSolves:)
        let bestAverage: Double = getBestAverageOf(width, trim, count,
                                                   solveDoubles,
                                                   &countedSolvesIndices, &trimmedSolvesIndices);
        
        if (bestAverage.isNaN) {
            return nil
        } else {
            let trimmedSolves = trimmedSolvesIndices.map({ solvesByDate[Int($0)] })
            let allSolves = trimmedSolves + countedSolvesIndices.map({ solvesByDate[Int($0)] })
            
            if (bestAverage == .infinity) {
                return CalculatedAverage(name: "Best ao \(width)",
                                         average: bestAverage,
                                         accountedSolves: allSolves,
                                         totalPen: .dnf,
                                         trimmedSolves: trimmedSolves)
            } else {
                return CalculatedAverage(name: "Best ao\(width)",
                                         average: bestAverage,
                                         accountedSolves: allSolves,
                                         totalPen: .none,
                                         trimmedSolves: trimmedSolves)
            }
        }
    }
}











