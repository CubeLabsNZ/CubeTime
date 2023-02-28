//
//  TimerOnlyTool.swift
//  CubeTime
//
//  Created by Tim Xie on 26/02/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct TimerOnlyTool: View {
    @StateObject var timerController: TimerContoller = TimerContoller()
    
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    // GET USER DEFAULTS
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @AppStorage(asKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    
    var body: some View {
        GeometryReader { geo in
            TimerBackgroundColor()
                .environmentObject(timerController)
                .ignoresSafeArea(.all)
            
            TimerTouchView()
                .environmentObject(timerController)
            
            TimerTime()
                .environmentObject(timerController)
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            
            
            if (timerController.mode == .stopped) {
                ToolHeader(name: tools[0].name, image: tools[0].iconName, content: { EmptyView() })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .statusBar(hidden: (timerController.mode != .stopped))
        .ignoresSafeArea(.keyboard)
    }
}
