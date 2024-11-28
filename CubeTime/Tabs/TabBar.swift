import SwiftUI
import CoreData

enum Tab {
    case timer
    case solves
    case stats
    case sessions
    case settings
}

class TabRouter: ObservableObject {
    static let shared = TabRouter()
    
    var pendingSessionURL: NSString?
    @Published var currentTab: Tab = .timer {
        didSet {
            if currentTab == .timer {
                padExpandState = 0
            }
        }
    }
    @Published var hideTabBar: Bool = false
    @Published var padExpandState: Int = 0 {
        didSet {
            if padExpandState == 1 && currentTab == .timer {
                currentTab = .solves
            }
        }
    }
}


struct TabBar: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @EnvironmentObject var tabRouter: TabRouter
    @Environment(\.colorScheme) private var colourScheme
    
    @Binding var currentTab: Tab
    
    @State var littleGuyCanJumpToSettings = false
    
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            TabIcon(
                currentTab: $currentTab,
                assignedTab: .timer,
                systemIconName: "stopwatch",
                systemIconNameSelected: "stopwatch.fill",
                namespace: namespace
            )
            
            Spacer(minLength: 0)
                .frame(maxWidth: 10)
            
            TabIcon(
                currentTab: $currentTab,
                assignedTab: .solves,
                systemIconName: "hourglass.bottomhalf.filled",
                systemIconNameSelected: "hourglass.tophalf.filled",
                namespace: namespace
            )
            
            Spacer(minLength: 0)
                .frame(maxWidth: 10)
            
            TabIcon(
                currentTab: $currentTab,
                assignedTab: .stats,
                systemIconName: "chart.pie",
                systemIconNameSelected: "chart.pie.fill",
                namespace: namespace
            )
            
            Spacer(minLength: 0)
                .frame(maxWidth: 10)
            
            TabIcon(
                currentTab: $currentTab,
                assignedTab: .sessions,
                systemIconName: "line.3.horizontal.circle",
                systemIconNameSelected: "line.3.horizontal.circle.fill",
                namespace: namespace
            )
            
            GeometryReader { geo in
                EmptyView()
                    .onChange(of: geo.size, perform: { newSize in
                        littleGuyCanJumpToSettings = newSize.width < 10
                    })
            }
            
            TabIcon(
                currentTab: $currentTab,
                assignedTab: .settings,
                systemIconName: "gearshape",
                systemIconNameSelected: "gearshape.fill",
                namespace: namespace,
                hasLittleGuy: littleGuyCanJumpToSettings
            )
        }
        .frame(height: 50)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill((self.currentTab == .timer
                       ? Color("base")
                       : colourScheme == .light ? Color("overlay0") : Color(hex: 0x303032)))
            
                .shadow(color: .black.opacity(self.currentTab == .timer ? 0.00 : 0.10),
                        radius: self.currentTab != .timer ? 8 : 0,
                        x: 0,
                        y: self.currentTab != .timer ? 1 : 0)
        }
        .animation(Animation.customFastSpring, value: self.currentTab)
        .animation(.spring(), value: tabRouter.padExpandState)
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard)
        .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: 0.10)), removal: .identity))
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
    let hasLittleGuy: Bool
    
    @Preference(\.isStaticGradient) private var isStaticGradient
    @EnvironmentObject var gradientManager: GradientManager

    init(currentTab: Binding<Tab>, assignedTab: Tab, systemIconName: String, systemIconNameSelected: String, namespace: Namespace.ID, hasLittleGuy: Bool = true) {
        self._currentTab = currentTab
        self.assignedTab = assignedTab
        self.systemIconName = systemIconName
        self.systemIconNameSelected = systemIconNameSelected
        self.namespace = namespace
        self.hasLittleGuy = hasLittleGuy
    }
    
    
    var body: some View {
        ZStack {
            if (hasLittleGuy && currentTab == assignedTab) {
                Capsule()
                    .fill(currentTab == .timer ? AnyShapeStyle(GradientManager.getGradient(gradientSelected: gradientManager.appGradient, isStaticGradient: isStaticGradient).opacity(0.8)) : AnyShapeStyle(Color("dark")))
                    .matchedGeometryEffect(id: "littleguy", in: namespace, properties: .frame)
                    .shadow(color: currentTab == .timer
                            ? Color("accent2")
                            : colourScheme == .dark
                              ? Color.clear
                              : Color("indent0"),
                            radius: 3,
                            x: 0, y: 0)
                    .frame(width: 32, height: 2.25)
                    .offset(y: 47.75 - 48/2)
            }
            
            Image(systemName: currentTab == assignedTab ? systemIconNameSelected : systemIconName)
                .font(.system(size: assignedTab == .solves ? 24 : 23, weight: .medium))
                .padding(.horizontal, 15)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                
                .onTapGesture {
                    if currentTab != assignedTab {
                        currentTab = assignedTab
                    }
                }
            
                .onLongPressGesture {
                    if currentTab != assignedTab {
                        currentTab = assignedTab
                    }
                }
            
                .frame(height: 48)
        }
    }
}
