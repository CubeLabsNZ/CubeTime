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
    @Published var currentTab: Tab = .timer
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
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        VStack {
            
            ZStack {
                switch tabRouter.currentTab {
                case .timer:
                    MainTimerView()
                        .environment(\.managedObjectContext, managedObjectContext)
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
                        VStack {
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.systemGray5))
                            
                                .frame(
                                    width: geometry.size.width - CGFloat(SetValues.marginLeftRight * 2),
                                    height: CGFloat(SetValues.tabBarHeight),
                                    alignment: .center
                                )
                            
                                .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 3)
                            
                                /*
                                .position(
                                    x: geometry.size.width / 2 - CGFloat(SetValues.marginLeftRight),
                                    y: geometry.size.height - 0.5 * CGFloat(SetValues.tabBarHeight)
                                )
                            */
                            
                                .padding(.leading, CGFloat(SetValues.marginLeftRight))
                                .padding(.trailing, CGFloat(SetValues.marginLeftRight))
                            
                            
                        }
                        /*
                        VStack {
                            
                            Spacer()
                            HStack {
                                RoundedRectangle(cornerRadius: 12)
                                    
                                
                                
                                Spacer()
                            }
                            
                        }
                         */
                        
                        VStack {
                            
                            Spacer()
                            
                            HStack {
                                
                                HStack {
                                    TabIcon(
                                        assignedTab: .timer,
                                        tabRouter: tabRouter,
                                        systemIconName: "stopwatch",
                                        systemIconNameSelected: "stopwatch.fill"
                                    )
                                        .padding(.leading, 14)
                                    
                                    Spacer()
                                    
                                    TabIcon(
                                        assignedTab: .solves,
                                        tabRouter: tabRouter,
                                        systemIconName: "hourglass.bottomhalf.filled",
                                        systemIconNameSelected: "hourglass.tophalf.filled"
                                    )
                                    
                                    Spacer()
                                    
                                    TabIcon(
                                        assignedTab: .stats,
                                        tabRouter: tabRouter,
                                        systemIconName: "chart.pie",
                                        systemIconNameSelected: "chart.pie.fill"
                                    )
                                    
                                    Spacer()
                                    
                                    TabIcon(
                                        assignedTab: .sessions,
                                        tabRouter: tabRouter,
                                        systemIconName: "line.3.horizontal.circle",
                                        systemIconNameSelected: "line.3.horizontal.circle.fill"
                                    )
                                        .padding(.trailing, 14)
                                }
                                
                                //.frame(maxWidth: 240)
                                
                                //.fill(Color(UIColor.systemGray4))
                                
                                .frame(
                                    width: 220,
                                    height: CGFloat(SetValues.tabBarHeight),
                                    alignment: .leading
                                )
                                
                                //.padding(.leading, CGFloat(SetValues.marginLeftRight))
                                //.padding(.trailing, CGFloat(SetValues.marginLeftRight))
                                
                                .background(Color(UIColor.systemGray4).clipShape(RoundedRectangle(cornerRadius:12)))
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3.5)
                                .padding(.leading, CGFloat(SetValues.marginLeftRight))
                                
                                
                                Spacer()
                                TabIcon(
                                    assignedTab: .settings,
                                    tabRouter: tabRouter,
                                    systemIconName: "gearshape",
                                    systemIconNameSelected: "gearshape.fill"
                                )
                                    .padding(.trailing, CGFloat(SetValues.marginLeftRight + 12))
                                
                                
                            }
                            //.padding(.bottom, 12)
                            
                            
                        }
                        
                        
                        
                                            
                       
                            
                        /*
                        .padding(.leading, CGFloat(SetValues.marginLeftRight))
                        .padding(.trailing, CGFloat(SetValues.marginLeftRight))
                         */
                    }
                }//.frame(height: CGFloat(SetValues.tabBarHeight), alignment: .bottom)
                   // .offset(y: SetValues.hasBottomBar ? CGFloat(0) : CGFloat(-SetValues.marginBottom))
                .padding(.bottom, SetValues.hasBottomBar ? CGFloat(0) : CGFloat(SetValues.marginBottom))
            }
            
                
                
                
            }
    }
}

@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct MainTabsView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabsView(tabRouter: TabRouter())
    }
}
