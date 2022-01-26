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
        Group {
            if svg == "" {
                ProgressView()
                    .progressViewStyle(.linear)
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
        
        
        
        
//        NSLog("\(UIScreen.main.scale)")

//        let svgsize = CGSize(svg.getSize())
//        NSLog("svgsize \(svgsize)")
        
//        NSLog("width: \(svgsize.width), height: \(svgsize.height)")
        
//        let ratio: CGFloat = CGFloat(svgsize.width) / CGFloat(svgsize.height)
//        NSLog("ratio \(ratio)")
//        let newsize = CGSize(width: size.width, height: CGFloat(size.width) * ratio)
//        NSLog("newsize \(newsize)")
        
//        let newsize = CGSize(width: 20, height: 10)
        
//        svg.setSizeWith(OrgWorldcubeassociationTnoodleSvgliteDimension(newsize))
        let svgstr = JavaUtilObjects.toString(withId: svg)
        let svgImage = SVGKImage(data: svgstr.data(using: .utf8))!
        
        
        
//        svgImage.size = newsize
        
        return SVGKFastImageView(svgkImage: svgImage)!
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        
    }
}


struct TimerScrambleView: View {
    let svg: OrgWorldcubeassociationTnoodleSvgliteSvg?
    var body: some View {
        if let svg = svg {
            TimerSVGView(svg: svg)
        } else {
            ProgressView()
        }
    }
}
