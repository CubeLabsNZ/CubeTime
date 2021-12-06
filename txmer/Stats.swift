//
//  Stats.swift
//  txmer
//
//  Created by macos sucks balls on 12/6/21.
//

import Foundation

import CoreData

class Stats {
    private var solves: [Solves]
    private var top: [Solves]
    private var bottom: [Solves]
    
    private let currentSession: Sessions
    
    private let managedObjectContext: NSManagedObjectContext
    
    private let fetchRequest = NSFetchRequest<Solves>(entityName: "Solves")
    
    init (currentSession: Sessions, managedObjectContext: NSManagedObjectContext) {
        self.currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        fetchRequest.predicate = NSPredicate(format: "session == %@", currentSession)
        
        /// Uncomment below if you want coredata to sort for you but this is inflexible and may be `O(n log n)` vs `O(n)`
        // fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Solves.time, ascending: true)]
        do {
            try solves = managedObjectContext.fetch(fetchRequest)
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        // your code here
        // calculate top and bottom n percent using my alg, maybe add a global length var
    }
    
    func best() -> Solves {
        // Return the smallest element of bottom
    }
}
