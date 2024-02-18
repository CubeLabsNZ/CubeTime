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
    let sm = SettingsManager.standard
    
    @Published var ctFontScramble: Font!
    @Published var ctFontDescBold: CTFontDescriptor!
    @Published var ctFontDesc: CTFontDescriptor!
    
    static func fontFor(size: CGFloat, weight: Int) -> CTFont {
        let desc = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: [2003265652: weight,
                                        1128354636: 0,
                                        1129468758: 0]
        ] as! CFDictionary)
        
        return CTFontCreateWithFontDescriptor(desc, size, nil)
    }
    
    let changeOnKeys: [PartialKeyPath<SettingsManager>] = [\.fontWeight, \.fontCursive, \.fontCasual, \.scrambleSize]
    
    var subscriber: AnyCancellable?
    
    init() {
        subscriber = sm.preferencesChangedSubject
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
        let variations = [2003265652: sm.fontWeight, 1128354636: sm.fontCasual, 1129468758: sm.fontCursive ? 1 : 0]
        let variationsTimer = [2003265652: sm.fontWeight + 200, 1128354636: sm.fontCasual, 1129468758: sm.fontCursive ? 1 : 0]
        
        ctFontDesc = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variations
        ] as! CFDictionary)
        
        ctFontDescBold = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: variationsTimer
        ] as! CFDictionary)
        
        ctFontScramble = Font(CTFontCreateWithFontDescriptor(ctFontDesc, CGFloat(sm.scrambleSize), nil))
    }
}

struct RecursiveMono: ViewModifier {
    @ScaledMetric var size: CGFloat
    let weight: Int
    
    init(size: CGFloat, weight: Int) {
        self._size = ScaledMetric(wrappedValue: size)
        self.weight = weight
    }
    
    func body(content: Content) -> some View {
        content
            .font(Font(FontManager.fontFor(size: size, weight: weight)))
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
        modifier(RecursiveMono(size: size,
                               weight: RecursiveMono.weightToValue(weight: weight)))
    }
    
    func recursiveMono(style: Font.TextStyle, weight: Font.Weight=Font.Weight.regular) -> some View {
        modifier(RecursiveMono(size: RecursiveMono.styleToValue(style: style),
                               weight: RecursiveMono.weightToValue(weight: weight)))
    }
}
