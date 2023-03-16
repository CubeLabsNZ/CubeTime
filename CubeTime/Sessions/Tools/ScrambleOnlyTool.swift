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
        ZStack {
            if let scr = scrambleController.scrambleStr {
                Text(scr)
                    .multilineTextAlignment(.center)
                    .recursiveMono(fontSize: 24, weight: .medium)
                    .padding(.horizontal)
            } else {
                LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
            }
            
            Color.white.opacity(0.0001)
                .onTapGesture {
                    scrambleController.rescramble()
                }
            
            
            ToolHeader(name: tools[1].name, image: tools[1].iconName, content: {
                Picker("", selection: $scrambleController.scrambleType) {
                    ForEach(Array(zip(puzzleTypes.indices, puzzleTypes)), id: \.0) { index, element in
                        Text(element.name).tag(Int32(index))
                            .font(.system(size: 15, weight: .regular))
                    }
                }
            })
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            scrambleController.rescramble()
        }
    }
}
