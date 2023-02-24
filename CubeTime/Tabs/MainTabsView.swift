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

struct TabIcon: View {
    @Binding var currentTab: Tab
    let assignedTab: Tab
    let systemIconName: String
    let systemIconNameSelected: String
    let pad: Bool
    var namespace: Namespace.ID
    let hasBar: Bool
    
    init(currentTab: Binding<Tab>, assignedTab: Tab, systemIconName: String, systemIconNameSelected: String, pad: Bool, namespace: Namespace.ID, hasBar: Bool = true) {
        self._currentTab = currentTab
        self.assignedTab = assignedTab
        self.systemIconName = systemIconName
        self.systemIconNameSelected = systemIconNameSelected
        self.pad = pad
        self.namespace = namespace
        self.hasBar = hasBar
    }
    
    var body: some View {
        ZStack {
            if (hasBar) {
                VHStack(vertical: !pad) {
                    if currentTab == assignedTab {
                        Color.Theme.accent2
                            .frame(width: 32, height: 2)
                            .clipShape(Capsule())
                            .matchedGeometryEffect(id: "littleguy", in: namespace, properties: .frame)
                            .shadow(color: Color.Theme.accent4, radius: 2, x: 0, y: 0.5)
                            .offset(y: 48)
                    } else {
                        Color.clear
                            .frame(width: 32, height: 2)
                            .offset(y: 48)
                    }
                    
                    Spacer()
                }
            }
            
            Image(systemName: currentTab == assignedTab ? systemIconNameSelected : systemIconName)
                .font(.system(size: 22, weight: .medium))
                .padding(.horizontal, 14)
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


struct MainTabsView: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @EnvironmentObject var tabRouter: TabRouter
    
    var body: some View {
        VStack {
            ZStack {
                switch tabRouter.currentTab {
                case .timer:
                    TimerView()
                        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                case .solves:
                    TimeListView()
                case .stats:
                    StatsView()
                case .sessions:
                    SessionsView()
                case .settings:
                    SettingsView()
                }
                
                
                if !tabRouter.hideTabBar {
                    TabBar(currentTab: $tabRouter.currentTab)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, UIDevice.hasBottomBar ? CGFloat(0) : nil)
                        .padding(.bottom, UIDevice.deviceIsPad && UIDevice.deviceIsLandscape(globalGeometrySize) ? nil : 0)
                        .ignoresSafeArea(.keyboard)
                }
            }
        }
    }
}
