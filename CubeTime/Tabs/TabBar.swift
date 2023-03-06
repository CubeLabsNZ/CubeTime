import SwiftUI


struct TabBar: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @EnvironmentObject var tabRouter: TabRouter
    @Environment(\.colorScheme) private var colourScheme
    
    @Binding var currentTab: Tab
    
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill((self.currentTab == .timer
                       ? Color("base")
                       : colourScheme == .light ? Color("overlay0") : Color(0x303032)))
            
                .shadow(color: .black.opacity(self.currentTab == .timer ? 0.00 : 0.10),
                        radius: self.currentTab != .timer ? 8 : 0,
                        x: 0,
                        y: self.currentTab != .timer ? 1 : 0)

                .animation(Animation.customFastSpring, value: self.currentTab)
            
            HStack {
                HStack {
                    TabIcon(
                        currentTab: $currentTab,
                        assignedTab: .timer,
                        systemIconName: "stopwatch",
                        systemIconNameSelected: "stopwatch.fill",
                        namespace: namespace
                    )
                                                   
                    TabIcon(
                        currentTab: $currentTab,
                        assignedTab: .solves,
                        systemIconName: "hourglass.bottomhalf.filled",
                        systemIconNameSelected: "hourglass.tophalf.filled",
                        namespace: namespace
                    )
                    
                    TabIcon(
                        currentTab: $currentTab,
                        assignedTab: .stats,
                        systemIconName: "chart.pie",
                        systemIconNameSelected: "chart.pie.fill",
                        namespace: namespace
                    )
                    
                    TabIcon(
                        currentTab: $currentTab,
                        assignedTab: .sessions,
                        systemIconName: "line.3.horizontal.circle",
                        systemIconNameSelected: "line.3.horizontal.circle.fill",
                        namespace: namespace
                    )
                }
                .frame(
                    height: 50,
                    alignment: .leading
                )
                .animation(Animation.customFastSpring, value: self.currentTab)
                .animation(.spring(), value: tabRouter.padExpandState)
                
                Spacer()
                
                TabIcon(
                    currentTab: $currentTab,
                    assignedTab: .settings,
                    systemIconName: "gearshape",
                    systemIconNameSelected: "gearshape.fill",
                    namespace: namespace,
                    hasBar: false
                )
            }
        }
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard)
        .transition(.move(edge: .bottom).animation(.easeIn(duration: 6)))
        .fixedSize(horizontal: false, vertical: true)
    }
}


struct TabIcon: View {
    @Environment(\.colorScheme) private var colourScheme
    @Binding var currentTab: Tab
    let assignedTab: Tab
    let systemIconName: String
    let systemIconNameSelected: String
    var namespace: Namespace.ID
    let hasBar: Bool
    
    init(currentTab: Binding<Tab>, assignedTab: Tab, systemIconName: String, systemIconNameSelected: String, namespace: Namespace.ID, hasBar: Bool = true) {
        self._currentTab = currentTab
        self.assignedTab = assignedTab
        self.systemIconName = systemIconName
        self.systemIconNameSelected = systemIconNameSelected
        self.namespace = namespace
        self.hasBar = hasBar
    }
    
    var body: some View {
        ZStack {
            if (hasBar) {
                VStack() {
                    Group {
                        if (currentTab == assignedTab) {
                            Capsule()
                                .fill(currentTab == .timer
                                      ? colourScheme == .dark
                                        ? Color.accentColor
                                        : Color("accent2")
                                      : Color("dark"))
                                .matchedGeometryEffect(id: "littleguy", in: namespace, properties: .frame)
                                .shadow(color: currentTab == .timer
                                        ? Color("accent3")
                                        : colourScheme == .dark
                                          ? Color.clear
                                          : Color("indent0"),
                                        radius: 2,
                                        x: 0, y: 0.5)
                            
                        } else {
                            Capsule()
                                .fill(Color.clear)
                        }
                    }
                    .frame(width: 32, height: 2.25)
                    .offset(y: 47.75)
                    
                    Spacer()
                }
            }
            
            Image(systemName: currentTab == assignedTab ? systemIconNameSelected : systemIconName)
                .font(.system(size: 23, weight: .medium))
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                
                .onTapGesture {
                    if currentTab != assignedTab {
                        currentTab = assignedTab
                    }
                }
                .frame(height: 48)
        }
    }
}
