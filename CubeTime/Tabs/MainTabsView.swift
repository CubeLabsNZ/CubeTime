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


struct MainTabsView: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    var body: some View {
        let timerController = stopwatchManager.timerController
        VStack {
            ZStack {
                switch tabRouter.currentTab {
                case .timer:
                    TimerView()
                        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                        .environmentObject(stopwatchManager.timerController)
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
                        .padding(.bottom, 0)
                        .ignoresSafeArea(.keyboard)
                }
            }
        }
    }
}
