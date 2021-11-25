//
//  txmerApp.swift
//  txmer
//
//  Created by Tim Xie on 21/11/21.
//

import SwiftUI

@main
@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct txmerApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject var tabRouter = TabRouter()
    
    var body: some Scene {
        WindowGroup {
            //MainTimerView()
            //TimeListView()
            //TimesView()
            // NEW UPDATE USE THIS - REAGAN
            MainTabsView(tabRouter: tabRouter)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
