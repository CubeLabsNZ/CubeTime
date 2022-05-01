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
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        
//        print("hi")
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(name: "customConfig", sessionRole: connectingSceneSession.role)
        sceneConfiguration.delegateClass = CustomScene.self
        
//        print("hi")
        
        return sceneConfiguration
    }
}

final class CustomScene: UIResponder, UIWindowSceneDelegate {
    func sceneDidBecomeActive(_ scene: UIScene) {
//        print("hi")
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
}
