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
class StopwatchManager: ObservableObject {
    let managedObjectContext: NSManagedObjectContext
    
    // MARK: get user defaults
    var showPrevTime: Bool = UserDefaults.standard.bool(forKey: gsKeys.showPrevTime.rawValue)
    var fontWeight: Double = UserDefaults.standard.double(forKey: asKeys.fontWeight.rawValue)
    var fontCasual: Double = UserDefaults.standard.double(forKey: asKeys.fontCasual.rawValue)
    var fontCursive: Bool = UserDefaults.standard.bool(forKey: asKeys.fontCursive.rawValue)
    var scrambleSize: Int = UserDefaults.standard.integer(forKey: asKeys.scrambleSize.rawValue)

    
    
    // MARK: published variables
    @Published var currentSession: Sessions! {
        didSet {
            NSLog("BEGIN DIDSET currentsession, now \(currentSession)")
            self.targetStr = filteredStrFromTime((currentSession as? CompSimSession)?.target)
            self.phaseCount = Int((currentSession as? MultiphaseSession)?.phase_count ?? 0)
            
            scrambleController?.scrambleType = currentSession.scramble_type
            tryUpdateCurrentSolveth()
            statsGetFromCache()
            currentSession.last_used = Date()
            try! managedObjectContext.save()
            self.playgroundScrambleType = currentSession.scramble_type
            if let currentSession = currentSession as? MultiphaseSession {
                timerController.phaseCount = Int(currentSession.phase_count)
            } else {
                timerController.phaseCount = nil
            }
            NSLog("END DIDSET currentsession, now \(currentSession)")
        }
    }
    
    @Published var showDeleteSolveConfirmation = false
    @Published var showPenOptions = false
    
    @Published var currentSolveth: Int?
    
    @Published var solveItem: Solves!
    
    
    @Published var ctFontScramble: Font!
    @Published var ctFontDescBold: CTFontDescriptor!
    @Published var ctFontDesc: CTFontDescriptor!
    
    var penType: PenTypes = .none

    
    #warning("TODO: remove")
    var nilSolve: Bool = true
    
    
    
    
    
    // MARK: stats
    @Published var playgroundScrambleType: Int32 {
        didSet {
            if (playgroundScrambleType != -1){
                NSLog("playgroundScrambleType didset to \(playgroundScrambleType)")
                currentSession.scramble_type = playgroundScrambleType
                try! managedObjectContext.save()
                scrambleController?.scrambleType = playgroundScrambleType
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
    
    #warning("TODO:  fix this god awful hack")
    @Published var stateID = UUID()
    
    
    // MARK: inspection alert audio
    
    
    
    
    
    
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
    
    var scrambleController: ScrambleController! = nil
    var timerController: TimerContoller! = nil; #warning("figure out way to not make it ! optional")
    
    init (currentSession: Sessions?, managedObjectContext: NSManagedObjectContext) {
        print("initialising audio...")
        setupAudioSession()
        
        
        
        print("im here:")
        Self.doSomething()
        
        
//        self.currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        
        self.isSmallDevice = smallDeviceNames.contains(getModelName())
        
        
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
                        currentSession.solvegroups = NSOrderedSet()
                    }
                                        
                    if currentSession.solvegroups!.count == 0 || self.currentSolveth == 5 {
                        let solvegroup = CompSimSolveGroup(context: managedObjectContext)
                        solvegroup.session = currentSession
                        
                    }
                    
                    (self.solveItem as! CompSimSolve).solvegroup = (currentSession.solvegroups!.lastObject! as! CompSimSolveGroup)
                    self.currentSolveth = (currentSession.solvegroups!.lastObject! as? CompSimSolveGroup)!.solves!.count

                } else {
                    if let _ = self.currentSession as? MultiphaseSession {
                        self.solveItem = MultiphaseSolve(context: managedObjectContext)
                        
                        (self.solveItem as! MultiphaseSolve).phases = phaseTimes
                    } else {
                        self.solveItem = Solves(context: managedObjectContext)
                    }
                }
                
                
                self.solveItem.date = Date()
                self.solveItem.penalty = self.penType.rawValue
                // .puzzle_id
                self.solveItem.session = self.currentSession
                // Use the current scramble if stopped from manual input
                self.solveItem.scramble = time == nil ? self.scrambleController.prevScrambleStr : self.scrambleController.scrambleStr
                self.solveItem.scramble_type = self.currentSession.scramble_type
                self.solveItem.scramble_subtype = 0
                self.solveItem.time = secondsElapsed
                try! managedObjectContext.save()
                
                // Rescramble if from manual input
                if time != nil {
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
                self.scrambleController.rescramble()
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
                    scrambleController.rescramble()
                default: break
                }
            }
        )
        
        if let currentSession = currentSession {
            self.currentSession = currentSession
        } else {
            loadSessionsHistory()
        }
        
        self.scrambleController = ScrambleController(scrambleType: self.currentSession!.scramble_type, onSetScrambleStr: { newScr in
            self.timerController.disabled = newScr == nil
        })
        
        statsGetFromCache()
        scrambleController.rescramble()
        
        updateFont()
        
        tryUpdateCurrentSolveth()
        
        print("swm initialised")
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
