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
    
    
    var hapticType: Int = UserDefaults.standard.integer(forKey: gsKeys.hapType.rawValue)
    var hapticEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.hapBool.rawValue)
    var inspectionEnabled: Bool = UserDefaults.standard.bool(forKey: gsKeys.inspection.rawValue)
    var timeDP: Int = UserDefaults.standard.integer(forKey: gsKeys.timeDpWhenRunning.rawValue)

    
    var feedbackStyle: UIImpactFeedbackGenerator?
    
    
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
        self.currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        secondsStr = formatSolveTime(secs: 0)
        calculateFeedbackStyle()
        scrambler.initSq1()
        self.rescramble()
        
        tryUpdateCurrentSolveth()
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
    
    
    func startInspection() {
        timer?.invalidate()
        penType = .none // reset penType from last solve
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
    
    
    func stop(_ time: Double?) {
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
        timerColour = TimerTextColours.timerHeldDownColour
        
        if mode == .running {
            
            justInspected = false
            
            if let multiphaseSession = currentSession as? MultiphaseSession {
                
                if multiphaseSession.phase_count != currentMPCount {
                    canGesture = false
                    
                    currentMPCount += 1
                    lap()
                } else {
                    
                    canGesture = true
                    
                    
                    lap()
                    prevDownStoppedTimer = true
                    justInspected = false
                    stop(nil)
                    self.rescramble()
                }
            } else {
                
                canGesture = true
                
                prevDownStoppedTimer = true
                justInspected = false
                stop(nil)
                self.rescramble()
            }
        }
    }
    
    
    func touchUp() {
        timerColour = TimerTextColours.timerDefaultColour
        
        
        if !prevDownStoppedTimer && mode == .stopped && inspectionEnabled {
            startInspection()
        }
        
        
        if showPenOptions {
            withAnimation {
                showPenOptions = false
            }
        }
            
            
        
        prevDownStoppedTimer = false
        
        if inspectionEnabled && mode == .stopped && !justInspected && prevDownStoppedTimer {
            startInspection()
            justInspected = true
        }
}
    
    
    func longPressStart() {
        if inspectionEnabled ? mode == .inspecting : mode == .stopped && !prevDownStoppedTimer {
            timerColour = TimerTextColours.timerCanStartColour
            feedbackStyle?.impactOccurred()
        }
    }
    
    func longPressEnd() {
        timerColour = TimerTextColours.timerDefaultColour
        withAnimation {
            showPenOptions = false
        }
        if !prevDownStoppedTimer {
            if inspectionEnabled ? mode == .inspecting : mode == .stopped {
                start()
            }
        }
        
        
        if inspectionEnabled && mode == .stopped && !justInspected && !prevDownStoppedTimer {
            startInspection()
            justInspected = true
        }
        prevDownStoppedTimer = false
    }
    
    
    
    
    
    /// OTHER FUNCS
    
    
    
    
    
    func changedPen() {
        if PenTypes(rawValue: solveItem.penalty)! == .plustwo {
            withAnimation {
                secondsStr = formatSolveTime(secs: secondsElapsed, penType: PenTypes(rawValue: solveItem.penalty)!)
            }
        } else {
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
        if nextScrambleStr == nil {
            DispatchQueue.global(qos: .userInitiated).sync {
                self.nextScrambleStr = self.safeGetScramble()
            }
        }
        scrambleStr = nextScrambleStr
        DispatchQueue.global(qos: .userInitiated).async {
            self.nextScrambleStr = self.safeGetScramble()
        }
    }
    
    func changeCurrentSession(_ session: Sessions) {
        // TODO do not rescramble when setting to same scramble eg 3blnd -> 3oh
        currentSession = session
        tryUpdateCurrentSolveth()
        nextScrambleStr = nil
        rescramble()
    }
    
    
    
    func displayPenOptions() {
        
        timerColour = TimerTextColours.timerDefaultColour
        prevDownStoppedTimer = false
        
        if solveItem != nil {
            withAnimation {
                showPenOptions = true
            }
        }
    }
    
    func askToDelete() {
        timerColour = TimerTextColours.timerDefaultColour
        prevDownStoppedTimer = false

        if solveItem != nil {
            // todo
            showDeleteSolveConfirmation = true
        }
    }
}

