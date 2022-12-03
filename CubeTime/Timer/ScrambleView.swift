import Foundation
import SwiftUI
import SVGKit
import SwiftfulLoadingIndicators

// swiftui views
struct DefaultScrambleView: View {
    let svg: String?
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        DefaultScrambleSVGViewRepresentable(svg: svg!, width: width, height: height)
    }
}

struct AsyncScrambleView: View {
    @State var svg = ""
    var puzzle: Int
    var scramble: String

    var width: CGFloat
    var height: CGFloat
    
    
    var body: some View {
        Group {
            if svg == "" {
                #warning("weird bug, full circle initially...")
                LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .medium, speed: .fast)
//                ProgressView()
            } else {
                AsyncScrambleSVGViewRepresentable(svg: svg, width: width, height: height)
                    .aspectRatio(contentMode: .fit)
            }
        }.task {
            let task = Task.detached(priority: .userInitiated) { () -> String in
                #if DEBUG
                NSLog("ismainthread \(Thread.isMainThread)")
                #endif
                
                var isolate: OpaquePointer? = nil
                var thread: OpaquePointer? = nil
                
                
                
                graal_create_isolate(nil, &isolate, &thread)
                
                var svg: String!
                
                
                scramble.withCString { s in
                    let buffer = UnsafeMutablePointer<Int8>(mutating: s) // https://github.com/CubeStuffs/tnoodle-lib-native/issues/2
                    svg = String(cString: Main__drawScramble__cebd98ae40477cd5c997c10733315758f3be6fe4(thread, 2, buffer))
                }
                
                graal_tear_down_isolate(thread);
                
                return svg
            }
            let result = await task.result
            svg = try! result.get()
        }
    }
}

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
