import SwiftUI
import UIKit
import CoreData
import Combine


@main
struct CubeTime: App {
    @Environment(\.scenePhase) var phase
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Preference(\.overrideDM) private var overrideSystemAppearance
    @Preference(\.dmBool) private var darkMode
    @Preference(\.inspectionAlertFollowsSilent) private var inspectionAlertFollowsSilent
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @AppStorage("onboarding") var showOnboarding: Bool = true
    
    let persistenceController: PersistenceController
    private let moc: NSManagedObjectContext
    
    @StateObject var stopwatchManager: StopwatchManager
    @StateObject var fontManager: FontManager = FontManager()
    @StateObject var tabRouter: TabRouter = TabRouter.shared
    
    @StateObject var gradientManager = GradientManager()
    
    #warning("todo separate this into a viewmodel this is disgusting")
    @State var showUpdates: Bool = false
    @State var pageIndex: Int = 0
    
    init() {
        UIApplication.shared.isIdleTimerDisabled = true
        
        persistenceController = PersistenceController.shared
        let moc = persistenceController.container.viewContext
        moc.automaticallyMergesChangesFromParent = true
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        
        // https://swiftui-lab.com/random-lessons/#data-10
        self._stopwatchManager = StateObject(wrappedValue: StopwatchManager(currentSession: nil, managedObjectContext: moc))
        
        
        self.moc = moc
        
        
        // check for update
        let newVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        let currentVersion = UserDefaults.standard.string(forKey: "currentVersion")
        
//        self._showUpdates = State(initialValue: currentVersion != newVersion && !showOnboarding)
        self._showUpdates = State(initialValue: currentVersion != newVersion)
        UserDefaults.standard.set(newVersion, forKey: "currentVersion")
        
        
        setupNavbarAppearance()
//        setupNavTitleAppearance() for future possibly, but doesn't look great ..
        setupColourScheme(overrideSystemAppearance ? (darkMode ? .dark : .light) : nil)
        
        setupAudioSession(with: inspectionAlertFollowsSilent ? .ambient : .playback)
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(overrideSystemAppearance ? (darkMode ? .dark : .light) : nil)
                .tint(Color("accent"))
                .accentColor(Color("accent"))
                .sheet(isPresented: $showUpdates, onDismiss: { showUpdates = false }) {
                    Updates(showUpdates: $showUpdates)
                        .tint(Color("accent"))
                }
#if false
                .sheet(isPresented: $showOnboarding, onDismiss: {
                    pageIndex = 0
                }) {
                    OnboardingView(showOnboarding: showOnboarding, pageIndex: $pageIndex)
                        .tint(Color("accent"))
                }
#endif
            
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
                .environmentObject(gradientManager)
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
                    stopwatchManager.currentSession = try! moc.existingObject(with: objID) as! Session
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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var stopwatchManager: StopwatchManager
        
    var body: some View {
        GeometryReader { geo in
            Group {
                if horizontalSizeClass == .compact {
                    ZStack {
                        BackgroundColour()
                            .ignoresSafeArea()
                        
                        switch tabRouter.currentTab {
                        case .timer:
                            TimerView()
//                            TimeTrendDetail()
                                .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
                                .environmentObject(stopwatchManager.timerController)
                                .environmentObject(stopwatchManager.scrambleController)
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
                        .environmentObject(stopwatchManager.scrambleController)
                }
            }
            .environment(\.globalGeometrySize, geo.size)
            .environmentObject(tabRouter)
        }
    }
}
