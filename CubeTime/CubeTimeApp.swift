import SwiftUI
//import UIKit
import CoreData

/*
let menuActions = MenuActions()
var shortcutItemToProcess: UIApplicationShortcutItem?
 */

@main
struct CubeTime: App {
    /*
    @Environment(\.scenePhase) var phase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    */
    
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
                gsKeys.hapType.rawValue: UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue,
                gsKeys.timeDpWhenRunning.rawValue: 3,
                gsKeys.displayDP.rawValue: 3
            ]
        )
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabsView(managedObjectContext: moc)
                .environment(\.managedObjectContext, moc)
//                .environmentObject(menuActions)
        }
        /*
        .onChange(of: phase) { newphase in
            switch newphase {
            case .active:
                print("app active")
                guard let name = shortcutItemToProcess?.userInfo?["name"] as? String else { return }
            case .background:
                print("background")
            case .inactive:
                print("inactive")
            @unknown default:
                print("default")
            }
        }
         */
        
    }
}


/*
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        
        return sceneConfiguration
    }
}

class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    @Environment(\.openURL) var openURL
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcutItem(shortcutItem)
    }
    
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        NSLog("\(shortcutItem)")
        
        /*
        if shortcutItem.t == "Timer" {
            print("timer pressed")
            
            print("Quick launch to Offers")
            
            if let url = URL(string:"cardpointers://open/offer/0") {
                openURL(url)
            }
        } else {
            print("run but not right")
            print("\(shortcutItem)")
        }
         */
        
    }
}
*/
