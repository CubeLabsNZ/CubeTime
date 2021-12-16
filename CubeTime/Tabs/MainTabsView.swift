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
    @Published var currentTab: Tab = .timer
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
            
            Image(systemName: currentTab == assignedTab ? systemIconNameSelected : systemIconName)
            .font(.system(size: SetValues.iconFontSize))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                currentTab = assignedTab
            }
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
            .font(.system(size: SetValues.iconFontSize))
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                currentTab = assignedTab
            }
    }
}



struct MainTabsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Namespace private var namespace
    
    @StateObject var tabRouter: TabRouter = TabRouter()
    
    @State var hideTabBar = false
    @State var currentSession: Sessions
    
    @AppStorage(asKeys.overrideDM.rawValue) private var overrideSystemAppearance: Bool = false
    @AppStorage(asKeys.dmBool.rawValue) private var darkMode: Bool = false
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
        
    init(managedObjectContext: NSManagedObjectContext) {
        let lastUsedSessionURI = UserDefaults.standard.url(forKey: "last_used_session")
                
        if lastUsedSessionURI == nil {
            NSLog("Saved ID is nil, creating default object")
            currentSession = Sessions(context: managedObjectContext) // TODO make it playground
            currentSession.scramble_type = 0
            currentSession.name = "Default Session"
            try! managedObjectContext.save() // TODO Fix for some reason save is not ok !!! still present
            UserDefaults.standard.set(currentSession.objectID.uriRepresentation(), forKey: "last_used_session")
        } else {
            let objID = managedObjectContext.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: lastUsedSessionURI!)!
            currentSession = try! managedObjectContext.existingObject(with: objID) as! Sessions // TODO better error handling
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                switch tabRouter.currentTab {
                case .timer:
                    TimerView(currentSession: $currentSession, stopWatchManager: StopWatchManager(currentSession: $currentSession, managedObjectContext: managedObjectContext), hideTabBar: $hideTabBar)
                        .environment(\.managedObjectContext, managedObjectContext)
                case .solves:
                    TimeListView(currentSession: $currentSession, managedObjectContext: managedObjectContext)
                        .environment(\.managedObjectContext, managedObjectContext)
                case .stats:
                    StatsView(currentSession: $currentSession, managedObjectContext: managedObjectContext)
//                    StatsDetail()
                case .sessions:
                    SessionsView(currentSession: $currentSession)
                        .environment(\.managedObjectContext, managedObjectContext)
                        .onChange(of: currentSession) { [currentSession] newSession in
                            UserDefaults.standard.set(newSession.objectID.uriRepresentation(), forKey: "last_used_session") // TODO what was i thinking move this logic into SessionsView
                        }
                case .settings:
                    SettingsView()
                }

                BottomTabsView(hide: $hideTabBar, currentTab: $tabRouter.currentTab, namespace: namespace)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(overrideSystemAppearance ? (darkMode ? .dark : .light) : nil)
        .tint(accentColour)
    }
}
