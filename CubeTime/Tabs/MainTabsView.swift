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
    @Published var currentTab: Tab = .solves
    @Published var hideTabBar: Bool = false
}

struct TabIconWithBar: View {
    @Binding var currentTab: Tab
    let assignedTab: Tab
    let systemIconName: String
    var systemIconNameSelected: String
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                if currentTab == assignedTab {
                    Color.primary
                        .frame(width: 32, height: 2)
                        .clipShape(Capsule())
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                        .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)
                        .offset(y: -48)
                    //                                                .padding(.leading, 14)
                } else {
                    Color.clear
                        .frame(width: 32, height: 2)
                        .offset(y: -48)
                }
            }
            
            TabIcon(currentTab: $currentTab, assignedTab: assignedTab, systemIconName: systemIconName, systemIconNameSelected: systemIconNameSelected)
        }
    }
}


struct TabIcon: View {
    @Binding var currentTab: Tab
    let assignedTab: Tab
    let systemIconName: String
    var systemIconNameSelected: String
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
    
    
    @Namespace private var namespace
    
    
    @AppStorage(asKeys.overrideDM.rawValue) private var overrideSystemAppearance: Bool = false
    @AppStorage(asKeys.dmBool.rawValue) private var darkMode: Bool = false
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    var body: some View {
        VStack {
            ZStack {
                switch tabRouter.currentTab {
                case .timer:
                    if !(UIDevice.deviceIsPad && (globalGeometrySize.width > globalGeometrySize.height)) {
                        TimerView()
                            .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                    }
                case .solves:
                    TimeListView()
                case .stats:
                    StatsView()
                case .sessions:
                    SessionsView()
                case .settings:
                    SettingsView()
                }
                
                BottomTabsView(hide: $tabRouter.hideTabBar, currentTab: $tabRouter.currentTab, namespace: namespace)
                    .zIndex(1)
                    .ignoresSafeArea(.keyboard)
                    .if(UIDevice.deviceIsPad && (globalGeometrySize.width > globalGeometrySize.height)) { view in
                        view.padding(.bottom)
                    }
            }
        }
        .preferredColorScheme(overrideSystemAppearance ? (darkMode ? .dark : .light) : nil)
        .tint(accentColour)
    }
}
