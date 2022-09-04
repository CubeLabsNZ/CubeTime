import Foundation
import CoreData
import SwiftUI



extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
    
}




let plustwotime = 15
let dnftime = 17


enum stopWatchMode {
    case running
    case stopped
    case inspecting
}

class StopWatchManager: ObservableObject {
    @Published var currentSession: Sessions {
        didSet {
            if currentSession.session_type == SessionTypes.playground.rawValue {
                NSLog("sesion is play, setting scramble to \(currentSession.scramble_type)")
                playgroundScrambleType = currentSession.scramble_type
            } else {
                rescramble()
                tryUpdateCurrentSolveth()
            }
            statsGetFromCache()
            UserDefaults.standard.set(currentSession.objectID.uriRepresentation(), forKey: "last_used_session")
        }
    }
    let managedObjectContext: NSManagedObjectContext
    
    
    var hapticType: Int = UserDefaults.standard.integer(forKey: gsKeys.hapType.rawValue)
    var hapticEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.hapBool.rawValue)
    var inspectionEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.inspection.rawValue)
    var timeDP: Int = UserDefaults.standard.integer(forKey: gsKeys.timeDpWhenRunning.rawValue)
    var insCountDown: Bool = UserDefaults.standard.bool(forKey: gsKeys.inspectionCountsDown.rawValue)

    
    var feedbackStyle: UIImpactFeedbackGenerator?
    
    
    @Published var scrambleStr: String? = nil
    @Published var scrambleSVG: OrgWorldcubeassociationTnoodleSvgliteSvg? = nil
    var prevScrambleStr: String! = nil
    
    @Published var secondsStr = ""
    var secondsElapsed = 0.0
    
    
    @Published var mode: stopWatchMode = .stopped
    @Published var showDeleteSolveConfirmation = false
    @Published var showPenOptions = false
    @Published var currentSolveth: Int?
    @Published var inspectionSecs = 0
    @Published var timerColour: Color = TimerTextColours.timerDefaultColour
    
    @Published var solveItem: Solves!
    
    
    var penType: PenTypes = .none
    
    
    init (currentSession: Sessions, managedObjectContext: NSManagedObjectContext) {
        self.currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        self.playgroundScrambleType = currentSession.scramble_type
        self.targetStr = filteredStrFromTime((currentSession as? CompSimSession)?.target)
        self.phaseCount = Int((currentSession as? MultiphaseSession)?.phase_count ?? 0)
        
        secondsStr = formatSolveTime(secs: 0)
        statsGetFromCache()
        calculateFeedbackStyle()
//        scrambler.initSq1()
        self.rescramble()
        
        tryUpdateCurrentSolveth()
        print("initialised")
    }

    func calculateFeedbackStyle() {
        self.feedbackStyle = hapticEnabled ? UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.init(rawValue: hapticType)!) : nil
    }
    
    func tryUpdateCurrentSolveth() {
        if let currentSession = currentSession as? CompSimSession {
            if currentSession.solvegroups!.count > 0 {
                currentSolveth = (currentSession.solvegroups!.lastObject! as! CompSimSolveGroup).solves!.count
            } else {
                currentSolveth = 0
            }
        }
    }
    

    var timer: Timer?
    
    private var timerStartTime: Date?
    
    
    var prevDownStoppedTimer = false
    var justInspected = false
    
    // multiphase temporary variables
    var currentMPCount: Int = 1
    var phaseTimes: [Double] = []
    
    var canGesture: Bool = true
    
    var nilSolve: Bool = true
    
    func startInspection() {
        timer?.invalidate()
        penType = .none // reset penType from last solve
        secondsStr = insCountDown ? "15" : "0"
        inspectionSecs = 0
        mode = .inspecting
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            inspectionSecs += 1
            if insCountDown {
                if inspectionSecs == 16 {
                    self.secondsStr = "-"
                } else if inspectionSecs < 16 {
                    self.secondsStr = String(15 - inspectionSecs)
                }
            } else {
                self.secondsStr = String(inspectionSecs)
            }
            if inspectionSecs == plustwotime {
                penType = .plustwo
            } else if inspectionSecs == dnftime {
                penType = .dnf
            }
        }
    }
    
    func interruptInspection() {
        mode = .stopped
        timer?.invalidate()
        inspectionSecs = 0
        secondsElapsed = 0
        justInspected = false
        secondsStr = formatSolveTime(secs: self.secondsElapsed, dp: timeDP)
        
    }

    
    
    
    func start() {
        #if DEBUG
        NSLog("starting")
        #endif
        mode = .running

        timer?.invalidate() // Stop possibly running inspections

        secondsElapsed = 0
        secondsStr = formatSolveTime(secs: 0)
        timerStartTime = Date()

        if timeDP != -1 {
            timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [self] timer in
                self.secondsElapsed = -timerStartTime!.timeIntervalSinceNow
                self.secondsStr = formatSolveTime(secs: self.secondsElapsed, dp: timeDP)
            }
        } else {
            self.secondsStr = "..."
        }
    }
    
    
    func stop(_ time: Double?) {
        #if DEBUG
        NSLog("stopping")
        #endif
        timer?.invalidate()
        
        if let time = time {
            self.secondsElapsed = time
        } else {
            self.secondsElapsed = -timerStartTime!.timeIntervalSinceNow
        }
        
        self.secondsStr = formatSolveTime(secs: self.secondsElapsed)
        mode = .stopped

        if let currentSession = currentSession as? CompSimSession {
            solveItem = CompSimSolve(context: managedObjectContext)
            if currentSession.solvegroups == nil {
                currentSession.solvegroups = NSOrderedSet()
            }
                                
            if currentSession.solvegroups!.count == 0 || currentSolveth == 5 {
                let solvegroup = CompSimSolveGroup(context: managedObjectContext)
                solvegroup.session = currentSession
                
            }
            
            (solveItem as! CompSimSolve).solvegroup = (currentSession.solvegroups!.lastObject! as! CompSimSolveGroup)
            currentSolveth = (currentSession.solvegroups!.lastObject! as? CompSimSolveGroup)!.solves!.count

        } else {
            if let _ = currentSession as? MultiphaseSession {
                solveItem = MultiphaseSolve(context: managedObjectContext)
                
                (solveItem as! MultiphaseSolve).phases = phaseTimes
                
                currentMPCount = 1
                phaseTimes = []
            } else {
                solveItem = Solves(context: managedObjectContext)
            }
        }
        
        
        solveItem.date = Date()
        solveItem.penalty = penType.rawValue
        // .puzzle_id
        solveItem.session = currentSession
        // Use the current scramble if stopped from manual input
        solveItem.scramble = time == nil ? prevScrambleStr : scrambleStr
        solveItem.scramble_type = currentSession.scramble_type
        solveItem.scramble_subtype = 0
        solveItem.time = self.secondsElapsed
        try! managedObjectContext.save()
        
        // Rescramble if from manual input
        if time != nil {
            rescramble()
        }
        
        updateStats()
    }
    
    func lap() {
        phaseTimes.append(-timerStartTime!.timeIntervalSinceNow)
    }
    
    
    func touchDown() {
        #if DEBUG
        NSLog("touch down")
        #endif
        if mode != .stopped || scrambleStr != nil || prevDownStoppedTimer {
            timerColour = TimerTextColours.timerHeldDownColour
        }
        
        if mode == .running {
            
            justInspected = false
            
            if let multiphaseSession = currentSession as? MultiphaseSession {
                
                if phaseCount != currentMPCount {
                    canGesture = false
                    
                    currentMPCount += 1
                    lap()
                } else {
                    canGesture = true
                    
                    lap()
                    prevDownStoppedTimer = true
                    justInspected = false
                    stop(nil)
                }
            } else {
                canGesture = true
                prevDownStoppedTimer = true
                justInspected = false
                stop(nil)
            }
        }
    }
    
    
    func touchUp() {
        #if DEBUG
        NSLog("touchup")
        #endif
        if mode != .stopped || scrambleStr != nil {
            timerColour = TimerTextColours.timerDefaultColour
            
            if inspectionEnabled && mode == .stopped && !prevDownStoppedTimer {
                startInspection()
                justInspected = true
            }
        } else if prevDownStoppedTimer && scrambleStr == nil {
            timerColour = TimerTextColours.timerLoadingColor
        }
        
        
        if showPenOptions {
            withAnimation {
                showPenOptions = false
            }
        }
        prevDownStoppedTimer = false
}
    
    
    func longPressStart() {
        #if DEBUG
        NSLog("long press start")
        #endif
        
        if inspectionEnabled ? mode == .inspecting : mode == .stopped && !prevDownStoppedTimer && ( mode != .stopped || scrambleStr != nil ) {
            #if DEBUG
            NSLog("timer can start")
            #endif
            
            timerColour = TimerTextColours.timerCanStartColour
            feedbackStyle?.impactOccurred()
        }
    }
    
    func longPressEnd() {
        #if DEBUG
        NSLog("long press end")
        #endif
        if mode != .stopped || scrambleStr != nil {
            timerColour = TimerTextColours.timerDefaultColour
        } else if prevDownStoppedTimer && scrambleStr == nil {
            timerColour = TimerTextColours.timerLoadingColor
        }
        
        withAnimation {
            showPenOptions = false
        }
        
        if !prevDownStoppedTimer && ( mode != .stopped || scrambleStr != nil ) {
            if inspectionEnabled ? mode == .inspecting : mode == .stopped {
                start()
                rescramble()
            } else if inspectionEnabled && mode == .stopped && !justInspected {
                startInspection()
//                rescramble()
                justInspected = true
            }
        }
        
        prevDownStoppedTimer = false
    }
    
    /// OTHER FUNCS
    func changedPen(_ oldPen: PenTypes) {
        if oldPen.rawValue == solveItem.penalty {
            return
        }
        
        if PenTypes(rawValue: solveItem.penalty)! == .plustwo {
            withAnimation {
                secondsStr = formatSolveTime(secs: secondsElapsed, penType: PenTypes(rawValue: solveItem.penalty)!)
            }
        } else {
            secondsStr = formatSolveTime(secs: secondsElapsed, penType: PenTypes(rawValue: solveItem.penalty)!)
        }

        solves.remove(object: solveItem)
        solves.insert(solveItem, at: solves.insertionIndex(of: solveItem))
        
        
        if solveItem.penalty == PenTypes.dnf.rawValue {
            assert(solvesNoDNFsbyDate.popLast() == solveItem)
            solvesNoDNFs.remove(object: solveItem)
        } else if oldPen == PenTypes.dnf {
            solvesNoDNFsbyDate.append(solveItem)
            solvesNoDNFs.insert(solveItem, at: solvesNoDNFs.insertionIndex(of: solveItem))
        }
        
        
        // TODO next update use optimised versions

        bestAo5 = getBestMovingAverageOf(5)
        bestAo12 = getBestMovingAverageOf(12)
        bestAo100 = getBestMovingAverageOf(100)
        
        // TODO optimise
        sessionMean = getSessionMean()
        
        
        
        changedTimeListSort()
        bestSingle = getMin()
        
        currentAo5 = getCurrentAverageOf(5)
        currentAo12 = getCurrentAverageOf(12)
        currentAo100 = getCurrentAverageOf(100)
    }
    
    func safeGetScramble() -> String {
        return puzzle_types[Int(currentSession.scramble_type)].puzzle.getScrambler().generateScramble()
    }
    
    var scrambleWorkItem: DispatchWorkItem?
    
    func rescramble() {
        #if DEBUG
        NSLog("rescramble")
        #endif
        
        prevScrambleStr = scrambleStr
        scrambleStr = nil
        if mode == .stopped {
            self.timerColour = TimerTextColours.timerLoadingColor
        }
        scrambleSVG = nil
        let newWorkItem = DispatchWorkItem {
            #if DEBUG
            NSLog("running work item")
            #endif
            
            
            let scrTypeAtWorkStart = self.currentSession.scramble_type
            let scramble = self.safeGetScramble()

            /// This absolutely is not best practice, but I couldn't find another way to do it
            /// **PLEASE** file a PR or issue if you know of a better way
            /// TODO make this not actually continue the scramble ... . .
            if scrTypeAtWorkStart == self.currentSession.scramble_type {
                DispatchQueue.main.async {
                    self.scrambleStr = scramble
                    self.timerColour = TimerTextColours.timerDefaultColour
                }
                
                let svg = puzzle_types[Int(self.currentSession.scramble_type)].puzzle.getScrambler().drawScramble(with: scramble, with: nil)
            
                DispatchQueue.main.async {
                    self.scrambleSVG = svg
                }
            }
        }
        scrambleWorkItem = newWorkItem
        DispatchQueue.global(qos: .userInitiated).async(execute: newWorkItem)
    }
    
    func displayPenOptions() {
        
        if solveItem != nil {
            timerColour = TimerTextColours.timerDefaultColour
        }
        prevDownStoppedTimer = false
        
        withAnimation {
            showPenOptions = true
            nilSolve = (solveItem == nil)
        }
        
    }
    
    func askToDelete() {
        withAnimation {
            showPenOptions = false
        }
        
        timerColour = TimerTextColours.timerDefaultColour
        prevDownStoppedTimer = false

        if solveItem != nil {
            // todo
            showDeleteSolveConfirmation = true
        }
    }
    
    // Other stuff
    
    @Published var playgroundScrambleType: Int32 {
        didSet {
            NSLog("playgroundScrambleType didset to \(playgroundScrambleType)")
            currentSession.scramble_type = playgroundScrambleType
            try! managedObjectContext.save()
            // TODO do not rescramble when setting to same scramble eg 3blnd -> 3oh
            rescramble()
        }
    }
    @Published var targetStr: String
    @Published var phaseCount: Int
    
    // STATS
    
    // Stats used on timer
    @Published var currentAo5: CalculatedAverage?
    @Published var currentAo12: CalculatedAverage?
    @Published var currentAo100: CalculatedAverage?
    
    @Published var sessionMean: Double?
    
    @Published var bpa: Double?
    @Published var wpa: Double?
    
    @Published var timeNeededForTarget: Double?
    
    // Stats not on timer
    @Published var bestAo5: CalculatedAverage?
    @Published var bestAo12: CalculatedAverage?
    @Published var bestAo100: CalculatedAverage?
    
    
    // other block calculations
    @Published var bestSingle: Solves?
    
    
    // For some reason calling sub function to initialize more doesn't work well, must use !
    
    // comp sim stats
    @Published var compSimCount: Int!
    @Published var reachedTargets: Int!
    
    @Published var allCompsimAveragesByDate: [CompSimSolveGroup]! // has no dnfs!!
    @Published var allCompsimAveragesByTime: [CompSimSolveGroup]!
    
    @Published var bestCompsimAverage: CalculatedAverage?
    @Published var currentCompsimAverage: CalculatedAverage?
    
    @Published var currentMeanOfTen: Double?
    @Published var bestMeanOfTen: Double?
    
    @Published var phases: [Double]?
    
    
    @Published var normalMedian: (Double?, Double?)
    
    
    // On stop: insert where time with plustwoforzolve > $0
    private var solves: [Solves]!
    // On stop: just append to list
    @Published var solvesByDate: [Solves]!
    // Maybe use trickery to get object, maybe delete this array
    @Published var solvesNoDNFs: [Solves]!
    // On stop: just append if not dnf, remove if dnf
    @Published var solvesNoDNFsbyDate: [Solves]!
    
    
    // Couple time list functions
    private var timeListSolves: [Solves]!
    @Published var timeListSolvesFiltered: [Solves]!
    @Published var timeListFilter = "" // TODO make this refilter automatically
    @Published var timeListAscending = false {
        didSet {
            changedTimeListSort()
        }
    }
    @Published var timeListSortBy: SortBy = .date {
        didSet {
            changedTimeListSort()
        }
    }
    
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
    }
    
    @Published var stateID = UUID() // TODO fix this god awful hack
    
    func delete(solve: Solves) {
        // TODO check best AOs
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
        
        if bestSingle == solve {
            bestSingle = getMin()
        }
        
        managedObjectContext.delete(solve)
        
        if recalcAO100 {
            self.currentAo100 = getCurrentAverageOf(100)
            if recalcAO12 {
                self.currentAo12 = getCurrentAverageOf(12)
                if recalcAO5 {
                    self.currentAo5 = getCurrentAverageOf(5)
                }
            }
        }
        
        self.bestAo5 = getBestMovingAverageOf(5)
        self.bestAo12 = getBestMovingAverageOf(12)
        self.bestAo100 = getBestMovingAverageOf(100)
        
        try! managedObjectContext.save()
    }
    
    func changePen(solve: Solves, pen: PenTypes) {
        // TODO check best AOs
        if solve.penalty == pen.rawValue {
            return
        }
        let oldPen = PenTypes(rawValue: solve.penalty)!
        
        
        solve.penalty = pen.rawValue
        
        solves.remove(object: solve)
        solves.insert(solve, at: solves.insertionIndex(of: solve))
        
        
        if solve.penalty == PenTypes.dnf.rawValue {
            solvesNoDNFsbyDate.insert(solve, at: solvesNoDNFsbyDate.insertionIndexDate(solve: solve))
            solvesNoDNFs.insert(solve, at: solvesNoDNFs.insertionIndex(of: solve))
        } else if oldPen == PenTypes.dnf {
            solvesNoDNFsbyDate.remove(object: solve)
            solvesNoDNFs.remove(object: solve)
        }
        
        
        
        if (solvesByDate.suffix(100).contains(solve)) {
            self.currentAo100 = getCurrentAverageOf(100)
            if (solvesByDate.suffix(12).contains(solve)) {
                self.currentAo12 = getCurrentAverageOf(12)
                if (solvesByDate.suffix(5).contains(solve)) {
                    self.currentAo5 = getCurrentAverageOf(5)
                }
            }
        }
        
        self.bestAo5 = getBestMovingAverageOf(5)
        self.bestAo12 = getBestMovingAverageOf(12)
        self.bestAo100 = getBestMovingAverageOf(100)
        
        stateID = UUID() // I'm so sorry
        
        try! managedObjectContext.save()
    }
    
    func statsGetFromCache() {
        // Todo get from cache actually
        let sessionSolves = currentSession.solves!.allObjects as! [Solves]
        
        solves = sessionSolves.sorted(by: {$0.timeIncPen < $1.timeIncPen})
        solvesByDate = sessionSolves.sorted(by: {$0.date! < $1.date!})
        
        changedTimeListSort()
        
        solvesNoDNFsbyDate = solvesByDate
        solvesNoDNFsbyDate.removeAll(where: { $0.penalty == PenTypes.dnf.rawValue })
        
        solvesNoDNFs = solves
        solvesNoDNFs.removeAll(where: { $0.penalty == PenTypes.dnf.rawValue })
        
        
        bestAo5 = getBestMovingAverageOf(5)
        bestAo12 = getBestMovingAverageOf(12)
        bestAo100 = getBestMovingAverageOf(100)
        
        currentAo5 = getCurrentAverageOf(5)
        currentAo12 = getCurrentAverageOf(12)
        currentAo100 = getCurrentAverageOf(100)
        
        bestSingle = getMin()
        sessionMean = getSessionMean()
    }
    
    func saveCache() {
        
    }
    
    func updateStats() {
        // TODO maybe make these async?
        
        solvesByDate.append(solveItem)
        // These stats would require severe voodoo to not recalculate (TODO switch to voodoo), and are faily cheap
        self.currentAo5 = getCurrentAverageOf(5)
        self.currentAo12 = getCurrentAverageOf(12)
        self.currentAo100 = getCurrentAverageOf(100)
        
        let bpawpa = getWpaBpa()
        self.bpa = bpawpa.0
        self.wpa = bpawpa.1
        
        self.timeNeededForTarget = getTimeNeededForTarget()
        
        // Update sessionMean
        if solveItem.penalty != PenTypes.dnf.rawValue { //TODO test if this really works with inspection
            sessionMean = ((sessionMean ?? 0) * Double(solvesNoDNFs.count) + timeWithPlusTwoForSolve(solveItem)) / Double(solvesNoDNFs.count + 1)
            solvesNoDNFsbyDate.append(solveItem)
            
            let greatersolvenodnfidx = solvesNoDNFs.firstIndex(where: {timeWithPlusTwoForSolve($0) > timeWithPlusTwoForSolve(solveItem)}) ?? solvesNoDNFs.count
            solvesNoDNFs.insert(solveItem, at: greatersolvenodnfidx) // TODO use own extension
            
            if bestSingle == nil || solveItem.timeIncPen < bestSingle!.timeIncPen {
                bestSingle = solveItem
            }
            
            // TODO update comp sim and phases
        }
        let greatersolveidx = solves.firstIndex(where: {$0.timeIncPen > solveItem.timeIncPen}) ?? solves.count
        solves.insert(solveItem, at: greatersolveidx)
        
        changedTimeListSort()
        
        // todo make these a dict instead
        
        if let currentAo5 = currentAo5 {
            if bestAo5 == nil || ( // best is not set yet (and current is), or:
                    (currentAo5.totalPen, bestAo5!.totalPen) == (PenTypes.dnf, PenTypes.dnf)
                    || (currentAo5.totalPen, bestAo5!.totalPen) == (PenTypes.none, PenTypes.none)
                    && currentAo5 < bestAo5! // current is less than current best, and total pen is the same, or:
                )
                || (currentAo5.totalPen, bestAo5!.totalPen) == (PenTypes.none, PenTypes.dnf) { // current is none and best is dnf
                self.bestAo5 = currentAo5
                self.bestAo5?.name = "Best ao5" // TODO unhardcode
                NSLog("updated best ao5: \(self.bestAo5 == currentAo5)")
            }
        }
        if let currentAo12 = currentAo12 {
            if bestAo12 == nil || ( // best is not set yet (and current is), or:
                    (currentAo12.totalPen, bestAo12!.totalPen) == (PenTypes.dnf, PenTypes.dnf)
                    || (currentAo12.totalPen, bestAo12!.totalPen) == (PenTypes.none, PenTypes.none)
                    && currentAo12 < bestAo12! // current is less than current best, and total pen is the same, or:
                )
                || (currentAo12.totalPen, bestAo12!.totalPen) == (PenTypes.none, PenTypes.dnf) { // current is none and best is dnf
                self.bestAo12 = currentAo12
                self.bestAo5?.name = "Best ao12" // TODO unhardcode
            }
        }
        if let currentAo100 = currentAo100 {
            if bestAo100 == nil || ( // best is not set yet (and current is), or:
                    (currentAo100.totalPen, bestAo100!.totalPen) == (PenTypes.dnf, PenTypes.dnf)
                    || (currentAo100.totalPen, bestAo100!.totalPen) == (PenTypes.none, PenTypes.none)
                    && currentAo100 < bestAo100! // current is less than current best, and total pen is the same, or:
                )
                || (currentAo100.totalPen, bestAo100!.totalPen) == (PenTypes.none, PenTypes.dnf) { // current is none and best is dnf
                self.bestAo100 = currentAo100
                self.bestAo5?.name = "Best ao100" // TODO unhardcode
            }
        }
        // TODO save to cache
    }
    
    
    // STATS FUNCTIONS
    static func calculateAverage(_ solves: [Solves], _ id: String, _ compsim: Bool) -> CalculatedAverage? {
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
        
        let solvesSorted: [Solves] = solves.sorted(by: Self.sortWithDNFsLast)
        let solvesTrimmed: [Solves] = solvesSorted.prefix(trim) + solvesSorted.suffix(trim)
        
        if compsim {
            return CalculatedAverage(
                name: "\(id)",
                average: solvesSorted.dropFirst(trim).dropLast(trim).reduce(0, {$0 + timeWithPlusTwoForSolve($1)}) / Double(cnt-(trim * 2)),
                accountedSolves: solvesSorted.suffix(cnt),
                totalPen: solvesSorted.suffix(cnt).filter {$0.penalty == PenTypes.dnf.rawValue}.count >= trim * 2 ? .dnf : .none,
                trimmedSolves: solvesTrimmed
            )
        } else {
            return CalculatedAverage(
                name: "\(id)\(cnt)",
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
            return solve0.timeIncPen < solve1.timeIncPen
        // Order non DNFs before DNFs
        } else {
            return pen0 != .dnf && pen1 == .dnf
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
        
        let truncatedValues = getTruncatedMinMax(numbers: getDivisions(data: solves))
        
        
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
    
    
    
    /// AVERAGE FUNCTIONS
    
    func getCurrentAverageOf(_ period: Int) -> CalculatedAverage? {
        if solvesByDate.count < period {
            return nil
        }
        
        return Self.calculateAverage(solvesByDate.suffix(period), "Current ao", false)
    }
    
    
    func getBestMovingAverageOf(_ period: Int) -> CalculatedAverage? {
        precondition(period > 1)
        if solvesByDate.count < period {
            return nil
        }
        
        let trim = period >= 100 ? 5 : 1
        
        
        var lowestAverage: Double?
        var lowestValues: [Solves]?
        var lowsetTrimmedSolves: [Solves]?
        var totalPen = PenTypes.none
        var lowestTotalPen = PenTypes.none
        
        for i in period..<solves.count+1 {
            var solves = solvesByDate[i - period..<i]
            solves.sort(by: Self.sortWithDNFsLast)
            
            let trimmedSolves = solves.suffix(trim) + solves.prefix(trim)
            
            let trimmed = solves.dropFirst(trim).dropLast(trim)
            
//            if trimmed.contains(where: {$0.penalty == PenTypes.dnf.rawValue}) {
//                continue
//            }
            totalPen = trimmed.last!.penalty == PenTypes.dnf.rawValue ? PenTypes.dnf : PenTypes.none
            let sum = trimmed.reduce(0, {$0 + $1.timeIncPen})
            
            let result = Double(sum) / Double(period-(trim*2))
            if lowestAverage == nil
                || (
                    result < lowestAverage!
                    && (
                        (totalPen, lowestTotalPen) == (PenTypes.dnf, PenTypes.dnf)
                        || (totalPen, lowestTotalPen) == (PenTypes.none, PenTypes.none)
                    )
                )
                || (totalPen, lowestTotalPen) == (PenTypes.none, PenTypes.dnf) {
                lowestValues = solvesByDate[i - period ..< i].sorted(by: {$0.date! > $1.date!})
                lowestAverage = result
                lowestTotalPen = totalPen
                lowsetTrimmedSolves = Array(trimmedSolves)
            }
        }
        return CalculatedAverage(name: "Best ao\(period)", average: lowestAverage, accountedSolves: lowestValues, totalPen: lowestTotalPen, trimmedSolves: lowsetTrimmedSolves)
    }

    
    
    
    /// COMP SIM STUFF
    
    func getNumberOfAverages() -> Int {
        return (solves.count / 5)
    }
        
    func getReachedTargets() -> Int {
        var reached = 0
        
        if let compsimSession = currentSession as? CompSimSession {
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
        if let compsimSession = currentSession as? CompSimSession {
            
            let groupCount = compsimSession.solvegroups!.count
            
            if groupCount == 0 {
                return nil
            } else if groupCount == 1 {
                let groupLastSolve = ((compsimSession.solvegroups!.lastObject as! CompSimSolveGroup).solves!.array as! [Solves])
                
                if groupLastSolve.count != 5 {
                    return nil
                } else {
                    return Self.calculateAverage(groupLastSolve, "Current Comp Sim", true)
                }
                
            } else {
                let groupLastTwoSolves = (compsimSession.solvegroups!.array as! [CompSimSolveGroup]).suffix(2)
                
                let lastInGroup = groupLastTwoSolves.last!.solves!.array as! [Solves]
                
                if lastInGroup.count == 5 {
                    
                    return Self.calculateAverage(lastInGroup, "Current Comp Sim", true)
                } else {
                    
                    return Self.calculateAverage((groupLastTwoSolves.first!.solves!.array as! [Solves]), "Current Comp Sim", true)
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
                        
                        
                        let currentAvg = Self.calculateAverage((solvegroup as AnyObject).solves!.array as! [Solves], "Best Comp Sim", true)
                        
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
    
    func getAveragePhases() -> [Double]? {
        if let multiphaseSession = currentSession as? MultiphaseSession {
            let times = (solvesNoDNFs as! [MultiphaseSolve]).map({ $0.phases! })
            
            
            var summedPhases = [Double](repeating: 0, count: Int(phaseCount))
                        
            
            for phase in times {
                var paddedPhase = phase
                paddedPhase.insert(0, at: 0)
                
                let mappedPhase = paddedPhase.chunked().map { $0[1] - $0[0] }
                
               
                for i in 0..<Int(phaseCount) {
                    summedPhases[i] += mappedPhase[i]
                }
            }
           
            
            return summedPhases.map({ $0 / Double(solvesNoDNFs.count) })
        } else {
            return nil
        }
    }
    
    
    func getWpaBpa() -> (Double?, Double?) {
        if let compsimSession = currentSession as? CompSimSession {
            let solveGroups = (compsimSession.solvegroups!.array as! [CompSimSolveGroup])
            
            if solveGroups.count == 0 { return (nil, nil) } else {
                let lastGroupSolves = (solveGroups.last!.solves!.array as! [Solves])
                if lastGroupSolves.count == 4 {
                    let sortedGroup = lastGroupSolves.sorted(by: Self.sortWithDNFsLast)
                    
                    print(sortedGroup.map{$0.time})
                    
                    let bpa = (sortedGroup.dropFirst().reduce(0) {$0 + timeWithPlusTwoForSolve($1)}) / 3.00
                    
                    let wpa = sortedGroup.contains(where: {$0.penalty == PenTypes.dnf.rawValue}) ? -1 : (sortedGroup.dropLast().reduce(0) {$0 + timeWithPlusTwoForSolve($1)}) / 3.00
                    
                    return (bpa, wpa)
                }
            }
        } else { return (nil, nil) }
        
        return (nil, nil)
    }
    
    func getTimeNeededForTarget() -> Double? {
        if let compsimSession = currentSession as? CompSimSession {
            let solveGroups = (compsimSession.solvegroups!.array as! [CompSimSolveGroup])
            
            if solveGroups.count == 0 { return nil } else {
                let lastGroupSolves = (solveGroups.last!.solves!.array as! [Solves])
                if lastGroupSolves.count == 4 {
                    let sortedGroup = lastGroupSolves.sorted(by: Self.sortWithDNFsLast)
                    
                    let timeNeededForTarget = (compsimSession as CompSimSession).target * 3 - (sortedGroup.dropFirst().dropLast().reduce(0) {$0 + timeWithPlusTwoForSolve($1)})
                    
                    if timeNeededForTarget < sortedGroup.last!.time {
                        return -1 // not possible
                    } else if timeNeededForTarget > sortedGroup.first!.time && !sortedGroup.contains(where: {$0.penalty == PenTypes.dnf.rawValue}) {
                        return -2 // guaranteed
                    } else {
                        return timeNeededForTarget // standard return
                    }
                }
            }
        } else { return nil }
        
        return nil
    }
}


struct CalculatedAverage: Identifiable, Comparable/*, Equatable, Comparable*/ {
    let id = UUID()
    var name: String

    //    let discardedIndexes: [Int]
    let average: Double?
    let accountedSolves: [Solves]?
    let totalPen: PenTypes
    let trimmedSolves: [Solves]?
    
    static func < (lhs: CalculatedAverage, rhs: CalculatedAverage) -> Bool {
        // TODO merge with that one sort function
        if lhs.totalPen == .dnf && rhs.totalPen != .dnf {
            return true
        } else if lhs.totalPen != .dnf && rhs.totalPen == .dnf {
            return false
        } else {
            if let lhsa = lhs.average {
                if let rhsa = rhs.average {
                    return timeWithPlusTwo(lhsa, pen: lhs.totalPen) < timeWithPlusTwo(rhsa, pen: rhs.totalPen)
                } else {
                    return true
                }
            } else {
                return false
            }
        }
    }
}

@available(*, deprecated, message: "Please use solve.timeIncPen instead")
func timeWithPlusTwoForSolve(_ solve: Solves) -> Double {
    return solve.time + (solve.penalty == PenTypes.plustwo.rawValue ? 2 : 0)
}

// TODO put this in Solve extensions
func timeWithPlusTwo(_ time: Double, pen: PenTypes) -> Double {
    return time + (pen == PenTypes.plustwo ? 2 : 0)
}

extension Array {
    func chunked() -> [[Element]] {
        return stride(from: 0, to: count-1, by: 1).map {
            Array(self[$0 ..< Swift.min($0 + 2, count)])
        }
    }
}
