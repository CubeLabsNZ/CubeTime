//
//  MainTabsView.swift
//  txmer
//
//  Created by Reagan Bohan on 11/25/21.
//

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
                    Color.black
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



@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct MainTabsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Namespace private var namespace
    
    @StateObject var tabRouter: TabRouter = TabRouter()
    
    @State var hideTabBar = false
    @State var currentSession: Sessions
        
    init(managedObjectContext: NSManagedObjectContext) {
        let lastUsedSessionURI = UserDefaults.standard.url(forKey: "last_used_session")
        if lastUsedSessionURI == nil {
            NSLog("Saved ID is nil, creating default object")
            currentSession = Sessions(context: managedObjectContext) // TODO make it playground
            currentSession.scramble_type = 0
            currentSession.name = "Default Session"
            UserDefaults.standard.set(currentSession.objectID.uriRepresentation(), forKey: "last_used_session")
            try! managedObjectContext.save() // TODO Fix for some reason save is not ok
            NSLog("Successfully created default session with id \(currentSession.objectID)")
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
                    let _ = NSLog("Here")
                    TimerView(stopWatchManager: StopWatchManager(currentSession: $currentSession, managedObjectContext: managedObjectContext), hideTabBar: $hideTabBar)
                        .environment(\.managedObjectContext, managedObjectContext)
                case .solves:
                    TimeListView(currentSession: $currentSession, managedObjectContext: managedObjectContext)
                        .environment(\.managedObjectContext, managedObjectContext)
                case .stats:
                    StatsView(currentSession: $currentSession, managedObjectContext: managedObjectContext)
                case .sessions:
                    SessionsView(currentSession: $currentSession)
                        .environment(\.managedObjectContext, managedObjectContext)
                        .onChange(of: currentSession) { [currentSession] newSession in
                            UserDefaults.standard.set(newSession.objectID.uriRepresentation(), forKey: "last_used_session")
                        }
                case .settings:
//                    SettingsView(hideTabBar: $hideTabBar)
                    SettingsView()
                    
                }

                BottomTabsView(hide: $hideTabBar, currentTab: $tabRouter.currentTab, namespace: namespace)
//                    .offset(y: hideTabBar ? 250 : 0)
                    .zIndex(1)
            }
        }
    }
}
