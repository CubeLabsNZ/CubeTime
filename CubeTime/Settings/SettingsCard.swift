import SwiftUI

let defaultIconStyle: Font = .system(size: 44, weight: .light)
let specialIconStyle: Font = .system(size: 32, weight: .regular)

enum SettingsType {
    case general, appearance, help
}

struct SettingsCardInfo: Hashable {
    var name: String
    var id: SettingsType
    var icon: String
    var iconStyle: Font
}

var settingsCards: [SettingsCardInfo] = [
    SettingsCardInfo(name: String(localized: "General"), id: .general, icon: "gearshape.2", iconStyle: defaultIconStyle),
    SettingsCardInfo(name: String(localized: "Appearance"), id: .appearance, icon: "paintpalette", iconStyle: defaultIconStyle),
    SettingsCardInfo(name: String(localized: "Help &\nAbout Us"), id: .help, icon: "info", iconStyle: defaultIconStyle),
]
