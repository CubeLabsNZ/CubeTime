//
//  txmerApp.swift
//  txmer
//
//  Created by Tim Xie on 21/11/21.
//

import SwiftUI
import CoreData

@main
@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct txmerApp: App {
    let persistenceController: PersistenceController
    private let moc: NSManagedObjectContext
    
    init() {
        persistenceController = PersistenceController.shared
        moc = persistenceController.container.viewContext
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabsView(managedObjectContext: moc)
                .environment(\.managedObjectContext, moc)
        }
    }
}
