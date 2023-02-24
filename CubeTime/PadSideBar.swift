//
//  PadSideBar.swift
//  CubeTime
//
//  Created by trainz-are-kul on 3/12/22.
//

import SwiftUI


struct PadMainView: View {
    @EnvironmentObject var tabRouter: TabRouter
    @Namespace private var namespace
    
    var body: some View {
        HStack {
            if !tabRouter.hideTabBar {
                PadSideBar(namespace: namespace)
            }
            
            if tabRouter.padExpandState == 1 || tabRouter.currentTab == .timer {
                TimerView()
                    .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            } else {
                switch tabRouter.currentTab {
                case .solves:
                    TimeListView()
                        .matchedGeometryEffect(id: "TimeList", in: namespace)
                case .stats:
                    StatsView()
                        .matchedGeometryEffect(id: "Stats", in: namespace)
                case .sessions:
                    SessionsView()
                        .matchedGeometryEffect(id: "Sessions", in: namespace)
                case .settings:
                    SettingsView()
                default:
                    EmptyView()
                }
            }
        }
        .animation(.spring(), value: tabRouter.padExpandState)
    }
}

struct PadSideBar: View {
    @EnvironmentObject var tabRouter: TabRouter
    
    var namespace: Namespace.ID
    
    var body: some View {
        HStack {
            TabBar(currentTab: $tabRouter.currentTab, pad: true)
                .padding(.leading)
                .padding(.trailing, 50)
            if tabRouter.padExpandState == 1 {
                VStack {
                    switch tabRouter.currentTab {
                    case .solves:
                        TimeListView()
                            .matchedGeometryEffect(id: "TimeList", in: namespace)
                    case .stats:
                        StatsView()
                            .matchedGeometryEffect(id: "Stats", in: namespace)
                    case .sessions:
                        SessionsView()
                            .matchedGeometryEffect(id: "Sessions", in: namespace)
                    case .settings:
                        SettingsView()
                    default:
                        EmptyView()
                    }
                }
                .frame(width: 400)
            }
            VStack {
                if tabRouter.padExpandState == 1 {
                    Button() {
                        tabRouter.padExpandState = 0
                        tabRouter.currentTab = .timer
                    } label: {
                        Text("<-")
                    }
                }
                
                Button() {
                    if tabRouter.padExpandState == 0 {
                        tabRouter.padExpandState = 1
                    } else {
                        tabRouter.padExpandState = 0
                    }
                } label: {
                    Text("->")
                }
            }

            Divider()
        }
    }
}
