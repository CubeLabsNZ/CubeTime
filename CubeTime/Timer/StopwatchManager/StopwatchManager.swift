import Foundation
import CoreData
import SwiftUI

import AVKit
import AVFoundation

enum TimerState {
    case running
    case stopped
    case inspecting
}


enum TimeNeededForTarget {
    case notPossible, guaranteed
    case value(Double)
}

// MARK: --
class StopwatchManager: ObservableObject {
    let managedObjectContext: NSManagedObjectContext
    
    @Published var isScrambleLocked: Bool = false
    
    // MARK: published variables
    @Published var currentSession: Session! {
        didSet {
            currentSession.lastUsed = Date()
            try! managedObjectContext.save()
            
            self.isScrambleLocked = false
            
            self.targetStr = filteredStrFromTime((currentSession as? CompSimSession)?.target)
            self.phaseCount = Int((currentSession as? MultiphaseSession)?.phaseCount ?? 0)
            
            scrambleController?.scrambleType = currentSession.scrambleType
            
            updateStatsForSession()
            tryUpdateCurrentSolveth()
            statsGetFromCache()
            self.playgroundScrambleType = currentSession.scrambleType
            if let currentSession = currentSession as? MultiphaseSession {
                timerController.phaseCount = Int(currentSession.phaseCount)
            } else {
                timerController.phaseCount = nil
            }
            if currentSession.sessionType == SessionType.playground.rawValue {
                updateSessionsCanMoveToPlayground()
            } else {
                updateSessionsCanMoveTo()
            }
        }
    }
    
    func updateStatsForSession() {
        self.stats = [
            "currentAo5": StatCurrentAverage(of: 5, stopwatchManager: self),
            "currentAo12": StatCurrentAverage(of: 12, stopwatchManager: self),
            "currentAo100": StatCurrentAverage(of: 100, stopwatchManager: self),
            "mean": StatMean(stopwatchManager: self),
        ]
    }
    
    func updateSessionsCanMoveTo() {
        var phaseCount: Int16 = -1
        if let multiphaseSession = currentSession as? MultiphaseSession {
            phaseCount = multiphaseSession.phaseCount
        }
        
        let req = NSFetchRequest<Session>(entityName: "Session")
        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \Session.pinned, ascending: false),
            NSSortDescriptor(keyPath: \Session.name, ascending: true)
        ]
        req.predicate = NSPredicate(format: """
            sessionType != \(SessionType.compsim.rawValue)
            AND
            (
                sessionType == \(SessionType.playground.rawValue) OR
                scrambleType == %i
            )
            AND
            (
                sessionType != \(SessionType.multiphase.rawValue) OR
                phaseCount == %i
            )
            AND
            self != %@
        """, currentSession.scrambleType, phaseCount, currentSession)
        
        sessionsCanMoveTo = try! managedObjectContext.fetch(req)
    }
    
    func updateSessionsCanMoveToPlayground() {
        let req = NSFetchRequest<Session>(entityName: "Session")
        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \Session.pinned, ascending: false),
            NSSortDescriptor(keyPath: \Session.name, ascending: true)
        ]
        req.predicate = NSPredicate(format: """
            sessionType != \(SessionType.compsim.rawValue) AND
            self != %@
        """, currentSession)
        
        let results = try! managedObjectContext.fetch(req)
        sessionsCanMoveToPlayground = Array(repeating: [], count: puzzleTypes.count)
        
        for result in results {
            if result.sessionType == SessionType.playground.rawValue {
                for i in sessionsCanMoveToPlayground.indices {
                    sessionsCanMoveToPlayground[i].append(result)
                }
            } else {
                sessionsCanMoveToPlayground[Int(result.scrambleType)].append(result)
            }
        }
        
        req.predicate = NSPredicate(format: """
            sessionType == \(SessionType.playground.rawValue) AND
            self != %@
        """, currentSession)
        
        allPlaygroundSessions = try! managedObjectContext.fetch(req)
    }
    
    @Published var sessionsCanMoveTo: [Session]!
    @Published var sessionsCanMoveToPlayground: [[Session]]!
    @Published var allPlaygroundSessions: [Session]!
    
    @Published var zenMode = false {
        didSet {
            updateHideStatusBar()
        }
    }
    @Published var hideUI = false
    

    @Published var showDeleteSolveConfirmation = false
    @Published var showUnlockScrambleConfirmation = false
    @Published var showPenOptions = false
    
    @Published var currentSolveth: Int?
    
    @Published var solveItem: Solve!
    
    @Published var currentPadFloatingStage: Int = 1
    
    var penType: Penalty = .none

    
    
    
    // MARK: stats
    @Published var playgroundScrambleType: Int32 {
        didSet {
            if (playgroundScrambleType != -1){
                currentSession.scrambleType = playgroundScrambleType
                try! managedObjectContext.save()
                scrambleController?.scrambleType = playgroundScrambleType
            }
        }
    }
    @Published var targetStr: String!
    @Published var phaseCount: Int!
    
    // STATS
    
    // Stats used on timer
    
    
    @Published var stats: [String: Stat] = [:]
    
    #warning("todo: merge average and calculatedaverage, and fix the functions")
    @Published var bpa: Average?
    @Published var wpa: Average?
    
    @Published var timeNeededForTarget: TimeNeededForTarget?
    
    // Stats not on timer
    @Published var bestAo5: CalculatedAverage?
    @Published var bestAo12: CalculatedAverage?
    @Published var bestAo100: CalculatedAverage?
    
    
    // other block calculations
    @Published var bestSingle: Solve?
    
    
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
    var solves: [Solve]!
    // On stop: just append to list
    @Published var solvesByDate: [Solve]!
    // Maybe use trickery to get object, maybe delete this array
    @Published var solvesNoDNFs: [Solve]!
    // On stop: just append if not dnf, remove if dnf
    @Published var solvesNoDNFsbyDate: [Solve]!
    
    
    
    
    @Published var compsimSolveGroups: [CompSimSolveGroup]!
    
    
    // Couple time list functions
    #warning("this spams purple errors ... \"publishing view updates something somethin\"")
    @Published var timeListSolvesSelected = Set<(Solve)>()
    var timeListSolves: [Solve]!
    @Published var timeListSolvesFiltered: [Solve]!
    @Published var timeListFilter = "" {
        didSet {
            filterTimeList()
        }
    }
    @Published var hasPenaltyOnly = false {
        didSet {
            filterTimeList()
        }
    }
    @Published var hasCommentOnly = false {
        didSet {
            filterTimeList()
        }
    }
    @Published var scrambleTypeFilter = -1 {
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
    
    var timeListReloadSolve: ((Solve) -> ())?
    var timeListSelectAll: (() -> ())?
    
    
    func updateHideStatusBar() {
        self.hideUI = timerController.mode == .inspecting || timerController.mode == .running || self.zenMode
    }
    
    func addSessionQuickActions() {
        #if DEBUG
        NSLog("Adding quick actions")
        #endif
        
        let req = NSFetchRequest<Session>(entityName: "Session")
        req.predicate = NSPredicate(format: "lastUsed != nil")
        req.sortDescriptors = [
            NSSortDescriptor(keyPath: \Session.lastUsed, ascending: false),
        ]
        req.fetchLimit = 3
        
        let lastUsed = try! managedObjectContext.fetch(req)
        
        
        UIApplication.shared.shortcutItems = lastUsed.map { session in
            return UIApplicationShortcutItem (
                type: "com.cubetime.cubetime.session",
                localizedTitle: session.name ?? "Unknown Session",
                localizedSubtitle: session.shortcutName,
                icon: UIApplicationShortcutIcon(
                    systemImageName: iconNamesForType[SessionType(rawValue: session.sessionType)!]!
                ),
                userInfo: ["id": session.objectID.uriRepresentation().absoluteString as NSString]
            )
        }
    }
    
    
    func loadSessionsHistory() {
        let userDefaults = UserDefaults.standard
        let moc = self.managedObjectContext
        
        let lastUsedSessionURI = userDefaults.url(forKey: "lastUsed_session")
        
        if let lastUsedSessionURI = lastUsedSessionURI {
            let objID = moc.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: lastUsedSessionURI)!
            self.currentSession = try! moc.existingObject(with: objID) as! Session
            userDefaults.removeObject(forKey: "lastUsed_session")
        } else {
            let req = NSFetchRequest<Session>(entityName: "Session")
            req.sortDescriptors = [
                NSSortDescriptor(keyPath: \Session.lastUsed, ascending: false),
            ]
            req.fetchLimit = 1
            
            let lastUsed = try! managedObjectContext.fetch(req)
                        
            if lastUsed.count > 0 {
                currentSession = lastUsed[0]
            } else {
                let sessionToSave = Session(context: moc) // Must use this variable else didset will fire prematurely
                sessionToSave.scrambleType = 1
                sessionToSave.sessionType = SessionType.playground.rawValue
                sessionToSave.name = "Default Session"
                currentSession = sessionToSave
                try! moc.save()
            }
        }
        assert(currentSession != nil)
    }
    
    var scrambleController: ScrambleController!
    var timerController: TimerContoller!
    
    init (currentSession: Session?, managedObjectContext: NSManagedObjectContext) {
        #if DEBUG
        NSLog("Initialising Audio...")
        NSLog("Initialising Stopwatch Manager")
        #endif
        
//        self.currentSession = currentSession
        self.managedObjectContext = managedObjectContext
                
        self.playgroundScrambleType = -1 // Get the compiler to shut up about not initialized, cannot be optional for picker
        
        
        self.timerController = TimerContoller(
            onStartInspection: { self.penType = .none /* reset penType from last solve */ },
            onInspectionSecondsChange: { inspectionSecs in
                if inspectionSecs == inspectionPlusTwoTime {
                    self.penType = .plustwo
                } else if inspectionSecs == inspectionDnfTime {
                    self.penType = .dnf
                }
            },
            onStop: { (time, secondsElapsed, phaseTimes) in
                if let currentSession = self.currentSession as? CompSimSession {
                    self.solveItem = CompSimSolve(context: managedObjectContext)
                    if currentSession.solvegroups == nil {
                        currentSession.solvegroups = NSSet()
                    }
                                        
                    if currentSession.solvegroups!.count == 0 || self.currentSolveth == 5 {
                        let solvegroup = CompSimSolveGroup(context: managedObjectContext)
                        solvegroup.session = currentSession
                        self.updateCSSolveGroups()
                    }
                    
                    (self.solveItem as! CompSimSolve).solvegroup = self.compsimSolveGroups.first
                    self.currentSolveth = self.compsimSolveGroups.first!.solves!.count

                } else {
                    if let _ = self.currentSession as? MultiphaseSession {
                        self.solveItem = MultiphaseSolve(context: managedObjectContext)
                        
                        (self.solveItem as! MultiphaseSolve).phases = phaseTimes
                    } else {
                        self.solveItem = Solve(context: managedObjectContext)
                    }
                }
                
                
                self.solveItem.date = Date()
                self.solveItem.penalty = self.penType.rawValue
                // .puzzle_id
                self.solveItem.session = self.currentSession
                // Use the current scramble if stopped from manual input
                
                self.solveItem.scramble = self.isScrambleLocked ? self.scrambleController.scrambleStr : (time == nil ? self.scrambleController.prevScrambleStr : self.scrambleController.scrambleStr)
                self.solveItem.scrambleType = self.currentSession.scrambleType
                self.solveItem.time = secondsElapsed
                try! managedObjectContext.save()
                
                // Rescramble if from manual input
                if time != nil && !self.isScrambleLocked {
                    self.scrambleController.rescramble()
                }
                
                self.updateStats()
            },
            onTouchUp: {
                if self.showPenOptions {
                    withAnimation(Animation.customSlowSpring) {
                        self.showPenOptions = false
                    }
                }
            },
            preTimerStart: {
                if !self.isScrambleLocked {
                    self.scrambleController.rescramble()
                }
            },
            onGesture: { [self] direction in
                switch direction {
                case .down:
                    timerController.feedbackStyle?.impactOccurred()
                    displayPenOptions()
                    
                case .left:
                    timerController.feedbackStyle?.impactOccurred()
                    askToDelete()
                    
                case .right:
                    timerController.feedbackStyle?.impactOccurred()
                    if (self.isScrambleLocked) {
                        self.showUnlockScrambleConfirmation = true
                    } else {
                        if !timerController.preventStart {
                            scrambleController.rescramble()
                        }
                    }
                    
                case .up:
                    withAnimation(Animation.customSlowSpring) {
                        self.showPenOptions = false
                    }
                    
                default: break
                }
            },
            onModeChange: { newMode in
                self.updateHideStatusBar()
            }
        )
        
        if let currentSession = currentSession {
            self.currentSession = currentSession
        } else {
            loadSessionsHistory()
        }
        
        self.scrambleController = ScrambleController(scrambleType: self.currentSession!.scrambleType, onSetScrambleStr: { newScr in
            self.timerController.preventStart = newScr == nil
        })
        
        statsGetFromCache()
        scrambleController.rescramble()
        
        tryUpdateCurrentSolveth()
        
        #if DEBUG
        NSLog("Stopwatch Manager Initialised")
        #endif
    }
    
    
    // compsim
    func tryUpdateCurrentSolveth() {
        if let currentSession = currentSession as? CompSimSession {
            if currentSession.solvegroups!.count > 0 {
                currentSolveth = compsimSolveGroups.first!.solves!.count
            } else {
                currentSolveth = 0
            }
        }
    }
}
