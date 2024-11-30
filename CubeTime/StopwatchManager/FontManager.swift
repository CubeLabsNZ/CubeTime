//
//  FontManager.swift
//  CubeTime
//
//  Created by trainz-are-kul on 2/03/23.
//

import Foundation
import SwiftUI
import Combine
import CoreText

class FontManager: ObservableObject {
    let settingsManager = SettingsManager.standard
    
    @Published var ctFontScramble: Font!
    @Published var ctFontDescBold: CTFontDescriptor!
    @Published var ctFontDesc: CTFontDescriptor!
    
    static func fontFor(size: CGFloat, weight: Int, font: CTCustomFontType = .recursive) -> CTFont {
        var desc: CTFontDescriptor!
        
        switch font {
        case .recursive:
            desc = CTFontDescriptorCreateWithAttributes([
                kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
                kCTFontVariationAttribute: [2003265652: weight,
                                            1128354636: 0,
                                            1129468758: 0]
            ] as! CFDictionary)
            
        case .rubik:
            desc = CTFontDescriptorCreateWithAttributes([
                kCTFontNameAttribute: "Rubik",
                kCTFontVariationAttribute: [2003265652: weight]
            ] as! CFDictionary)
        }
        
        return CTFontCreateWithFontDescriptor(desc, size, nil)
    }
    
    let changeOnKeys: [PartialKeyPath<SettingsManager>] = [\.fontWeight, \.fontCursive, \.fontCasual, \.scrambleSize]
    
    var subscriber: AnyCancellable?
    
    init() {
        subscriber = settingsManager.preferencesChangedSubject
            .filter { item in
                (self.changeOnKeys as [AnyKeyPath]).contains(item)
            }
            .sink(receiveValue: { [weak self] i in
            self?.updateFont()
        })
        updateFont()
    }
    
    private func updateFont() {
            // weight, casual, cursive
        let variations = [2003265652: settingsManager.fontWeight, 1128354636: settingsManager.fontCasual, 1129468758: settingsManager.fontCursive ? 1 : 0]
        let variationsTimer = [2003265652: settingsManager.fontWeight + 200, 1128354636: settingsManager.fontCasual, 1129468758: settingsManager.fontCursive ? 1 : 0]
        
        ctFontDesc = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variations
        ] as! CFDictionary)
        
        ctFontDescBold = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variationsTimer
        ] as! CFDictionary)
        
        ctFontScramble = Font(CTFontCreateWithFontDescriptor(ctFontDesc, CGFloat(settingsManager.scrambleSize), nil))
    }
}


enum CTCustomFontType {
    case recursive
    case rubik
}

struct CTCustomFont: ViewModifier {
    @ScaledMetric var size: CGFloat
    
    let weight: Int
    let font: CTCustomFontType
    
    init(size: CGFloat, weight: Int, font: CTCustomFontType) {
        self._size = ScaledMetric(wrappedValue: size)
        self.weight = weight
        self.font = font
    }
    
    func body(content: Content) -> some View {
        content
            .font(Font(FontManager.fontFor(size: size, weight: weight, font: self.font)))
    }

    static func weightToValue(weight: Font.Weight) -> Int {
        switch weight {
        case .regular:
            return 400
        case .medium:
            return 500
        case .semibold:
            return 600
        case .bold:
            return 700
            
        default:
            return 400
        }
    }
    
    static func styleToValue(style: Font.TextStyle) -> CGFloat {
        // using default (Large) dynamic type sizes
        switch style {
        case .largeTitle:
            return 34
        case .title:
            return 28
        case .title2:
            return 22
        case .title3:
            return 20
        
        case .body:
            return 17
        case .callout:
            return 16
        case .subheadline:
            return 16
        
        case .footnote:
            return 13
        case .caption:
            return 12
        case .caption2:
            return 11
            
        default:
            return 17
        }
    }
}

extension View {
    func recursiveMono(size: CGFloat, weight: Font.Weight=Font.Weight.regular) -> some View {
        modifier(CTCustomFont(size: size,
                              weight: CTCustomFont.weightToValue(weight: weight),
                              font: .recursive))
    }
    
    func recursiveMono(style: Font.TextStyle, weight: Font.Weight=Font.Weight.regular) -> some View {
        modifier(CTCustomFont(size: CTCustomFont.styleToValue(style: style),
                              weight: CTCustomFont.weightToValue(weight: weight),
                              font: .recursive))
    }
    
    func recursiveMono(style: Font.TextStyle, weightValue: Int) -> some View {
        modifier(CTCustomFont(size: CTCustomFont.styleToValue(style: style),
                              weight: weightValue,
                              font: .recursive))
    }
}


//extension Font {
//    static func system(size: CGFloat, weight: Font.Weight? = nil, design: Font.Design? = nil) -> Font {
//        return Font(FontManager.fontFor(size: size, weight: CTCustomFont.weightToValue(weight: weight ?? Font.Weight.regular) + 100, font: .recursive))
//    }
//    
//    static let caption = Font(FontManager.fontFor(size: 11, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//    static let caption2 = Font(FontManager.fontFor(size: 12, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//    static let footnote = Font(FontManager.fontFor(size: 13, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//    static let subheadline = Font(FontManager.fontFor(size: 15, weight: CTCustomFont.weightToValue(weight: .semibold), font: .recursive))
//    static let callout = Font(FontManager.fontFor(size: 17, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//    static let body = Font(FontManager.fontFor(size: 17, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//    static let title3 = Font(FontManager.fontFor(size: 20, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//    static let title2 = Font(FontManager.fontFor(size: 22, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//    static let title = Font(FontManager.fontFor(size: 28, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//    static let largeTitle = Font(FontManager.fontFor(size: 34, weight: CTCustomFont.weightToValue(weight: .regular), font: .recursive))
//}
