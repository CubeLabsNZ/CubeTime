import Foundation
import SwiftUI
import SVGKit


struct SVGView: UIViewRepresentable {
    var svg: String
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(data: svg.data(using: .utf8))
        return SVGKFastImageView(svgkImage: svgImage!)!
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        uiView.image = SVGKImage(data: svg.data(using: .utf8))
    }
}

struct AsyncScrambleView: View {
    @State var svg = ""
    var puzzle: OrgWorldcubeassociationTnoodleScramblesPuzzleRegistry
    var scramble: String

    
    var body: some View {
        let _ = NSLog("here")
        
        Group {
            if svg == "" {
                ProgressView()
            } else {
                SVGView(svg: svg)
                    .aspectRatio(contentMode: .fit)
            }
        }.task {
            let task = Task.detached(priority: .userInitiated) { () -> String in
                NSLog("ismainthread \(Thread.isMainThread)")
                return JavaUtilObjects.toString(withId: puzzle.getScrambler().drawScramble(with: scramble, with: nil))
            }
            let result = await task.result
            svg = try! result.get()
        }
    }
}


struct TimerSVGView: UIViewRepresentable {
    var svg: OrgWorldcubeassociationTnoodleSvgliteSvg
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgstr = JavaUtilObjects.toString(withId: svg)
        let svgImage = SVGKImage(data: svgstr.data(using: .utf8))!
        
        return SVGKFastImageView(svgkImage: svgImage)!
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        
    }
}


struct TimerScrambleView: View {
    let svg: OrgWorldcubeassociationTnoodleSvgliteSvg?
    var body: some View {
        TimerSVGView(svg: svg!)
    }
}
