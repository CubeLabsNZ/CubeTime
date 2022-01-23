import Foundation
import SwiftUI
import SVGKit


struct ScrambleImageView: UIViewRepresentable {
    @Binding var puzzle: OrgWorldcubeassociationTnoodleScramblesPuzzleRegistry
    @Binding var scramble: String
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgText = JavaUtilObjects.toString(withId: puzzle.getScrambler().drawScramble(with: scramble, with: nil))
        let svgImage = SVGKImage(data: svgText.data(using: .utf8))
        return SVGKFastImageView(svgkImage: svgImage!)!
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        let svgText = JavaUtilObjects.toString(withId: puzzle.getScrambler().drawScramble(with: scramble, with: nil))
        uiView.image = SVGKImage(data: svgText.data(using: .utf8))
    }
}
