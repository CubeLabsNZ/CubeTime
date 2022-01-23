import SwiftUI
import UIKit
import CoreData


@main
struct CubeTime: App {
    @Environment(\.scenePhase) var phase
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /*
    var shortcutItem: UIApplicationShortcutItem?
     */
    
    
    let persistenceController: PersistenceController
    private let moc: NSManagedObjectContext
    
    init() {
        persistenceController = PersistenceController.shared
        moc = persistenceController.container.viewContext
        
        
//        UIApplication.shared.isIdleTimerDisabled = true
        
        let userDefaults = UserDefaults.standard
        userDefaults.register(
            defaults: [
                gsKeys.inspection.rawValue: false,
                gsKeys.freeze.rawValue: 0.5,
                gsKeys.gestureDistance.rawValue: 50,
                gsKeys.hapBool.rawValue: true,
                gsKeys.hapType.rawValue: UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue,
                gsKeys.timeDpWhenRunning.rawValue: 3,
                gsKeys.displayDP.rawValue: 3,
                gsKeys.showStats.rawValue: true,
                gsKeys.showScramble.rawValue: true,
                asKeys.graphGlow.rawValue: true
            ]
        )
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabsView(managedObjectContext: moc)
                .environment(\.managedObjectContext, moc)
        }
//        .onChange(of: phase) { newValue in
//            if newValue == .active {
//                print(appDelegate.shortcutItem)
//            }
//        }
    }
}
