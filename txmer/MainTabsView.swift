//
//  MainTabsView.swift
//  txmer
//
//  Created by macos sucks balls on 11/25/21.
//

import SwiftUI

enum Tab {
    case timer
    case solves
    case stats
    case sessions
    case settings
}



class TabRouter: ObservableObject {
    @Published var currentTab: Tab = .stats
}


struct TabIcon: View {
    let assignedTab: Tab
    @StateObject var tabRouter: TabRouter
    let systemIconName: String
    var systemIconNameSelected: String
    var body: some View {
        Image(
            systemName:
                tabRouter.currentTab == assignedTab ? systemIconNameSelected : systemIconName
        )
            .font(.system(size: SetValues.iconFontSize))
            .onTapGesture {
                tabRouter.currentTab = assignedTab
            }
    }
}



@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct MainTabsView: View {
    
    @StateObject var tabRouter: TabRouter
    
    var body: some View {
        VStack {
            
            switch tabRouter.currentTab {
            case .timer:
                MainTimerView()
            case .solves:
                TimeListView()
            case .stats:
                StatsView()
            case .sessions:
                SessionsView()
            case .settings:
                SettingsView()
            }
            
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemGray3))
                    
                        .frame(
                            width: geometry.size.width - CGFloat(SetValues.marginLeftRight * 2),
                            height: CGFloat(SetValues.tabBarHeight),
                            alignment: .center
                            //height: geometry.safeAreaInsets.top,
                            //height:  - safeAreaInset(edge: .bottom) - CGFloat(tabBarHeight),
                        )
                    
                        .position(
                            x: geometry.size.width / 2 - CGFloat(SetValues.marginLeftRight),
                            y: geometry.size.height - 0.5 * CGFloat(SetValues.tabBarHeight)
                        )
                    
                        /*
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 50)
                         */
                        .padding(.leading, CGFloat(SetValues.marginLeftRight))
                        .padding(.trailing, CGFloat(SetValues.marginLeftRight))
                    HStack (){
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray2))
                                .frame(maxWidth: (22+14) * 4)
                            HStack {
                                TabIcon(
                                    assignedTab: .timer,
                                    tabRouter: tabRouter,
                                    systemIconName: "stopwatch",
                                    systemIconNameSelected: "stopwatch.fill"
                                )
                                TabIcon(
                                    assignedTab: .solves,
                                    tabRouter: tabRouter,
                                    systemIconName: "hourglass.bottomhalf.filled",
                                    systemIconNameSelected: "hourglass.tophalf.filled"
                                )
                                TabIcon(
                                    assignedTab: .stats,
                                    tabRouter: tabRouter,
                                    systemIconName: "chart.pie",
                                    systemIconNameSelected: "chart.pie.fill"
                                )
                                TabIcon(
                                    assignedTab: .sessions,
                                    tabRouter: tabRouter,
                                    systemIconName: "line.3.horizontal.circle",
                                    systemIconNameSelected: "line.3.horizontal.circle.fill"
                                )
                                
                            }
                        }
                        Spacer()
                        TabIcon(
                            assignedTab: .settings,
                            tabRouter: tabRouter,
                            systemIconName: "gearshape",
                            systemIconNameSelected: "gearshape.fill"
                        )
                    }
                    .padding(.leading, CGFloat(SetValues.marginLeftRight))
                    .padding(.trailing, CGFloat(SetValues.marginLeftRight))
                }
            }.frame(height: CGFloat(SetValues.tabBarHeight), alignment: .bottom)
                .offset(y: SetValues.hasBottomBar ? CGFloat(0) : CGFloat(-SetValues.marginBottom))
        }
        /*
        TabView {
            MainTimerView()
                .tabItem {
                    Image(systemName: "stopwatch")
            }
            TimeListView()
                .tabItem {
                    Image(systemName: "hourglass.bottomhalf.filled")
            }
            StatsView()
                .tabItem {
                    Image(systemName: "chart.pie")
            }
            SessionsView()
                .tabItem {
                    Image(systemName: "line.3.horizontal.circle")
            }
            SettingsView()
                .tabItem {
                    Image(systemName: "line.3.horizontal.circle")
            }
        }*/
    }
}

@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct MainTabsView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabsView(tabRouter: TabRouter())
    }
}
