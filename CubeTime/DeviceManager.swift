//
//  DeviceManager.swift
//  CubeTime
//
//  Created by Tim Xie on 3/12/22.
//

import Foundation
import SwiftUI

class DeviceManager: ObservableObject {
    @Published var deviceOrientation: UIInterfaceOrientation?
    @Published var windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
        (scene as? UIWindowScene)?.keyWindow
    }).first?.frame.size
    
    init(deviceOrientation: UIInterfaceOrientation? = nil) {
        self.deviceOrientation = deviceOrientation
    }
}
