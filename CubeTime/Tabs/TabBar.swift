import SwiftUI


struct VHStack<Content: View>: View {
    let vertical: Bool
    let spacing: CGFloat?
    let content: Content

    init(vertical: Bool, spacing: CGFloat? = nil, @ViewBuilder _ content: () -> Content) {
        self.vertical = vertical
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        if vertical {
            VStack(spacing: spacing) {
                content
            }
        } else {
            HStack(spacing: spacing) {
                content
            }
        }
    }
}

struct TabBar: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @EnvironmentObject var tabRouter: TabRouter
    @Environment(\.colorScheme) private var colourScheme
    
    @Binding var currentTab: Tab
    
    var pad = false
    
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill((self.currentTab == .timer
                       ? Color("base")
                       : Color("overlay0")))
            
                .shadow(color: .black.opacity(self.currentTab == .timer ? 0.00 : 0.04),
                        radius: self.currentTab != .timer ? 6 : 0,
                        x: 0,
                        y: self.currentTab != .timer ? 2 : 0)

                .animation(.spring(response: 0.3, dampingFraction: 0.72, blendDuration: 0), value: self.currentTab)
            
            VHStack(vertical: pad) {
                VHStack(vertical: pad) {
                    if !(UIDevice.deviceIsPad && UIDevice.deviceIsLandscape(globalGeometrySize) && padFloatingLayout) {
                        TabIcon(
                            currentTab: $currentTab,
                            assignedTab: .timer,
                            systemIconName: "stopwatch",
                            systemIconNameSelected: "stopwatch.fill",
                            pad: pad,
                            namespace: namespace
                        )
                    }
                                                   
                    TabIcon(
                        currentTab: $currentTab,
                        assignedTab: .solves,
                        systemIconName: "hourglass.bottomhalf.filled",
                        systemIconNameSelected: "hourglass.tophalf.filled",
                        pad: pad,
                        namespace: namespace
                    )
                    
                    TabIcon(
                        currentTab: $currentTab,
                        assignedTab: .stats,
                        systemIconName: "chart.pie",
                        systemIconNameSelected: "chart.pie.fill",
                        pad: pad,
                        namespace: namespace
                    )
                    
                    TabIcon(
                        currentTab: $currentTab,
                        assignedTab: .sessions,
                        systemIconName: "line.3.horizontal.circle",
                        systemIconNameSelected: "line.3.horizontal.circle.fill",
                        pad: pad,
                        namespace: namespace
                    )
                }
                .frame(
                    width: pad ? 50 : nil,
                    height: pad ? nil : 50,
                    alignment: pad ? .top : .leading
                )
                .animation(.spring(response: 0.30, dampingFraction: 0.72, blendDuration: 0), value: self.currentTab)
                .animation(.spring(), value: tabRouter.padExpandState)
                
                Spacer()
                
                TabIcon(
                    currentTab: $currentTab,
                    assignedTab: .settings,
                    systemIconName: "gearshape",
                    systemIconNameSelected: "gearshape.fill",
                    pad: pad,
                    namespace: namespace,
                    hasBar: false
                )
            }
        }
        .padding(pad ? .vertical : .horizontal)
        .ignoresSafeArea(.keyboard)
        .transition(.move(edge: .bottom).animation(.easeIn(duration: 6)))
        .fixedSize(horizontal: pad, vertical: !pad)
    }
}
