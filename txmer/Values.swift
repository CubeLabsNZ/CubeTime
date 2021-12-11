//
//  UserDefinedValues.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import Foundation
import SwiftUI


extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
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
    
    static let timerDefaultColour: Color = Color.black
    static let timerDefaultColourDarkMode: Color = Color.primary
    static let timerHeldDownColour: Color = Color.red
    static let timerCanStartColour: Color = Color.green
}

class CustomGradientColours {
    static let ccPink: Color = Color(red: 236/255, green: 74/255, blue: 134/255)
    static let ccPrpl: Color = Color(red: 126/255, green: 94/255, blue: 191/255)
    
    
    static let gradientColour: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 236/255, green: 74/255, blue: 134/255), Color(red: 136/255, green: 94/255, blue: 191/255)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing)

    
}
