import SwiftUI
import Combine


struct BottomTabsView: View {
    @Binding var hide: Bool
    @Binding var currentTab: Tab
    @Environment(\.horizontalSizeClass) var hSizeClass
    var largePad = false
    
    var namespace: Namespace.ID
    
    var body: some View {
        if !hide {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(uiColor: .systemGray5))
                        
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
                                
                                if !largePad {
                                    TabIconWithBar(
                                        currentTab: $currentTab,
                                        assignedTab: .timer,
                                        systemIconName: "stopwatch",
                                        systemIconNameSelected: "stopwatch.fill",
                                        namespace: namespace
                                    )
                                }
                                                                    
                                TabIconWithBar(
                                    currentTab: $currentTab,
                                    assignedTab: .solves,
                                    systemIconName: "hourglass.bottomhalf.filled",
                                    systemIconNameSelected: "hourglass.tophalf.filled",
                                    namespace: namespace
                                )
                                
                                TabIconWithBar(
                                    currentTab: $currentTab,
                                    assignedTab: .stats,
                                    systemIconName: "chart.pie",
                                    systemIconNameSelected: "chart.pie.fill",
                                    namespace: namespace
                                )
                                
                                TabIconWithBar(
                                    currentTab: $currentTab,
                                    assignedTab: .sessions,
                                    systemIconName: "line.3.horizontal.circle",
                                    systemIconNameSelected: "line.3.horizontal.circle.fill",
                                    namespace: namespace
                                )
                            }
                            .frame(
                                width: nil,
                                height: CGFloat(SetValues.tabBarHeight),
                                alignment: .leading
                            )
                            .background(Color(uiColor: .systemGray4).clipShape(RoundedRectangle(cornerRadius:12)))
                            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 3.5)
                            .animation(.spring(), value: self.currentTab)
                            
                            Spacer()
                            
                            
                            
                            TabIcon(
                                currentTab: $currentTab,
                                assignedTab: .settings,
                                systemIconName: "gearshape",
                                systemIconNameSelected: "gearshape.fill"
                            )
                        }
                        .padding(.horizontal)
                    }
                    .zIndex(1)
                }
                .ignoresSafeArea(.keyboard)
            }
            .padding(.bottom, SetValues.hasBottomBar ? CGFloat(0) : nil)
            .transition(.move(edge: .bottom).animation(.easeIn(duration: 6)))
        }

    }
}
