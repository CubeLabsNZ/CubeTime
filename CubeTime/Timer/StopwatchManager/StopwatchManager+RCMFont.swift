import Foundation
import SwiftUI

extension StopwatchManager {
    func updateFont() {
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

