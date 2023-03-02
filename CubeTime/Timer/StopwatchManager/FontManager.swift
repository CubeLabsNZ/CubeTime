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
