import Foundation
import SwiftUI
import SVGKit
import SVGView
import SwiftfulLoadingIndicators

struct AsyncSVGView: View {
    @State var svg = ""
    var puzzle: Int32
    var scramble: String

    var body: some View {
        Group {
            if svg == "" {
                #warning("weird bug, full circle initially...")
                LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .medium, speed: .fast)
//                ProgressView()
            } else {
                SVGView(string: svg)
//                AsyncScrambleSVGViewRepresentable(svg: svg, width: width, height: height)
                    .aspectRatio(contentMode: .fit)
            }
        }
        .task {
            let task = Task.detached(priority: .userInitiated) { () -> String in
                #if DEBUG
                NSLog("ismainthread \(Thread.isMainThread)")
                #endif
                
                var isolate: OpaquePointer? = nil
                var thread: OpaquePointer? = nil
                
                
                
                graal_create_isolate(nil, &isolate, &thread)
                
                var svg: String!
                
                
                scramble.withCString { s in
                    svg = String(cString: tnoodle_lib_draw_scramble(thread, puzzle, s))
                }
                
                graal_tear_down_isolate(thread);
                
                return svg
            }
            let result = await task.result
            svg = try! result.get()
        }
    }
}

@available(*, deprecated, message: "USE SVGVIEW")
// uikit wrappers
struct DefaultScrambleSVGViewRepresentable: UIViewRepresentable {
    var svg: String
    var width: CGFloat
    var height: CGFloat
    
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(data: svg.data(using: .utf8))!
        svgImage.scaleToFit(inside: CGSize(width: width, height: height))
        
        let imageView = SVGKFastImageView(svgkImage: svgImage)!
//        imageView.backgroundColor = UIColor.green
//        imageView.setContentHuggingPriority(.required, for: .horizontal)
//        imageView.setContentHuggingPriority(.required, for: .vertical)
//        imageView.frame(forAlignmentRect: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        
        
        return imageView
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        
    }
}

struct AsyncScrambleSVGViewRepresentable: UIViewRepresentable {
    var svg: String
    var width: CGFloat
    var height: CGFloat
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(data: svg.data(using: .utf8))
        svgImage!.scaleToFit(inside: CGSize(width: width, height: height))
        return SVGKFastImageView(svgkImage: svgImage!)!
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        let svgImage = SVGKImage(data: svg.data(using: .utf8))
        svgImage?.scaleToFit(inside: CGSize(width: width, height: height))
        uiView.image = svgImage
    }
}
