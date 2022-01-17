//
//  QuickActions.swift
//  CubeTime
//
//  Created by macos sucks balls on 1/16/22.
//

import Foundation
import UIKit
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    var shortcutItem: UIApplicationShortcutItem? {AppDelegate.shortcutItem}
    
    fileprivate static var shortcutItem: UIApplicationShortcutItem?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = shortcutItem {
            AppDelegate.shortcutItem = shortcutItem
        }
        let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomSceneDelegate.self
        
        return sceneConfiguration
    }
}


private final class CustomSceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        #if DEBUG
        NSLog("scene has shortcutitem \(shortcutItem)")
        #endif
        
        AppDelegate.shortcutItem = shortcutItem
        completionHandler(true)
    }
}


