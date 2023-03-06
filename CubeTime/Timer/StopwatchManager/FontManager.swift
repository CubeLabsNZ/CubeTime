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
    var fontWeight: Double = UserDefaults.standard.double(forKey: appearanceSettingsKey.fontWeight.rawValue) {
        didSet {
            updateFont()
        }
    }
    var fontCasual: Double = UserDefaults.standard.double(forKey: appearanceSettingsKey.fontCasual.rawValue) {
        didSet {
            updateFont()
        }
    }
    var fontCursive: Bool = UserDefaults.standard.bool(forKey: appearanceSettingsKey.fontCursive.rawValue) {
        didSet {
            updateFont()
        }
    }
    var scrambleSize: Int = UserDefaults.standard.integer(forKey: appearanceSettingsKey.scrambleSize.rawValue) {
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

struct RecursiveMono: ViewModifier {
    @ScaledMetric var fontSize: CGFloat
    let weight: Int
    
    init(fontSize: CGFloat, weight: Int) {
        self._fontSize = ScaledMetric(wrappedValue: fontSize)
        self.weight = weight
    }
    
    func body(content: Content) -> some View {
        content
            .font(FontManager.fontFor(size: fontSize, weight: weight))
    }
}

extension View {
    func recursiveMono(fontSize: CGFloat, weight: Int) -> some View {
        modifier(RecursiveMono(fontSize: fontSize, weight: weight))
    }
    
    func recursiveMono(fontSize: CGFloat, weight: Font.Weight) -> some View {
        switch (weight) {
        case .regular:
            return modifier(RecursiveMono(fontSize: fontSize, weight: 400))
        case .medium:
            return modifier(RecursiveMono(fontSize: fontSize, weight: 500))
        case .semibold:
            return modifier(RecursiveMono(fontSize: fontSize, weight: 600))
        case .bold:
            return modifier(RecursiveMono(fontSize: fontSize, weight: 700))
            
        default:
            return modifier(RecursiveMono(fontSize: fontSize, weight: 400))
        }
    }
}
