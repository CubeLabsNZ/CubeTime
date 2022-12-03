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
    
    @StateObject var stopWatchManager: StopWatchManager
    @StateObject var tabRouter: TabRouter = TabRouter()
    
    @State var showUpdates: Bool = false
    @State var pageIndex: Int = 0
    
    
    init() {
        persistenceController = PersistenceController.shared
        let moc = persistenceController.container.viewContext
        
        #warning("TODO: move to WM")
        UIApplication.shared.isIdleTimerDisabled = true
        
        #warning("TODO: move to SWM init")
        
        let userDefaults = UserDefaults.standard
        
        let lastUsedSessionURI = userDefaults.url(forKey: "last_used_session")
        let fetchedSession: Sessions
        
        if lastUsedSessionURI == nil {
            fetchedSession = Sessions(context: moc)
            fetchedSession.scramble_type = 1
            fetchedSession.session_type = SessionTypes.playground.rawValue
            fetchedSession.name = "Default Session"
            try! moc.save()
            userDefaults.set(fetchedSession.objectID.uriRepresentation(), forKey: "last_used_session")
        } else {
            let objID = moc.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: lastUsedSessionURI!)!
            fetchedSession = try! moc.existingObject(with: objID) as! Sessions; #warning("TODO: better error handling")
        }
        
        // https://swiftui-lab.com/random-lessons/#data-10
        self._stopWatchManager = StateObject(wrappedValue: StopWatchManager(currentSession: fetchedSession, managedObjectContext: moc))
        
        
        self.moc = moc
        
        
        // check for update
        let newVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        let currentVersion = UserDefaults.standard.string(forKey: "currentVersion")
        
        self._showUpdates = State(initialValue: currentVersion != newVersion && !showOnboarding)
        UserDefaults.standard.set(newVersion, forKey: "currentVersion")
        
        userDefaults.register(
            defaults: [
                // timer settings
                gsKeys.inspection.rawValue: false,
                gsKeys.inspectionCountsDown.rawValue: false,
                gsKeys.showCancelInspection.rawValue: true,
                gsKeys.inspectionAlert.rawValue: true,
                gsKeys.inspectionAlertType.rawValue: 0,
                
                gsKeys.freeze.rawValue: 0.5,
                gsKeys.timeDpWhenRunning.rawValue: 3,
                gsKeys.showSessionName.rawValue: false,
                
                // timer tools
                gsKeys.showScramble.rawValue: true,
                gsKeys.showStats.rawValue: true,
                
                // accessibility
                gsKeys.hapBool.rawValue: true,
                gsKeys.hapType.rawValue: UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue,
                gsKeys.forceAppZoom.rawValue: false,
                gsKeys.appZoom.rawValue: 3,
                gsKeys.scrambleSize.rawValue: 18,
                gsKeys.gestureDistance.rawValue: 50,
                
                // show previous time afte solve deleted
                gsKeys.showPrevTime.rawValue: false,
                
                // statistics
                gsKeys.displayDP.rawValue: 3,
                
                // colours
                asKeys.graphGlow.rawValue: true,
            ]
        )
    }
    
    
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .sheet(isPresented: $showUpdates, onDismiss: { showUpdates = false }) {
                    let _ = NSLog("SDHFLKDF")
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
                .environmentObject(stopWatchManager)
                .environmentObject(tabRouter)
//                .onAppear {
//                    self.deviceManager.deviceOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
//                }
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
    @StateObject var tabRouter: TabRouter = TabRouter()
        
    var body: some View {
        GeometryReader { geo in
            if UIDevice.deviceIsPad && UIDevice.deviceIsLandscape(geo.size) {
                TimerView()
                    .environment(\.globalGeometrySize, geo.size)
                    .environmentObject(tabRouter)
            } else {
                MainTabsView()
                    .environment(\.globalGeometrySize, geo.size)
                    .environmentObject(tabRouter)
            }
        }
    }
}
