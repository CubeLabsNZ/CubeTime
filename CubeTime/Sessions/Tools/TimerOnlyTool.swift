//
//  TimerOnlyTool.swift
//  CubeTime
//
//  Created by Tim Xie on 26/02/23.
//

import SwiftUI

struct TimerOnlyTool: View {
    @StateObject var timerController: TimerController = TimerController()
    
    var body: some View {
        ZStack {
            Color("base")
                .ignoresSafeArea(.all)
            
            TimerTouchView()
            
            TimerTime()
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            
            
            if (timerController.mode == .stopped) {
                ToolHeader(name: tools[0].name, image: tools[0].iconName, content: { EmptyView() })
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .environmentObject(timerController)
        .statusBar(hidden: (timerController.mode != .stopped))
        .ignoresSafeArea(.keyboard)
    }
}
