import XCTest
import UIKit
@testable import CubeTime

class FormatSolveTest: XCTestCase {
    let num = 10000
    var times: [Double]!
    
    override func setUp() {
        times = (0..<num).map { _ in
            Double.random(in: 0..<(99*60+60))
        }
        NSLog("TIMES: \(times.prefix(100)), count: \(times.count)")
    }

    func testFormatPerf() {
        self.measure {
            for time in times {
                // Bogus test to not optimize the result away
                XCTAssertNotNil(formatSolveTime(secs: time, dp: 3))
            }
        }
    }

}

class FontSpeedTest: XCTestCase {
    let num = 1000
    var variationsList: [[Int: Any]]!
    var sizes: [Double]!
    
    override func setUpWithError() throws {
        variationsList = (0..<num).map { _ in
            [2003265652: Int.random(in: 300...1000), 1128354636: Double.random(in: 0...1), 1129468758: [0, 0.5, 1].randomElement()!]
        }
        sizes = (0..<num).map { _ in Double.random(in: 0...100)}
    }

    func testUiFontPerformance() throws {
        self.measure(metrics: [XCTClockMetric()]) {
            for (size, variations) in zip(sizes.unsafelyUnwrapped, variationsList.unsafelyUnwrapped) {
                let uiFontDesc = UIFontDescriptor(fontAttributes: [
                    .name: "RecursiveSansLinearLightMonospace-Regular",
                    kCTFontVariationAttribute as UIFontDescriptor.AttributeName: variations
                ])
                let uiFont = UIFont(descriptor: uiFontDesc, size: size)
                XCTAssertNotNil(uiFont) // Make sure the compiler doesnt optimize out the variable
            }
        }
    }
    
    func testCtFontPerformance() throws {
        self.measure(metrics: [XCTClockMetric()]) {
            for (size, variations) in zip(sizes.unsafelyUnwrapped, variationsList.unsafelyUnwrapped) {
                let ctFontDesc = CTFontDescriptorCreateWithAttributes([
                    kCTFontNameAttribute: "RecursiveSansLinearLightMonospace-Regular",
                    kCTFontVariationAttribute: variations
                ] as! CFDictionary)
                let ctFont = CTFontCreateWithFontDescriptor(ctFontDesc, size, nil)
                XCTAssertNotNil(ctFont) // Make sure the compiler doesnt optimize out the variable
            }
        }
    }
}
