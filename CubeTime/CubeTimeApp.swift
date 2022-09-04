import SwiftUI
import UIKit
import CoreData


@main
struct CubeTime: App {
    @Environment(\.scenePhase) var phase
    
    
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
        
        // TODO move to WM
        UIApplication.shared.isIdleTimerDisabled = true
        
        // TODO move to SWM init
        
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
            fetchedSession = try! moc.existingObject(with: objID) as! Sessions // TODO better error handling
        }
        
        // https://swiftui-lab.com/random-lessons/#data-10
        self._stopWatchManager = StateObject(wrappedValue: StopWatchManager(currentSession: fetchedSession, managedObjectContext: moc))
        
        self.moc = moc
        
        let newVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
    
        let currentVersion = userDefaults.string(forKey: "currentVersion")
        
        if currentVersion == newVersion {
            print("same")
        } else {
            if !showOnboarding {
                showUpdates = true
            }
            userDefaults.set(newVersion, forKey: "currentVersion")
        }
                
        userDefaults.register(
            defaults: [
                // timer settings
                gsKeys.inspection.rawValue: false,
                gsKeys.inspectionCountsDown.rawValue: false,
                gsKeys.freeze.rawValue: 0.5,
                gsKeys.timeDpWhenRunning.rawValue: 3,
                
                // timer tools
                gsKeys.showScramble.rawValue: true,
                gsKeys.showStats.rawValue: true,
                
                // accessibility
                gsKeys.hapBool.rawValue: true,
                gsKeys.hapType.rawValue: UIImpactFeedbackGenerator.FeedbackStyle.rigid.rawValue,
                gsKeys.scrambleSize.rawValue: 18,
                gsKeys.gestureDistance.rawValue: 50,
                
                // statistics
                gsKeys.displayDP.rawValue: 3,
                
                // colours
                asKeys.graphGlow.rawValue: true
            ]
        )
    }
    
    var body: some Scene {
        
        WindowGroup {
            VStack {
                // This is a Scene not a View so there is no size class
                MainView()
            }
            .sheet(isPresented: $showUpdates, onDismiss: { showUpdates = false }) {
                Updates(showUpdates: $showUpdates)
            }
            .sheet(isPresented: $showOnboarding, onDismiss: {
                pageIndex = 0
                if false { /// FIX IN FUTURE: check for first time register and not just == 18 because can break :sob:
                    if UserDefaults.standard.integer(forKey: gsKeys.scrambleSize.rawValue) == 18 {
                        UserDefaults.standard.set(24, forKey: gsKeys.scrambleSize.rawValue)
                    }
                }
            }) {
                OnboardingView(showOnboarding: showOnboarding, pageIndex: $pageIndex)
            }
            .environment(\.managedObjectContext, moc)
            .environmentObject(stopWatchManager)
            .environmentObject(tabRouter)
        }

    }
}


struct MainView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            TimerView(largePad: true)
        } else {
            MainTabsView()
        }
    }
}
