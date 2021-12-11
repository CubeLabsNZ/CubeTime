//
//  SettingsCard.swift
//  txmer
//
//  Created by Tim Xie on 9/12/21.
//

import SwiftUI

let defaultIconStyle: Font = .system(size: 44, weight: .light)
let specialIconStyle: Font = .system(size: 32, weight: .regular)

struct SettingsCardInfo: Hashable {
    var name: String
    var icon: String
    var iconStyle: Font
}

var settingsCards: [SettingsCardInfo] = [
    SettingsCardInfo(name: "General", icon: "gearshape.2", iconStyle: defaultIconStyle),
    SettingsCardInfo(name: "Appearance", icon: "paintpalette", iconStyle: defaultIconStyle),
    SettingsCardInfo(name: "Import &\nExport", icon: "square.and.arrow.up.on.square", iconStyle: specialIconStyle),
    SettingsCardInfo(name: "About", icon: "info", iconStyle: defaultIconStyle)
]
