//
//  TimeListView.swift
//  txmer
//
//  Created by Tim Xie on 24/11/21.
//

import Foundation
import SwiftUI
import CoreData

/*
enum buttonMode {
    case isAscending
    case isDescending
}
 */

enum SortBy {
    case date
    case time
}

class TimeListManager: ObservableObject {
    @Published var solves: [Solves]?
    private var allsolves: [Solves]?
    @Published var fetchError: NSError?
    @Binding var currentSession: Sessions
    let managedObjectContext: NSManagedObjectContext
    @Published var sortBy: Int = 0 {
        didSet {
            self.resort()
        }
    }
    @Published var filter: String = "" {
        didSet {
            self.refilter()
        }
    }
    var ascending = true
    
    private let fetchRequest = NSFetchRequest<Solves>(entityName: "Solves")
    
    init (currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext) {
        self._currentSession = currentSession
        self.managedObjectContext = managedObjectContext
        fetchRequest.predicate = NSPredicate(format: "session == %@", currentSession.wrappedValue)
        resort()
    }
    
    func resort() {
        NSLog("resort")
        if sortBy == 0 {
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Solves.date, ascending: ascending)]
        } else {
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Solves.time, ascending: ascending)]
        }
        do {
            try allsolves = managedObjectContext.fetch(fetchRequest)
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        solves = allsolves!
        refilter()
    }
    func refilter() {
        if filter == "" {
            solves = allsolves
        } else {
            solves = allsolves?.filter{ formatSolveTime(secs: $0.time).hasPrefix(filter) }
        }
    }
}

@available(iOS 15.0, *)
struct TimeListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var currentSession: Sessions
    
    @StateObject var timeListManager: TimeListManager
    
    @State var solve: Solves?
    
    @State var isSelectMode = false
    @State var selectedSolves: [Solves] = []
     
    //let descendingButtonIcon: Image = Image(systemName: "chevron.down.circle")
    //var buttonIcon: String = userLastState
    
    private let columns = [
        // GridItem(.adaptive(minimum: 112), spacing: 11)
        GridItem(spacing: 10),
        GridItem(spacing: 10),
        GridItem(spacing: 10)
    ]
    
//    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    init (currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext) {
        self._currentSession = currentSession
        self._timeListManager = StateObject(wrappedValue: TimeListManager(currentSession: currentSession, managedObjectContext: managedObjectContext))
        //fetchRequest = NSFetchRequest<Solves>(entity: Solves.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Solves.date, ascending: true)], predicate: NSPredicate(format: "session == %@", self.currentSession!))
        
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                /// YES FULL BLACK FOR AMOLED DO YOU HATE YOUR BATTERY LIFE
                    .ignoresSafeArea()
                
                
                ScrollView() {
                    VStack {
                        HStack (alignment: .center) {
                            Text(currentSession.name!)
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            Spacer()
                            
                            Text(puzzle_types[Int(currentSession.scramble_type)].name) // TODO playground
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                        .padding(.horizontal)
                        
                        ZStack {
                            HStack {
                                Spacer()
                                
                                Picker("Sort Method", selection: $timeListManager.sortBy) {
                                    Text("Sort by Date").tag(0)
                                    Text("Sort by Time").tag(1)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(maxWidth: 200, alignment: .center)
                                .padding(.top, -6)
                                .padding(.bottom, 4)
                                
                               
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                
                                Button {
                                    timeListManager.ascending.toggle()
                                    timeListManager.resort()
                                    // let sortDesc: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: sortAscending)
                                    //solves.sortDescriptors = [sortDesc]
                                } label: {
                                    Image(systemName: timeListManager.ascending ? "chevron.up.circle" : "chevron.down.circle")
                                        .font(.system(size: 20, weight: .medium))
                                }
//                                        .padding(.trailing, 16.5)
                                .padding(.trailing)
                                .padding(.top, -6)
                                .padding(.bottom, 4)
                            }
                        }
                             
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(timeListManager.solves!, id: \.self) { item in
                                TimeCard(solve: item, currentSolve: $solve, isSelectMode: $isSelectMode, selectedSolves: $selectedSolves)
                                    .environment(\.managedObjectContext, managedObjectContext)
                            }
                        }
                        .padding(.horizontal)
                        
//                        Spacer()
                    }
                    .padding(.vertical, -6)
                }
                .navigationTitle("Session Times")
                
                .sheet(item: $solve /*isPresented: $showingPopupSlideover*/, onDismiss: {
                    if managedObjectContext.hasChanges {
                        try! managedObjectContext.save()
                    }
                }) { item in
                    
                    SolvePopupView(solve: item, currentSolve: $solve, timeListManager: timeListManager)
                        .environment(\.managedObjectContext, managedObjectContext)
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if isSelectMode {
                            Button {
                                isSelectMode = false
                                selectedSolves.removeAll()
                            } label: {
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .padding(.leading, -4)
                                Text("Stop Selecting")
                                    .padding(.leading, -4)
                            }
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if isSelectMode {
                            Button {
                                isSelectMode = false
                                NSLog("hi")
                                for object in selectedSolves {
                                    managedObjectContext.delete(object)
                                }
                                selectedSolves.removeAll()
                                if managedObjectContext.hasChanges {
                                    try! managedObjectContext.save()
                                    timeListManager.resort()
                                }
                            } label: {
                                Image(systemName: "trash.circle.fill")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color.red)
                            }
                        
                        } else {
                            Button {
                                isSelectMode = true
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 17, weight: .medium))
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .frame(height: 50)
                        .padding(.top)
                }
            }
            
        }
        .searchable(text: $timeListManager.filter, placement: .navigationBarDrawer)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
