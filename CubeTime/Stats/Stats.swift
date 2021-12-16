import Foundation
import CoreData
import SwiftUI


struct CalculatedAverage: Identifiable {
    let id: String
    
    let average: Double
//    let discardedIndexes: [Int]
    let accountedSolves: [Solves]
}


class Stats {
    var solves: [Solves]
    //    private var top: [Solves]
    //    private var bottom: [Solves]
    
    var solvesByDate: [Solves]
    
    private let currentSession: Sessions
    
    private let managedObjectContext: NSManagedObjectContext
    
    private let fetchRequest = NSFetchRequest<Solves>(entityName: "Solves")
    
    init (currentSession: Sessions, managedObjectContext: NSManagedObjectContext) {
        self.currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        fetchRequest.predicate = NSPredicate(format: "session == %@", currentSession)
        
        /// Uncomment below if you want coredata to sort for you but this is inflexible and may be `O(n log n)` vs `O(n)`
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Solves.time, ascending: true)]
        do {
            try solves = managedObjectContext.fetch(fetchRequest)
            
            
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        //        print(solves)
        
        
        /// 1. GET MIN
        //        for solve in solves {
        //
        //        }
        
        // your code here
        // calculate top and bottom n percent using my alg, maybe add a global length var
        
        solvesByDate = solves.sorted(by: {$0.date! < $1.date!})
//        solvesByDate = solves
    }
    
    
    
    func getMin() -> Solves? {
        if solves.count == 0 {
            return nil
        }
        return solves[0]
    }
    
    func getSessionMean() -> Double? {
        if solves.count == 0 {
            return nil
        } 
        var noDNFs = solves
        noDNFs.removeAll(where: { $0.penalty == 3 })
        let sum = noDNFs.reduce(0, {$0 + $1.time})
        return sum / Double(noDNFs.count)
    }
    
    func getNumberOfSolves() -> Int {
        
        return solves.count
    }
    
    
    
    func getBestMovingAverageOf(_ period: Int) -> CalculatedAverage? {
        precondition(period > 1)
        if solvesByDate.count < period {
            return nil
        }
        
        var trim: Int
        
        if period > 100 {
            trim = 5
        } else {
            trim = 1
        }
            
        
        var lowest_average: Double = solves[solves.count-1].time
        var lowest_values: [Solves]?
        
        for i in period..<solves.count+1 {
            let range = i - period + trim..<i - trim
            let sum = solvesByDate[range].reduce(0, {$0 + $1.time})
            
            let result = Double(sum) / Double(period-2)
            if result < lowest_average {
                lowest_values = solvesByDate[i - period ..< i].sorted(by: {$0.date! > $1.date!})
                lowest_average = result
            }
        }
        return CalculatedAverage(id: "Best AO\(period)", average: lowest_average, accountedSolves: lowest_values!)
    }

    
    
    func getCurrentAverageOf(_ period: Int) -> CalculatedAverage? {
        if solves.count < period {
            return nil
        }
        
        return CalculatedAverage(
            id: "Current AO\(period)",
            average: solvesByDate.suffix(period).sorted(by: {$0.time > $1.time}).dropFirst().dropLast().reduce(0, {$0 + $1.time}) / Double(period-2),
            accountedSolves: solvesByDate.suffix(period)
        )
    }
    
}
