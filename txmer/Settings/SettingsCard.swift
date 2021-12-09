//
//  SettingsCard.swift
//  txmer
//
//  Created by Tim Xie on 9/12/21.
//

import SwiftUI

let defaultIconStyle: Font = .system(size: 44, weight: .light)
let specialIconStyle: Font = .system(size: 32, weight: .regular)

struct SettingsCard: Identifiable {
    var id = UUID().uuidString
    var name: String
    var icon: String
    var iconStyle: Font
}

var settingsCards: [SettingsCard] = [
    SettingsCard(name: "Appearance", icon: "paintpalette", iconStyle: defaultIconStyle),
    SettingsCard(name: "General", icon: "gearshape.2", iconStyle: defaultIconStyle),
    SettingsCard(name: "Import &\nExport", icon: "square.and.arrow.up.on.square", iconStyle: specialIconStyle),
    SettingsCard(name: "About", icon: "info", iconStyle: defaultIconStyle)
]
