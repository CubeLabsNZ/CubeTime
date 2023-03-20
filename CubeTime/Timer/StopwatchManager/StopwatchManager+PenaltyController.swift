import Foundation
import SwiftUI

extension StopwatchManager {
    func changePen(to penalty: Penalty) {
        guard let solveItem else { return }
        let old = solveItem.penalty
        solveItem.penalty = penalty.rawValue
        changedPen(Penalty(rawValue: old)!)
    }
    
    func changedPen(_ oldPen: Penalty) {
        if oldPen.rawValue == solveItem.penalty {
            return
        }
        timeListReloadSolve?(solveItem)
        
        if Penalty(rawValue: solveItem.penalty)! == .plustwo {
            timerController.secondsStr = formatSolveTime(secs: timerController.secondsElapsed, penType: Penalty(rawValue: solveItem.penalty)!)
        } else {
            timerController.secondsStr = formatSolveTime(secs: timerController.secondsElapsed, penType: Penalty(rawValue: solveItem.penalty)!)
        }
        
        solves.remove(object: solveItem)
        solves.insert(solveItem, at: solves.insertionIndex(of: solveItem))
        
        
        if solveItem.penalty == Penalty.dnf.rawValue {
            assert(solvesNoDNFsbyDate.popLast() == solveItem)
            solvesNoDNFs.remove(object: solveItem)
        } else if oldPen == Penalty.dnf {
            solvesNoDNFsbyDate.append(solveItem)
            solvesNoDNFs.insert(solveItem, at: solvesNoDNFs.insertionIndex(of: solveItem))
        }
        
        
#warning("TODO: next update use optimised versions")
        
        bestAo5 = getBestAverage(of: 5)
        bestAo12 = getBestAverage(of: 12)
        bestAo100 = getBestAverage(of: 100)
        
#warning("TODO:  optimise")
        sessionMean = getSessionMean()
        
        
        
        changedTimeListSort()
        bestSingle = getMin()
        
        currentAo5 = getCurrentAverage(of: 5)
        currentAo12 = getCurrentAverage(of: 12)
        currentAo100 = getCurrentAverage(of: 100)
    }
    
    
    func changePen(solve: Solve, pen: Penalty) {
        #warning("TODO:  check best AOs")
        if solve.penalty == pen.rawValue {
            return
        }
        
        solve.penalty = pen.rawValue
        if timeListSolvesFiltered.contains(solve) {
            timeListReloadSolve?(solve)
        }
        
        solves.remove(object: solve)
        solves.insert(solve, at: solves.insertionIndex(of: solve))
        
        
        if solve.penalty != Penalty.dnf.rawValue {
            solvesNoDNFsbyDate.insert(solve, at: solvesNoDNFsbyDate.insertionIndexDate(solve: solve))
            solvesNoDNFs.insert(solve, at: solvesNoDNFs.insertionIndex(of: solve))
        } else if solve.penalty == Penalty.dnf.rawValue {
            solvesNoDNFsbyDate.remove(object: solve)
            solvesNoDNFs.remove(object: solve)
        }
        
        bestSingle = getMin()
        phases = getAveragePhases()
        sessionMean = getSessionMean()
        
        if (solvesByDate.suffix(100).contains(solve)) {
            self.currentAo100 = getCurrentAverage(of: 100)
            if (solvesByDate.suffix(12).contains(solve)) {
                self.currentAo12 = getCurrentAverage(of: 12)
                if (solvesByDate.suffix(5).contains(solve)) {
                    self.currentAo5 = getCurrentAverage(of: 5)
                }
            }
        }
        
        self.bestAo5 = getBestAverage(of: 5)
        self.bestAo12 = getBestAverage(of: 12)
        self.bestAo100 = getBestAverage(of: 100)
        
        try! managedObjectContext.save()
    }

    
    func displayPenOptions() {
        withAnimation(Animation.customSlowSpring) {
            showPenOptions = true
        }
    }
    
    func deleteLastSolve() {
        guard let solveItem else {return}
        delete(solve: solveItem)
        timerController.secondsElapsed = 0
        
        if !SettingsManager.standard.showPrevTime || currentSession is CompSimSession {
            if currentSession is CompSimSession {
                statsGetFromCache()
            }
            self.solveItem = nil
        } else {
            self.solveItem = solvesByDate.last
        }
        
        timerController.secondsStr = formatSolveTime(secs: self.solveItem?.time ?? 0)
        tryUpdateCurrentSolveth()
    }
    
    func askToDelete() {
        withAnimation(Animation.customSlowSpring) {
            showPenOptions = false
        }
        
        if solveItem != nil {
            #warning("TODO")
            showDeleteSolveConfirmation = true
        }
    }
}
