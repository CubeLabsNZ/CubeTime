//
//  UserDefinedValues.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import Foundation
import SwiftUI

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
    PuzzleType(name: "6x6", subtypes: [1: "SiGN (OLD)"]),
    PuzzleType(name: "7x7", subtypes: [1: "SiGN (OLD)"]),
    PuzzleType(name: "Square-1", subtypes: [0: "Random State"]),
    PuzzleType(name: "Megaminx", subtypes:  [0: "Pochmann"]),
    PuzzleType(name: "Pyraminx", subtypes: [0: "Random State", 1: "Random Moves"]),
    PuzzleType(name: "Clock", subtypes: [0: "WCA"]),
    PuzzleType(name: "Skewb", subtypes: [0: "Random State"]),
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
    static let timerDefaultColourDarkMode: Color = Color.white
    static let timerHeldDownColour: Color = Color.red
    static let timerCanStartColour: Color = Color.green
}
