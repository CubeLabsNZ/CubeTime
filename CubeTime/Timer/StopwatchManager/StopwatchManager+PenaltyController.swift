import Foundation
import SwiftUI

extension StopwatchManager {
    func changedPen(_ oldPen: PenTypes) {
        if oldPen.rawValue == solveItem.penalty {
            return
        }
        
        if PenTypes(rawValue: solveItem.penalty)! == .plustwo {
            timerController.secondsStr = formatSolveTime(secs: timerController.secondsElapsed, penType: PenTypes(rawValue: solveItem.penalty)!)
        } else {
            timerController.secondsStr = formatSolveTime(secs: timerController.secondsElapsed, penType: PenTypes(rawValue: solveItem.penalty)!)
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
        
        
#warning("TODO: next update use optimised versions")
        
        bestAo5 = getBestMovingAverageOf(5)
        bestAo12 = getBestMovingAverageOf(12)
        bestAo100 = getBestMovingAverageOf(100)
        
#warning("TODO:  optimise")
        sessionMean = getSessionMean()
        
        
        
        changedTimeListSort()
        bestSingle = getMin()
        
        currentAo5 = getCurrentAverageOf(5)
        currentAo12 = getCurrentAverageOf(12)
        currentAo100 = getCurrentAverageOf(100)
    }
    
    
    func changePen(solve: Solves, pen: PenTypes) {
        #warning("TODO:  check best AOs")
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
        
        bestSingle = getMin()
        phases = getAveragePhases()
        
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

    
    func displayPenOptions() {
        withAnimation(Animation.customSlowSpring) {
            showPenOptions = true
            nilSolve = (solveItem == nil)
        }
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
