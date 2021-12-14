//
//  UserDefinedValues.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import Foundation
import SwiftUI


extension Color: RawRepresentable {
    public typealias RawValue = Int
    init(_ hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
    
    public init?(rawValue: RawValue) {
        self.init(UInt(rawValue))
    }

    public var rawValue: RawValue {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Int(r * 255) << 16) + (Int(r * 255) << 08) + (Int(r * 255) << 00)
    }
}

enum PenTypes: Int16 {
    case none
    case plustwo
    case dnf
}


func formatSolveTime(secs: Double, penType: PenTypes = .none) -> String {
    if penType == PenTypes.dnf {
        return "DNF"
    }
    let secsfmt = penType == .plustwo ? ".3f+" : ".3f"
    if secs < 60 {
        return String(format: "%\(secsfmt)", secs) // TODO set DP
    } else {
        let mins: Int = Int((secs / 60).rounded(.down))
        let secs = secs.truncatingRemainder(dividingBy: 60)
        
        return String(format: "%d:%06\(secsfmt)", mins, secs)
    }
}


struct PuzzleType {
    let name: String
    let subtypes: [Int: String]
    
}


// TODO 3BLD

let puzzle_types: [PuzzleType] = [
    PuzzleType(name: "2x2", subtypes: [0: "Random State"]),
    PuzzleType(name: "3x3", subtypes: [0: "Random State", 2: "Cross Solved"]),
    PuzzleType(name: "4x4", subtypes: [0: "WCA"]),
    PuzzleType(name: "5x5", subtypes: [0: "WCA"]),
    PuzzleType(name: "6x6", subtypes: [0: "prefix", 1: "SiGN (OLD)"]), // TODO remove prefix only here because 0 hardcoded
    PuzzleType(name: "7x7", subtypes: [0: "prefix", 1: "SiGN (OLD)"]), // TODO remove prefix
    PuzzleType(name: "Square-1", subtypes: [0: "Random State"]),
    PuzzleType(name: "Megaminx", subtypes:  [0: "Pochmann"]),
    PuzzleType(name: "Pyraminx", subtypes: [0: "Random State", 1: "Random Moves"]),
    PuzzleType(name: "Clock", subtypes: [0: "WCA"]),
    PuzzleType(name: "Skewb", subtypes: [0: "Random State"]),
    
    PuzzleType(name: "3x3 OH", subtypes: [0: "Random State"]), // TODO map to actual scrambles
    PuzzleType(name: "3x3 Blindfolded", subtypes: [0: "Random State"]),
    PuzzleType(name: "4x4 Blindfolded", subtypes: [0: "Random State"]),
    PuzzleType(name: "5x5 Blindfolded", subtypes: [0: "Random State"]),
    
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
    @Environment(\.colorScheme) var colourScheme
    
//    static var timerDefaultColour: Color {
//        if colourScheme == .light {
//            return Color.black
//        } else {
//            return Color.white
//        }
//    } /// doesn't work wtf
    
    static let timerDefaultColour: Color = Color.primary
    static let timerDefaultColourDarkMode: Color = Color.primary
    static let timerHeldDownColour: Color = Color.red
    static let timerCanStartColour: Color = Color.green
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
