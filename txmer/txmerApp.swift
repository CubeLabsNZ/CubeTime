//
//  txmerApp.swift
//  txmer
//
//  Created by Tim Xie on 24/11/21.
//

import SwiftUI

@main
struct txmerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTimerView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
