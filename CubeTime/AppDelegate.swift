import Foundation
import UIKit

/// DELEGATE TO SET IDLETIMER ON APP LAUNCH + SCENE ACTIVE
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true

        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "customConfig", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomScene.self

        return sceneConfiguration
    }
}

final class CustomScene: UIResponder, UIWindowSceneDelegate {
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if shortcutItem.type == "com.cubetime.cubetime.allsessions" {
            TabRouter.shared.currentTab = .sessions
        } else if shortcutItem.type == "com.cubetime.cubetime.session" {
            TabRouter.shared.pendingSessionURL = (shortcutItem.userInfo!["id"] as! NSString)
        }
    }
}
