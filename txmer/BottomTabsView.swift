//
//  BottomTabsView.swift
//  txmer
//
//  Created by macos sucks balls on 12/8/21.
//

import SwiftUI

struct BottomTabsView: View {
    @Binding var hide: Bool
    @Binding var currentTab: Tab
    
    var body: some View {
        if !hide {
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
                            .padding(.leading, CGFloat(SetValues.marginLeftRight))
                            .padding(.trailing, CGFloat(SetValues.marginLeftRight))
                    }.zIndex(0)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            HStack {
                                TabIcon(
                                    assignedTab: .timer,
                                    currentTab: $currentTab,
                                    systemIconName: "stopwatch",
                                    systemIconNameSelected: "stopwatch.fill"
                                )
                                    .padding(.leading, 14)
                                
                                Spacer()
                                
                                TabIcon(
                                    assignedTab: .solves,
                                    currentTab: $currentTab,
                                    systemIconName: "hourglass.bottomhalf.filled",
                                    systemIconNameSelected: "hourglass.tophalf.filled"
                                )
                                
                                Spacer()
                                
                                TabIcon(
                                    assignedTab: .stats,
                                    currentTab: $currentTab,
                                    systemIconName: "chart.pie",
                                    systemIconNameSelected: "chart.pie.fill"
                                )
                                
                                Spacer()
                                
                                TabIcon(
                                    assignedTab: .sessions,
                                    currentTab: $currentTab,
                                    systemIconName: "line.3.horizontal.circle",
                                    systemIconNameSelected: "line.3.horizontal.circle.fill"
                                )
                                    .padding(.trailing, 14)
                            }
                            .frame(
                                width: 220,
                                height: CGFloat(SetValues.tabBarHeight),
                                alignment: .leading
                            )
                            .background(Color(UIColor.systemGray4).clipShape(RoundedRectangle(cornerRadius:12)))
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3.5)
                            .padding(.leading, CGFloat(SetValues.marginLeftRight))
                            
                            Spacer()
                            
                            TabIcon(
                                assignedTab: .settings,
                                currentTab: $currentTab,
                                systemIconName: "gearshape",
                                systemIconNameSelected: "gearshape.fill"
                            )
                                .padding(.trailing, CGFloat(SetValues.marginLeftRight + 12))
                        }
                    }
                    .zIndex(1)
                }
                
                .ignoresSafeArea(.keyboard)
                
            }
            .padding(.bottom, SetValues.hasBottomBar ? CGFloat(0) : CGFloat(SetValues.marginBottom))
            .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
//            .transition(AnyTransition.scale.animation(.easeIn(duration: 1)))
            //
            
        }
    }
        
}

//struct BottomTabsView_Previews: PreviewProvider {
//    static var previews: some View {
//        BottomTabsView()
//    }
//}
