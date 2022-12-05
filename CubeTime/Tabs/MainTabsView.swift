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

struct TabIconWithBar: View {
    @Binding var currentTab: Tab
    let assignedTab: Tab
    let systemIconName: String
    let systemIconNameSelected: String
    let pad: Bool
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            VHStack(vertical: !pad) {
                Spacer()
                if currentTab == assignedTab {
                    Color.primary
                        .frame(width: 32, height: 2)
                        .clipShape(Capsule())
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                        .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)
                        .offset(y: -48)
                } else {
                    Color.clear
                        .frame(width: 32, height: 2)
                        .offset(y: -48)
                }
            }
            
            TabIcon(currentTab: $currentTab, assignedTab: assignedTab, systemIconName: systemIconName, systemIconNameSelected: systemIconNameSelected, pad: pad)
        }
    }
}


struct TabIcon: View {
    @Binding var currentTab: Tab
    let assignedTab: Tab
    let systemIconName: String
    let systemIconNameSelected: String
    let pad: Bool
    var body: some View {
        Image(
            systemName:
                currentTab == assignedTab ? systemIconNameSelected : systemIconName
        )
            .font(.system(size: 22))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                if currentTab != assignedTab {
                    currentTab = assignedTab
                }
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
                    BottomTabsView(currentTab: $tabRouter.currentTab)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, UIDevice.hasBottomBar ? CGFloat(0) : nil)
                        .padding(.bottom, UIDevice.deviceIsPad && UIDevice.deviceIsLandscape(globalGeometrySize) ? nil : 0)
                }
            }
        }
    }
}
