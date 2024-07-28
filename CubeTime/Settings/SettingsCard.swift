import SwiftUI

let defaultIconStyle: Font = .system(size: 44, weight: .light)
let specialIconStyle: Font = .system(size: 32, weight: .regular)

struct SettingsCardInfo: Hashable {
    var name: String
    var icon: String
    var iconStyle: Font
}

var settingsCards: [SettingsCardInfo] = [
    SettingsCardInfo(name: String(localized: "General"), icon: "gearshape.2", iconStyle: defaultIconStyle),
    SettingsCardInfo(name: String(localized: "Appearance"), icon: "paintpalette", iconStyle: defaultIconStyle),
    SettingsCardInfo(name: String(localized: "Help &\nAbout Us"), icon: "info", iconStyle: defaultIconStyle),
]
