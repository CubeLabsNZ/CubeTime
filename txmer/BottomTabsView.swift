//
//  BottomTabsView.swift
//  txmer
//
//  Created by macos sucks balls on 12/8/21.
//

import SwiftUI


@available(iOS 15.0, *)
struct BottomTabsView: View {
    @Binding var hide: Bool
    @Binding var currentTab: Tab
    
    var namespace: Namespace.ID
    
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
                            .padding(.horizontal)
                    }
                    .zIndex(0)
                    
                                        
                    VStack {
                        Spacer()
                        
                        HStack {
                            HStack {
                                TabIconWithBar(
                                    currentTab: $currentTab,
                                    assignedTab: .timer,
                                    systemIconName: "stopwatch",
                                    systemIconNameSelected: "stopwatch.fill",
                                    namespace: namespace
                                )
                                
//                                Spacer()
                                
                                TabIconWithBar(
                                    currentTab: $currentTab,
                                    assignedTab: .solves,
                                    systemIconName: "hourglass.bottomhalf.filled",
                                    systemIconNameSelected: "hourglass.tophalf.filled",
                                    namespace: namespace
                                )
                                
//                                Spacer()
                                
                                TabIconWithBar(
                                    currentTab: $currentTab,
                                    assignedTab: .stats,
                                    systemIconName: "chart.pie",
                                    systemIconNameSelected: "chart.pie.fill",
                                    namespace: namespace
                                )
                                
                                
//                                Spacer()
                                
                                TabIconWithBar(
                                    currentTab: $currentTab,
                                    assignedTab: .sessions,
                                    systemIconName: "line.3.horizontal.circle",
                                    systemIconNameSelected: "line.3.horizontal.circle.fill",
                                    namespace: namespace
                                )
//                                    .padding(.trailing, 14)
                            }
                            .frame(
                                width: nil,
                                height: CGFloat(SetValues.tabBarHeight),
                                alignment: .leading
                            )
                            .background(Color(UIColor.systemGray4).clipShape(RoundedRectangle(cornerRadius:12)))
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3.5)
//                            .padding(.leading, CGFloat(SetValues.marginLeftRight))
                            .animation(.spring(), value: self.currentTab)
                            
                            Spacer()
                            
                            
                            
                            TabIcon(
                                currentTab: $currentTab,
                                assignedTab: .settings,
                                systemIconName: "gearshape",
                                systemIconNameSelected: "gearshape.fill"
                            )
//                                .padding(.trailing, CGFloat(SetValues.marginLeftRight + 12))
                        }
                        .padding(.horizontal)
                        
                        
                    }
                    .zIndex(1)
                }
                .ignoresSafeArea(.keyboard)                
            }
            .padding(.bottom, SetValues.hasBottomBar ? CGFloat(0) : nil)
            //.transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.25)), removal: .opacity.animation(.easeIn(duration: 0.1))))
            .transition(.move(edge: .bottom).animation(.easeIn(duration: 6)))
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
