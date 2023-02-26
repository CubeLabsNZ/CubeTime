import Foundation
import CoreData
import SwiftUI

import AVKit
import AVFoundation

enum stopWatchMode {
    case running
    case stopped
    case inspecting
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
        #warning("TODO:  merge with that one sort function")
        if lhs.totalPen == .dnf && rhs.totalPen != .dnf {
            return true
        } else if lhs.totalPen != .dnf && rhs.totalPen == .dnf {
            return false
        } else {
            if let lhsa = lhs.average {
                if let rhsa = rhs.average {
//                    return timeWithPlusTwo(lhsa, pen: lhs.totalPen) < timeWithPlusTwo(rhsa, pen: rhs.totalPen)
                    return lhsa < rhsa
                } else {
                    return true
                }
            } else {
                return false
            }
        }
    }
}

func setupAudioSession() {
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setCategory(AVAudioSession.Category.playback)
    } catch let error as NSError {
        print(error.description)
    }
}

// MARK: --
// MARK: SWM
class StopWatchManager: ObservableObject {
    let managedObjectContext: NSManagedObjectContext
    
    // MARK: get user defaults
    var hapticType: Int = UserDefaults.standard.integer(forKey: gsKeys.hapType.rawValue)
    var hapticEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.hapBool.rawValue)
    var inspectionEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.inspection.rawValue)
    var inspectionAlert: Bool = UserDefaults.standard.bool(forKey: gsKeys.inspectionAlert.rawValue)
    var inspectionAlertType: Int = UserDefaults.standard.integer(forKey: gsKeys.inspectionAlertType.rawValue)
    var timeDP: Int = UserDefaults.standard.integer(forKey: gsKeys.timeDpWhenRunning.rawValue)
    var insCountDown: Bool = UserDefaults.standard.bool(forKey: gsKeys.inspectionCountsDown.rawValue)
    var showPrevTime: Bool = UserDefaults.standard.bool(forKey: gsKeys.showPrevTime.rawValue)
    var fontWeight: Double = UserDefaults.standard.double(forKey: asKeys.fontWeight.rawValue)
    var fontCasual: Double = UserDefaults.standard.double(forKey: asKeys.fontCasual.rawValue)
    var fontCursive: Bool = UserDefaults.standard.bool(forKey: asKeys.fontCursive.rawValue)
    var scrambleSize: Int = UserDefaults.standard.integer(forKey: asKeys.scrambleSize.rawValue)

    
    
    // MARK: published variables
    @Published var timerColour: Color = Color.Timer.normal
    
    @Published var currentSession: Sessions! {
        didSet {
            NSLog("DIDSET currentsession")
            self.targetStr = filteredStrFromTime((currentSession as? CompSimSession)?.target)
            self.phaseCount = Int((currentSession as? MultiphaseSession)?.phase_count ?? 0)
            
            rescramble()
            tryUpdateCurrentSolveth()
            statsGetFromCache()
            currentSession.last_used = Date()
            self.playgroundScrambleType = currentSession.scramble_type
        }
    }
    
    @Published var scrambleStr: String? = nil
    @Published var scrambleSVG: String? = nil
    
    @Published var secondsStr = ""
    @Published var inspectionSecs = 0
    
    @Published var mode: stopWatchMode = .stopped
    
    @Published var showDeleteSolveConfirmation = false
    @Published var showPenOptions = false
    
    @Published var currentSolveth: Int?
    
    @Published var solveItem: Solves!
    
    
    @Published var ctFontScramble: Font!
    @Published var ctFontDescBold: CTFontDescriptor!
    @Published var ctFontDesc: CTFontDescriptor!
    
    var feedbackStyle: UIImpactFeedbackGenerator?
    var secondsElapsed = 0.0
    var penType: PenTypes = .none

    
    
    // MARK: scrambler
    var scrambleWorkItem: DispatchWorkItem?
    
    
    // MARK: private
    var prevScrambleStr: String! = nil
    let plusTwoTime: Int = 15
    let dnfTime: Int = 17
    
    
    // MARK: timer
    private var timer: Timer?
    private var timerStartTime: Date?
    
    private var justInspected = false
    
    var prevDownStoppedTimer = false
    var canGesture: Bool = true
    
    
    // MARK: multiphase
    private var currentMPCount: Int = 1
    var phaseTimes: [Double] = []
    
    
    
    
    #warning("TODO: remove")
    var nilSolve: Bool = true
    
    
    
    
    
    // MARK: stats
    @Published var playgroundScrambleType: Int32 {
        didSet {
            if (playgroundScrambleType != -1){
                NSLog("playgroundScrambleType didset to \(playgroundScrambleType)")
                currentSession.scramble_type = playgroundScrambleType
                try! managedObjectContext.save()
                rescramble()
            }
        }
    }
    @Published var targetStr: String!
    @Published var phaseCount: Int!
    
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
    var solves: [Solves]!
    // On stop: just append to list
    @Published var solvesByDate: [Solves]!
    // Maybe use trickery to get object, maybe delete this array
    @Published var solvesNoDNFs: [Solves]!
    // On stop: just append if not dnf, remove if dnf
    @Published var solvesNoDNFsbyDate: [Solves]!
    
    
    // Couple time list functions
    var timeListSolves: [Solves]!
    @Published var timeListSolvesFiltered: [Solves]!
    @Published var timeListFilter = "" {
        didSet {
            filterTimeList()
        }
    }
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
    
    #warning("TODO:  fix this god awful hack")
    @Published var stateID = UUID()
    
    
    // MARK: inspection alert audio
    
    
    
    private let systemSoundID: SystemSoundID = 1057
    private let inspectionAlert_8: AVAudioPlayer!
    private let inspectionAlert_12: AVAudioPlayer!
    
    
    
    let isSmallDevice: Bool
    
    
    func addSessionQuickActions() {
        NSLog("adding actions")
        let req = NSFetchRequest<Sessions>(entityName: "Sessions")
        req.predicate = NSPredicate(format: "last_used != nil")
        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \Sessions.last_used, ascending: false),
        ]
        req.fetchLimit = 3
        
        let lastUsed = try! managedObjectContext.fetch(req)
        
        
        UIApplication.shared.shortcutItems = lastUsed.map { session in
            return UIApplicationShortcutItem (
                type: "com.cubetime.cubetime.session",
                localizedTitle: session.name ?? "Unknown Session",
                localizedSubtitle: session.shortcutName,
                icon: UIApplicationShortcutIcon(
                    systemImageName: iconNamesForType[SessionTypes(rawValue: session.session_type)!]!
                ),
                userInfo: ["id": session.objectID.uriRepresentation().absoluteString as NSString]
            )
        }
    }
    
    
    func loadSessionsHistory() {
        let userDefaults = UserDefaults.standard
        let moc = self.managedObjectContext
        
        let lastUsedSessionURI = userDefaults.url(forKey: "last_used_session")
        
        if let lastUsedSessionURI = lastUsedSessionURI {
            let objID = moc.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: lastUsedSessionURI)!
            self.currentSession = try! moc.existingObject(with: objID) as! Sessions
            userDefaults.removeObject(forKey: "last_used_session")
        } else {
            let req = NSFetchRequest<Sessions>(entityName: "Sessions")
            req.sortDescriptors = [
                NSSortDescriptor(keyPath: \Sessions.last_used, ascending: false),
            ]
            req.fetchLimit = 1
            
            let lastUsed = try! managedObjectContext.fetch(req)
                        
            if lastUsed.count > 0 {
                currentSession = lastUsed[0]
            } else {
                let sessionToSave = Sessions(context: moc) // Must use this variable else didset will fire prematurely
                sessionToSave.scramble_type = 1
                sessionToSave.session_type = SessionTypes.playground.rawValue
                sessionToSave.name = "Default Session"
                currentSession = sessionToSave
                try! moc.save()
            }
        }
        assert(currentSession != nil)
    }
    
    
    init (currentSession: Sessions?, managedObjectContext: NSManagedObjectContext) {
        print("initialising audio...")
        setupAudioSession()
        self.inspectionAlert_8 = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "8sec-audio", ofType: "wav")!))
        self.inspectionAlert_12 = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "12sec-audio", ofType: "wav")!))
        
        
//        self.currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        
        self.isSmallDevice = smallDeviceNames.contains(getModelName())
        
        secondsStr = formatSolveTime(secs: 0)
        
        self.playgroundScrambleType = -1 // Get the compiler to shut up about not initialized, cannot be optional for picker
        
        if let currentSession = currentSession {
            self.currentSession = currentSession
        } else {
            loadSessionsHistory()
        }
        
        statsGetFromCache()
        calculateFeedbackStyle()
        self.rescramble()
        
        updateFont()
        
        tryUpdateCurrentSolveth()
        
        
        
        
        print("swm initialised")
    }
    
    
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
            
            if inspectionSecs == self.plusTwoTime {
                penType = .plustwo
            } else if inspectionSecs == self.dnfTime {
                penType = .dnf
            }
            
            if inspectionAlert && (inspectionSecs == 8 || inspectionSecs == 12) {
                if inspectionAlertType == 1 {
                    AudioServicesPlayAlertSound(systemSoundID)
                } else {
                    if inspectionSecs == 8 {
                        inspectionAlert_8.play()
                    } else {
                        inspectionAlert_12.play()
                    }
                }
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
    
    
    func touchDown() {
        #if DEBUG
        NSLog("touch down")
        #endif
        if mode != .stopped || scrambleStr != nil || prevDownStoppedTimer {
            timerColour = Color.Timer.heldDown
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
            timerColour = Color.Timer.normal
            
            if inspectionEnabled && mode == .stopped && !prevDownStoppedTimer {
                startInspection()
                justInspected = true
            }
        } else if prevDownStoppedTimer && scrambleStr == nil {
            timerColour = Color.Timer.loading
        }
        
        
        if showPenOptions {
            withAnimation(Animation.customSlowSpring) {
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
            
            timerColour = Color.Timer.canStart
            feedbackStyle?.impactOccurred()
        }
    }
    
    func longPressEnd() {
        #if DEBUG
        NSLog("long press end")
        #endif
        if mode != .stopped || scrambleStr != nil {
            timerColour = Color.Timer.normal
        } else if prevDownStoppedTimer && scrambleStr == nil {
            timerColour = Color.Timer.loading
        }
        
        withAnimation(Animation.customSlowSpring) {
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
    
    
    // multiphase
    func lap() {
        phaseTimes.append(-timerStartTime!.timeIntervalSinceNow)
    }
    
    // compsim
    func tryUpdateCurrentSolveth() {
        if let currentSession = currentSession as? CompSimSession {
            if currentSession.solvegroups!.count > 0 {
                currentSolveth = (currentSession.solvegroups!.lastObject! as! CompSimSolveGroup).solves!.count
            } else {
                currentSolveth = 0
            }
        }
    }
}
