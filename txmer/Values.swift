//
//  UserDefinedValues.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import Foundation
import SwiftUI


extension Color {
    init(_ hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
}



func formatSolveTime(secs: Double) -> String {
    if secs < 60 {
        return String(format: "%.3f", secs) // TODO set DP
    } else {
        let mins: Int = Int((secs / 60).rounded(.down))
        let secs = secs.truncatingRemainder(dividingBy: 60)
        
        return String(format: "%d:%06.3f", mins, secs)
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
    
    PuzzleType(name: "3x3 OH", subtypes: [0: "Random State"]),
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

func getGradient(gradientArray: [[Color]]) -> LinearGradient {
    return LinearGradient(gradient: Gradient(colors: gradientArray[5]), startPoint: .bottomTrailing, endPoint: .topLeading)
}

func getGradientColours(gradientArray: [[Color]]) -> [Color] {
    return gradientArray[5]
}

class CustomGradientColours {
    static let gradientColours: [[Color]] = [
        /* old colours
        [Color(0x218db6), Color(0x074a70)], // light blue - dark blue
        [Color(0x68c1c3), Color(0x197aa2)], // aqua - light blue
        [Color(0xebe9b9), Color(0x5abec7)], // pale yellow/white ish - aqua
        [Color(0xf6d657), Color(0x9cd0bf)], // yellow - green
        [Color(0xf7ae6b), Color(0xf6d968)], // pale orange-yellow
        
        [Color(0xf28947), Color(0xf7cc63)], // darker orange - yellow
        [Color(0xee777b), Color(0xf6a757)], // pink-orange
        [Color(0xca678d), Color(0xf68e6a)], // magenta-orange
        [Color(0x5c3480), Color(0xcf6c87)], // purple-pink
        [Color(0x372c75), Color(0x703f82)] // dark blue-purple
        */
        
        
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
