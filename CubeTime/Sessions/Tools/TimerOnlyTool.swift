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
    
    @Binding var showOverlay: Tool?
    var namespace: Namespace.ID
    let name: String
    
    init(showOverlay: Binding<Tool?>, namespace: Namespace.ID) {
        self._showOverlay = showOverlay
        self.namespace = namespace
        self.name = showOverlay.wrappedValue!.name
        
    }
    
    var body: some View {
        TimerOnlyToolInner(showOverlay: $showOverlay, namespace: namespace, name: name)
            .environmentObject(timerController)
    }
}

struct TimerOnlyToolInner: View {
    @EnvironmentObject var timerController: TimerContoller
    @EnvironmentObject var tabRouter: TabRouter
    
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    @Binding var showOverlay: Tool?
    
    var namespace: Namespace.ID
    
    let name: String
    
    // GET USER DEFAULTS
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @AppStorage(asKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    
    @State var hideStatusBar = true
    
    var body: some View {
        GeometryReader { geo in
            TimerBackgroundColor()
                .ignoresSafeArea(.all)
            
            TimerTouchView()
            
            
            TimerTime()
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            
            
            if timerController.mode == .stopped || timerController.mode == .inspecting {
                //ToolHeader(name: name, image: "stopwatch", content: {EmptyView()})
                    //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .statusBar(hidden: hideStatusBar)
        .ignoresSafeArea(.keyboard)
    }
}

