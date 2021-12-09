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
    
    @Published var currentSettingsCard: SettingsCard?
    @Published var showDetail: Bool = false
    
}

struct TabIconWithBar: View {
    let assignedTab: Tab
    @Binding var currentTab: Tab
    let systemIconName: String
    var systemIconNameSelected: String
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                //                                            CustomGradientColours.gradientColour
                
                if currentTab == assignedTab {
                    Color.black
                        .frame(width: 32, height: 2)
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                        .offset(x: 7, y: -48)
                    //                                                .padding(.leading, 14)
                } else {
                    Color.clear
                        .frame(width: 32, height: 2)
                        .offset(x: 7, y: -48)
                }
            }
            
            
            
            Image(
                systemName:
                    currentTab == assignedTab ? systemIconNameSelected : systemIconName
            )
            .font(.system(size: SetValues.iconFontSize))
            .onTapGesture {
                currentTab = assignedTab
            }
                .padding(.leading, 14)
                
        }
    }
}


struct TabIcon: View {
    let assignedTab: Tab
    @Binding var currentTab: Tab
    let systemIconName: String
    var systemIconNameSelected: String
    var body: some View {
        Image(
            systemName:
                currentTab == assignedTab ? systemIconNameSelected : systemIconName
        )
            .font(.system(size: SetValues.iconFontSize))
            .onTapGesture {
                currentTab = assignedTab
            }
    }
}



@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct MainTabsView: View {
    
    @Namespace private var namespace
    @Namespace var animation
    
    
    @StateObject var tabRouter: TabRouter = TabRouter()
    @Environment(\.managedObjectContext) var managedObjectContext
    
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
                    SettingsView(tabRouter: tabRouter, animation: animation)
                    
                }

                BottomTabsView(hide: $hideTabBar, currentTab: $tabRouter.currentTab, namespace: namespace)
                    .zIndex(1)
            }
        }
    }
}
/*
@available(iOS 15.0, *) /// TODO: remove all `@available(iOS 15.0, *)` in the project and change the button role BECAUSE iOS 15 + ONLY :sob:
struct MainTabsView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabsView(tabRouter: TabRouter())
    }
}
*/
