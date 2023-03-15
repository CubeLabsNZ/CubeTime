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
    
    static func fontFor(size: CGFloat, weight: Int) -> Font {
        let desc = CTFontDescriptorCreateWithAttributes([
            kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
            kCTFontVariationAttribute: [2003265652: weight,
                                        1128354636: 0,
                                        1129468758: 0]
        ] as! CFDictionary)
        
        return Font(CTFontCreateWithFontDescriptor(desc, size, nil))
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
    
    func recursiveMono(fontSize: CGFloat, weight: Font.Weight=Font.Weight.regular) -> some View {
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
