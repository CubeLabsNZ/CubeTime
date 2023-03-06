import SwiftUI
import UIKit
import CoreData


@main
struct CubeTime: App {
    @Environment(\.scenePhase) var phase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /*
    var shortcutItem: UIApplicationShortcutItem?
     */
    
    @AppStorage("onboarding") var showOnboarding: Bool = true
    
    let persistenceController: PersistenceController
    private let moc: NSManagedObjectContext
    
    @StateObject var stopwatchManager: StopwatchManager
    @StateObject var fontManager: FontManager = FontManager()
    @StateObject var tabRouter: TabRouter = TabRouter.shared
    
    @State var showUpdates: Bool = false
    @State var pageIndex: Int = 0
    
    
    init() {
        persistenceController = PersistenceController.shared
        let moc = persistenceController.container.viewContext
        
        #warning("TODO: move to WM")
        UIApplication.shared.isIdleTimerDisabled = true
        

        let userDefaults = UserDefaults.standard
        
        // https://swiftui-lab.com/random-lessons/#data-10
        self._stopwatchManager = StateObject(wrappedValue: StopwatchManager(currentSession: nil, managedObjectContext: moc))
        
        
        self.moc = moc
        
        
        // check for update
        let newVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        let currentVersion = UserDefaults.standard.string(forKey: "currentVersion")
        
        self._showUpdates = State(initialValue: currentVersion != newVersion && !showOnboarding)
        UserDefaults.standard.set(newVersion, forKey: "currentVersion")
        
        userDefaults.register(
            defaults: [
                // timer settings
                generalSettingsKey.inspection.rawValue: false,
                generalSettingsKey.inspectionCountsDown.rawValue: false,
                generalSettingsKey.showCancelInspection.rawValue: true,
                generalSettingsKey.inspectionAlert.rawValue: true,
                generalSettingsKey.inspectionAlertType.rawValue: 0,
                
                generalSettingsKey.freeze.rawValue: 0.5,
                generalSettingsKey.timeDpWhenRunning.rawValue: 3,
                generalSettingsKey.showSessionName.rawValue: false,
                
                // timer tools
                generalSettingsKey.showScramble.rawValue: true,
                generalSettingsKey.showStats.rawValue: true,
                
                // accessibility
                generalSettingsKey.hapBool.rawValue: true,
                generalSettingsKey.hapType.rawValue: UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue,
                generalSettingsKey.forceAppZoom.rawValue: false,
                generalSettingsKey.appZoom.rawValue: 3,
                generalSettingsKey.gestureDistance.rawValue: 50,
                
                // show previous time afte solve deleted
                generalSettingsKey.showPrevTime.rawValue: false,
                
                // statistics
                generalSettingsKey.displayDP.rawValue: 3,
                
                // colours
                appearanceSettingsKey.graphGlow.rawValue: true,
                
                appearanceSettingsKey.scrambleSize.rawValue: 18,
                appearanceSettingsKey.fontWeight.rawValue: 516.0,
                appearanceSettingsKey.fontCasual.rawValue: 0.0,
            ]
        )
        
        setNavBarAppearance()
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .sheet(isPresented: $showUpdates, onDismiss: { showUpdates = false }) {
                    Updates(showUpdates: $showUpdates)
                }
                .sheet(isPresented: $showOnboarding, onDismiss: {
                    pageIndex = 0
                }) {
                    OnboardingView(showOnboarding: showOnboarding, pageIndex: $pageIndex)
                }
                .if(dynamicTypeSize != DynamicTypeSize.large) { view in
                    view
                        .alert(isPresented: $showUpdates) {
                            Alert(title: Text("DynamicType Detected"), message: Text("CubeTime only supports standard DyanmicType sizes. Accessibility DynamicType modes are currently not supported, so layouts may not be rendered correctly."), dismissButton: .default(Text("Got it!")))
                        }
                }
                .environment(\.managedObjectContext, moc)
                .environmentObject(stopwatchManager)
                .environmentObject(fontManager)
                .environmentObject(tabRouter)
//                .onAppear {
//                    self.deviceManager.deviceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
//                }
        }
        .onChange(of: phase) { newValue in
            switch(newValue) {
            case .background:
                stopwatchManager.addSessionQuickActions()
                break
            case .active:
                if let pendingSession = tabRouter.pendingSessionURL {
                    let url = URL(string: pendingSession as String)
                    let objID = moc.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url!)!
                    stopwatchManager.currentSession = try! moc.existingObject(with: objID) as! Sessions
                    tabRouter.pendingSessionURL = nil
                }
            default: break
            }
        }
    }
}


private struct GlobalGeometrySize: EnvironmentKey {
    static let defaultValue: CGSize = UIScreen.main.bounds.size
}

extension EnvironmentValues {
    var globalGeometrySize: CGSize {
        get {
            self[GlobalGeometrySize.self]
            
        }
        set {
            self[GlobalGeometrySize.self] = newValue
            
        }
    }
}

struct MainView: View {
    @StateObject var tabRouter: TabRouter = TabRouter.shared
    
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @AppStorage(appearanceSettingsKey.overrideDM.rawValue) private var overrideSystemAppearance: Bool = false
    @AppStorage(appearanceSettingsKey.dmBool.rawValue) private var darkMode: Bool = false

        
    var body: some View {
        GeometryReader { geo in
            Group {
                if horizontalSizeClass == .compact {
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
                } else {
                    TimerView()
                        .environmentObject(stopwatchManager.timerController)
                }
            }
            .tint(Color.accentColor)
            .preferredColorScheme(overrideSystemAppearance ? (darkMode ? .dark : .light) : nil)
            .environment(\.globalGeometrySize, geo.size)
            .environmentObject(tabRouter)
        }
    }
}
