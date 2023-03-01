//
//  ScrambleOnlyTool.swift
//  CubeTime
//
//  Created by trainz-are-kul on 1/03/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ScrambleOnlyTool: View {
    @StateObject var scrambleController = ScrambleController()
    
    var body: some View {
        GeometryReader { geo in
            
            if let scr = scrambleController.scrambleStr {
                ScrambleText(scr: scr, timerSize: geo.size, scrambleSheetStr: .constant(nil))
                    .frame(maxHeight: .infinity, alignment: .top)
            } else {
                LoadingIndicator(animation: .circleRunner, color: .accentColor, size: .small, speed: .fast)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            
            ToolHeader(name: tools[1].name, image: tools[1].iconName, content: {
                Picker("", selection: $scrambleController.scrambleType) {
                    ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                        Text(element.name).tag(Int32(index))
                            .font(.system(size: 15, weight: .regular))
                    }
                }
            })
            .allowsHitTesting(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .contentShape(Rectangle())
        .onAppear {
//            scrambleController.rescramble()
        }
        .onTapGesture {
            NSLog("TAP")
            scrambleController.rescramble()
        }
    }
}

struct ScrambleOnlyTool_Previews: PreviewProvider {
    static var previews: some View {
        ScrambleOnlyTool()
    }
}
