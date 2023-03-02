//
//  FontManager.swift
//  CubeTime
//
//  Created by trainz-are-kul on 2/03/23.
//

import Foundation
import SwiftUI
import CoreText

class FontManager: ObservableObject {
    var fontWeight: Double = UserDefaults.standard.double(forKey: asKeys.fontWeight.rawValue) {
        didSet {
            updateFont()
        }
    }
    var fontCasual: Double = UserDefaults.standard.double(forKey: asKeys.fontCasual.rawValue) {
        didSet {
            updateFont()
        }
    }
    var fontCursive: Bool = UserDefaults.standard.bool(forKey: asKeys.fontCursive.rawValue) {
        didSet {
            updateFont()
        }
    }
    var scrambleSize: Int = UserDefaults.standard.integer(forKey: asKeys.scrambleSize.rawValue) {
        didSet {
            updateFont()
        }
    }
    
    
    
    @Published var ctFontScramble: Font!
    @Published var ctFontDescBold: CTFontDescriptor!
    @Published var ctFontDesc: CTFontDescriptor!
    
    
    static func fontFor(size: CGFloat, variations: [Int: Int]) -> Font {
        let desc = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variations
        ] as! CFDictionary)
        
        return Font(CTFontCreateWithFontDescriptor(desc, size, nil))
    }
    
    static func fontFor(size: CGFloat, weight: Int) -> Font {
        return fontFor(size: size, variations: [2003265652: weight, 1128354636: 0, 1129468758: 0])
    }
    
    static let mono10 = fontFor(size: 10, weight: 600)
    static let mono10Bold = fontFor(size: 10, weight: 800)
    static let mono11Bold = fontFor(size: 11, weight: 800)
    static let mono13 = fontFor(size: 13, weight: 600)
    static let mono15 = fontFor(size: 15, weight: 600)
    static let mono15Bold = fontFor(size: 15, weight: 800)
    static let mono16 = fontFor(size: 16, weight: 600)
    static let mono17 = fontFor(size: 17, weight: 600)
    
    
    init() {
        updateFont()
    }
    
    private func updateFont() {
            // weight, casual, cursive
        let variations = [2003265652: fontWeight, 1128354636: fontCasual, 1129468758: fontCursive ? 1 : 0]
        let variationsTimer = [2003265652: fontWeight + 200, 1128354636: fontCasual, 1129468758: fontCursive ? 1 : 0]
        
        ctFontDesc = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variations
        ] as! CFDictionary)
        
        ctFontDescBold = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variationsTimer
        ] as! CFDictionary)
        
        ctFontScramble = Font(CTFontCreateWithFontDescriptor(ctFontDesc, CGFloat(scrambleSize), nil))
    }
}
