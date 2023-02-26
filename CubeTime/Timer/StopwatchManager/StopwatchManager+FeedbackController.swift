import Foundation
import SwiftUI

extension StopwatchManager {
    func calculateFeedbackStyle() {
        self.feedbackStyle = hapticEnabled ? UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.init(rawValue: hapticType)!) : nil
    }
}
