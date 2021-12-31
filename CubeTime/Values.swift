import Foundation
import SwiftUI


extension Color: RawRepresentable {
    public typealias RawValue = String
    init(_ hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
    
    public init?(rawValue: RawValue) {
        let colors = rawValue.components(separatedBy: ",")
        self.init(
            red: Double(colors[0]) ?? 88/255,
            green: Double(colors[1]) ?? 86/255,
            blue: Double(colors[2]) ?? 124/255
        )
    }

    public var rawValue: RawValue {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        return "\(r),\(g),\(b)"
    }
}

enum PenTypes: Int16 {
    case none
    case plustwo
    case dnf
}

enum SessionTypes: Int16 {
    case standard
    case algtrainer
    case multiphase
    case playground
    case compsim
}

struct resisableText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .allowsTightening(true)
    }
}

func formatSolveTimeForTimer(secs: Double, dp: Int) -> String {
    if secs < 60 {
        return String(format: "%.\(dp)f", secs) // TODO set DP
    } else {
        let mins: Int = Int((secs / 60).rounded(.down))
        let secs = secs.truncatingRemainder(dividingBy: 60)
        
        return String(format: "%d:%06.\(dp)f", mins, secs)
    }
}

func formatSolveTime(secs: Double, penType: PenTypes? = PenTypes.none) -> String {
    if penType == PenTypes.dnf {
        return "DNF"
    }
    let dp = UserDefaults.standard.integer(forKey: gsKeys.displayDP.rawValue)
    let secsfmt = penType == .plustwo ? ".\(dp)f+" : ".\(dp)f"
    if secs < 60 {
        return String(format: "%\(secsfmt)", secs) // TODO set DP
    } else {
        let mins: Int = Int((secs / 60).rounded(.down))
        let secs = secs.truncatingRemainder(dividingBy: 60)
        
        return String(format: "%d:%06\(secsfmt)", mins, secs)
    }
}


func formatLegendTime(secs: Double, dp: Int) -> String {
    
    if secs < 10 {
        return String(format: "%.\(dp)f", secs) // dp = 1
    } else if secs < 60 {
        return String(format: "%.\(dp-1)f", secs) // TODO set DP
    } else if secs < 600 {
        let mins: Int = Int((secs / 60).rounded(.down))
        let secs = Int(secs.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", mins, secs)
    } else {
        let mins: Int = Int((secs / 60).rounded(.down))
        return String(format: "%dm", mins)
    }
}


struct PuzzleType {
    let name: String
    let subtypes: [Int: String]
    
    let scrID: Int32
    var blind = false
}


// TODO 3BLD

let puzzle_types: [PuzzleType] = [
    PuzzleType(name: "2x2", subtypes: [0: "Random State"], scrID: 0),
    PuzzleType(name: "3x3", subtypes: [0: "Random State", 2: "Cross Solved"], scrID: 1),
    PuzzleType(name: "4x4", subtypes: [0: "WCA"], scrID: 2),
    PuzzleType(name: "5x5", subtypes: [0: "WCA"], scrID: 3),
    PuzzleType(name: "6x6", subtypes: [0: "prefix", 1: "SiGN (OLD)"], scrID: 4), // TODO remove prefix only here because 0 hardcoded
    PuzzleType(name: "7x7", subtypes: [0: "prefix", 1: "SiGN (OLD)"], scrID: 5), // TODO remove prefix
    PuzzleType(name: "Square-1", subtypes: [0: "Random State"], scrID: 6),
    PuzzleType(name: "Megaminx", subtypes:  [0: "Pochmann"], scrID: 7),
    PuzzleType(name: "Pyraminx", subtypes: [0: "Random State", 1: "Random Moves"], scrID: 8),
    PuzzleType(name: "Clock", subtypes: [0: "WCA"], scrID: 9),
    PuzzleType(name: "Skewb", subtypes: [0: "Random State"], scrID: 10),
    
    PuzzleType(name: "3x3 OH", subtypes: [0: "Random State"], scrID: 1), // TODO map to actual scrambles
    PuzzleType(name: "3x3 Blindfolded", subtypes: [0: "Random State"], scrID: 1, blind: true),
    PuzzleType(name: "4x4 Blindfolded", subtypes: [0: "Random State"], scrID: 2, blind: true),
    PuzzleType(name: "5x5 Blindfolded", subtypes: [0: "Random State"], scrID: 3, blind: true),
    
]


class SetValues {
    
    
    static let tabBarHeight = 50
    static let marginLeftRight = 16
    static let paddingIcons = 14
    static let spacingIcons = 20
    static let marginBottom = 16
    static let iconFontSize = CGFloat(22)
    static let hasBottomBar = UIApplication.shared.windows[0].safeAreaInsets.bottom > 0
}

class TimerTextColours {
    static let timerDefaultColour: Color = Color.primary
    static let timerDefaultColourDarkMode: Color = Color.primary
    static let timerHeldDownColour: Color = Color.red
    static let timerCanStartColour: Color = Color.green
}

class InspectionColours {
    static let eightColour: Color = Color(red: 234/255, green: 224/255, blue: 182/255)
    static let twelveColour: Color = Color(red: 234/255, green: 212/255, blue: 182/255)
    static let penaltyColour: Color = Color(red: 234/255, green: 194/255, blue: 192/255)
    
//    static let eightColour = 0xeae0b6
//    static let twelveColour = 0xead4b6
//    static let penaltyColour = 0xeac2c0
    
//    static let eightColour = Color(0xeae0b6)
//    static let twelveColour = Color(0xead4b6)
//    static let penaltyColour = Color(0xeac2c0)
}

func getGradient(gradientArray: [[Color]], gradientSelected: Int?) -> LinearGradient {
    if let gradientSelected = gradientSelected {
        return LinearGradient(gradient: Gradient(colors: gradientArray[gradientSelected]), startPoint: .bottomTrailing, endPoint: .topLeading)
    } else {
        return LinearGradient(gradient: Gradient(colors: gradientArray[6]), startPoint: .bottomTrailing, endPoint: .topLeading)
    }
}

func getGradientColours(gradientArray: [[Color]], gradientSelected: Int?) -> [Color] {
    if let gradientSelected = gradientSelected {
        return gradientArray[gradientSelected]
    } else {
        return gradientArray[6]
    }
}

class CustomGradientColours {
    static let gradientColours: [[Color]] = [
        [Color(0x0093c1), Color(0x05537a)], // light blue - dark blue
        [Color(0x52c8cd), Color(0x007caa)], // aqua - light blue
        [Color(0xe6e29a), Color(0x3ec4d0)], // pale yellow/white ish - aqua
        [Color(0xffd325), Color(0x94d7be)], // yellow - green
        [Color(0xff9e45), Color(0xffd63c)], // pale orange-yellow
        
        [Color(0xfc7018), Color(0xffc337)], // darker orange - yellow
        [Color(0xfb5b5c), Color(0xff9528)], // pink-orange
        [Color(0xd35082), Color(0xf77d4f)], // magenta-orange
        [Color(0x8548ba), Color(0xd95378)], // purple-pink
        [Color(0x3f248f), Color(0x702f86)] // dark blue-purple
    ]
}
