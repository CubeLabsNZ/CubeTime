//
//  ScrambleView.swift
//  CubeTime
//
//  Created by macos sucks balls on 1/21/22.
//

import Foundation
import SwiftUI
import SVGKit


struct SVGView: UIViewRepresentable {
    @Binding var svg: String
    
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
    @Binding var puzzle: OrgWorldcubeassociationTnoodleScramblesPuzzleRegistry
    @Binding var scramble: String
    
    var body: some View {
        Group {
            if svg == "" {
                ProgressView("Loading scramble image")
                    .progressViewStyle(.linear)
            } else {
                SVGView(svg: $svg)
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
