import SwiftUI
import CoreData

@main
@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct CubeTime: App {
    let persistenceController: PersistenceController
    private let moc: NSManagedObjectContext
    
    init() {
        persistenceController = PersistenceController.shared
        moc = persistenceController.container.viewContext
        
        let userDefaults = UserDefaults.standard
        userDefaults.register(
            defaults: [
                gsKeys.inspection.rawValue: false,
                gsKeys.freeze.rawValue: 0.5,
                gsKeys.gestureDistance.rawValue: 50,
                gsKeys.hapBool.rawValue: true,
                gsKeys.hapType.rawValue: UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue
            ]
        )
        
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabsView(managedObjectContext: moc)
                .environment(\.managedObjectContext, moc)
        }
    }
}
