//
//  TimerOnlyTool.swift
//  CubeTime
//
//  Created by Tim Xie on 26/02/23.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct TimerOnlyTool: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var tabRouter: TabRouter
    
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    @Binding var showOverlay: Tool?
    
    var namespace: Namespace.ID
    
    let name: String
    
    init(showOverlay: Binding<Tool?>, namespace: Namespace.ID) {
        self._showOverlay = showOverlay
        self.namespace = namespace
        self.name = showOverlay.wrappedValue!.name
        
    }
    
    // GET USER DEFAULTS
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @AppStorage(asKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    
    @State var hideStatusBar = true
    
    var body: some View {
        GeometryReader { geo in
            TimerBackgroundColor()
                .ignoresSafeArea(.all)
            
            TimerTouchView(stopwatchManager: stopwatchManager)
            
            
            TimerTime()
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            
            
            if stopwatchManager.mode == .stopped {
                HStack {
                    Label("Timer Only", systemImage: "stopwatch")
                    .matchedGeometryEffect(id: name, in: namespace)
                    .font(.system(size: 17, weight: .medium))
                    .padding(.leading, 8)
                    .padding(.trailing)
                    .frame(height: 35)
                    .background(
                        Color("overlay1")
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            .matchedGeometryEffect(id: "bg" + name, in: namespace)
                    )
                    
                    Spacer()
                    
                    CloseButton(hasBackgroundShadow: true) {
                        showOverlay = nil
                        tabRouter.hideTabBar = false
                    }
                }
                .padding(.horizontal, padFloatingLayout && UIDevice.deviceIsPad && UIDevice.deviceIsLandscape(globalGeometrySize) ? 24 : nil)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .statusBar(hidden: hideStatusBar)
        .ignoresSafeArea(.keyboard)
    }
}

