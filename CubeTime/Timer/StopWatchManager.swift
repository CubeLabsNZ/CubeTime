import Foundation
import CoreData
import SwiftUI

let plustwotime = 15
let dnftime = 17


enum stopWatchMode {
    case running
    case stopped
    case inspecting
}

class StopWatchManager: ObservableObject {
    private var currentSession: Sessions
    let managedObjectContext: NSManagedObjectContext
    
    
    private let hapticType: Int = UserDefaults.standard.integer(forKey: gsKeys.hapType.rawValue)
    private let hapticEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.hapBool.rawValue)
    private let inspectionEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.inspection.rawValue)
    private let timeDP: Int = UserDefaults.standard.integer(forKey: gsKeys.timeDpWhenRunning.rawValue)

    
    
    let feedbackStyle: UIImpactFeedbackGenerator?
    
    
    let scrambler = CHTScrambler.init()

    
    @Published var scrambleStr: String? = nil
    var nextScrambleStr: String? = nil
    
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
        NSLog("Initializing a stopwatchamanager")
        self.currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        self.feedbackStyle = hapticEnabled ? UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.init(rawValue: hapticType)!) : nil
        scrambler.initSq1()
        secondsStr = formatSolveTime(secs: 0)
        DispatchQueue.main.async {
            self.rescramble()
        }
        
        if let currentSession = currentSession as? CompSimSession {
            if currentSession.solvegroups!.count > 0 {
                currentSolveth = (currentSession.solvegroups!.lastObject! as? CompSimSolveGroup)!.solves!.count
            } else {
                currentSolveth = 0
            }
        }
    }
    
    
    
    var timer: Timer?
    
    private var timerStartTime: Date?
    
    
    var prevDownStoppedTimer = false
    
    var currentMPCount: Int = 1
    
    var phaseTimes: [Double] = []
    
    
    func startInspection() {
        timer?.invalidate()
        secondsStr = "0"
        inspectionSecs = 0
        mode = .inspecting
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            inspectionSecs += 1
            self.secondsStr = String(inspectionSecs)
            if inspectionSecs == plustwotime {
                penType = .plustwo
            } else if inspectionSecs == dnftime {
                penType = .dnf
            }
        }
    }
    
    func start() {
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
    
    
    func stop() {
        timer?.invalidate()
        self.secondsElapsed = -timerStartTime!.timeIntervalSinceNow
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
            } else {
                solveItem = Solves(context: managedObjectContext)
            }
        }
        
        
        solveItem.date = Date()
        solveItem.penalty = penType.rawValue
        // .puzzle_id
        solveItem.session = currentSession
        solveItem.scramble = scrambleStr
        solveItem.scramble_type = currentSession.scramble_type
        solveItem.scramble_subtype = 0
        solveItem.time = self.secondsElapsed
        try! managedObjectContext.save()
    }
    
    
    
    
    
    
    
    
    
    func lap() {
        phaseTimes.append(-timerStartTime!.timeIntervalSinceNow)
    }
    
    
    func touchDown() {
        NSLog("touch down")

        timerColour = TimerTextColours.timerHeldDownColour
        
        if mode == .running {
            
            print(currentMPCount)
            print(currentSession.session_type)
            
            if let multiphaseSession = currentSession as? MultiphaseSession {
                
                print(currentMPCount)
                
                if multiphaseSession.phase_count != currentMPCount {
                    currentMPCount += 1
                    lap()
                } else {
                    
                    print(phaseTimes)
                    lap()
                    prevDownStoppedTimer = true
                    stop()
                    DispatchQueue.main.async {
                        self.rescramble()
                    }
                }
            } else {
                prevDownStoppedTimer = true
                stop()
                DispatchQueue.main.async {
                    self.rescramble()
                }
            }
        }
    }
    
    
    func touchUp() {
        NSLog("touch up")
        
        
        timerColour = TimerTextColours.timerDefaultColour
        if !prevDownStoppedTimer {
            if showPenOptions {
                withAnimation {
                    showPenOptions = false
                }
            }
            if mode == .stopped && inspectionEnabled {
                startInspection()
            }
        }
        prevDownStoppedTimer = false
    }
    
    
    func longPressStart() {
        NSLog("long press start")
        
        if inspectionEnabled ? mode == .inspecting : mode == .stopped && !prevDownStoppedTimer {
            timerColour = TimerTextColours.timerCanStartColour
            feedbackStyle?.impactOccurred()
        }
    }
    
    func longPressEnd() {
        NSLog("long press end")
        
        // TODO maybe hide pen options
        timerColour = TimerTextColours.timerDefaultColour
        withAnimation {
            showPenOptions = false
        }
        if !prevDownStoppedTimer {
            if inspectionEnabled ? mode == .inspecting : mode == .stopped {
                start()
            } else if inspectionEnabled && mode == .stopped {
                startInspection()
            }
        }
        prevDownStoppedTimer = false
    }
    
    func changedPen() {
        withAnimation {
            secondsStr = formatSolveTime(secs: secondsElapsed, penType: PenTypes(rawValue: solveItem.penalty)!)
        }
    }
    
    func safeGetScramble() -> String {
        guard let scr = CHTScramble.getNewScramble(by: scrambler, type: puzzle_types[Int(currentSession.scramble_type)].scrID, subType: 0).scramble else {
            return "Failed to load scramble."
        }
        return scr
    }
    
    func rescramble() {
        if nextScrambleStr == nil { nextScrambleStr = safeGetScramble() }
        scrambleStr = nextScrambleStr
        nextScrambleStr = safeGetScramble()
    }
    
    func changeCurrentSession(_ session: Sessions) {
        self.currentSession = session
        DispatchQueue.main.async {
            self.nextScrambleStr = nil
            self.rescramble()
        }
    }
    
    
    
    func displayPenOptions() {
        if solveItem != nil {
            withAnimation {
                showPenOptions = true
            }
        }
    }
    
    func askToDelete() {
        if solveItem != nil {
            // todo
            showDeleteSolveConfirmation = true
        }
    }
}

