//
//  txmerApp.swift
//  txmer
//
//  Created by Tim Xie on 21/11/21.
//

import SwiftUI

@main
struct txmerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // MainTimerView() // USE THIS WHEN TESTING YOUR THING
            // TimeListView() // COMMENT THIS OUT WHEN TESTING
            // NEW UPDATE USE THIS - REAGAN
            MainTabsView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
