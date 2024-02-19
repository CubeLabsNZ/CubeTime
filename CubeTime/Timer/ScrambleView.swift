import Foundation
import SwiftUI
import SVGView
import SwiftfulLoadingIndicators

//import TNoodleLibNative

struct AsyncSVGView: View {
    @State var svg: String?
    var puzzle: Int32
    var scramble: String

    var body: some View {
        Group {
            if let svg = svg {
                SVGView(string: svg)
                    .aspectRatio(contentMode: .fit)
            } else {
                LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
            }
        }
        .task {
            let task = Task.detached(priority: .userInitiated) { () -> String? in
                var isolate: OpaquePointer? = nil
                var thread: OpaquePointer? = nil
                
                
                
                graal_create_isolate(nil, &isolate, &thread)
                
                var svg: String!
                
                #warning("todo: infinite loading if :boom:")
                scramble.withCString { s in
                    if let drawnSvg = tnoodle_lib_draw_scramble(thread, puzzle, s) {
                        svg = String(cString: drawnSvg)
                    } else {
                        svg = nil
                    }
                }
                
                graal_tear_down_isolate(thread);
                
                return svg
            }
            let result = await task.result
            svg = try? result.get()
        }
    }
}
