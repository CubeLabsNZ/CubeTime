import Foundation
import SwiftUI
import CoreData

/*
enum buttonMode {
    case isAscending
    case isDescending
}
 */

enum SortBy: Int {
    case date
    case time
}



struct TimeListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.sizeCategory) var sizeCategory
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    
    @State var solve: Solves?
    @State var calculatedAverage: CalculatedAverage?
    
    @State var sessionsCanMoveTo: [Sessions]?
    
    @State var isSelectMode = false
    @State var selectedSolves: Set<Solves> = []
    
    @State var isClearningSession = false
    
    private var columns: [GridItem] {
        if sizeCategory > ContentSizeCategory.extraLarge {
            return [GridItem(spacing: 10), GridItem(spacing: 10)]
        } else if sizeCategory < ContentSizeCategory.small {
            return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
        } else {
            return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
        }
    }
    
    
    /* TODO: COMBINE THIS WITH THE ABOVE
    private var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
        } else {
            if globalGeometrySize.width > globalGeometrySize.width/2 {
                return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
            } else {
                return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
            }
        }
    }
     */
    
    func updateSessionsCanMoveTo() {
        if stopWatchManager.currentSession.session_type == SessionTypes.playground.rawValue || stopWatchManager.currentSession.session_type == SessionTypes.compsim.rawValue {
            return
        }
        
        
        sessionsCanMoveTo = getSessionsCanMoveTo(managedObjectContext: managedObjectContext, scrambleType: stopWatchManager.currentSession.scramble_type, currentSession: stopWatchManager.currentSession)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.bg(colourScheme)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack {
                        SessionBar(name: stopWatchManager.currentSession.name!, session: stopWatchManager.currentSession)
                            .padding(.horizontal)
                        
                        
                        // REMOVE THIS IF WHEN SORT IMPELEMNTED FOR COMP SIM SESSIONS
                        if stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue {
                            ZStack {
                                HStack {
                                    Spacer()
                                    
                                    Picker("Sort Method", selection: $stopWatchManager.timeListSortBy) {
                                        Text("Sort by Date").tag(SortBy.date)
                                        Text("Sort by Time").tag(SortBy.time)
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
                                        stopWatchManager.timeListAscending.toggle()
                                        // let sortDesc: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: sortAscending)
                                        //solves.sortDescriptors = [sortDesc]
                                    } label: {
                                        Image(systemName: stopWatchManager.timeListAscending ? "chevron.up.circle" : "chevron.down.circle")
                                            .font(.title3.weight(.medium))
                                    }
                                    .padding(.trailing)
                                    .padding(.top, -6)
                                    .padding(.bottom, 4)
                                }
                            }
                        }
                        
                        let sessType = stopWatchManager.currentSession.session_type
                        
                        if sessType != SessionTypes.compsim.rawValue {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(stopWatchManager.timeListSolvesFiltered, id: \.self) { item in
                                    TimeCard(solve: item, currentSolve: $solve, isSelectMode: $isSelectMode, selectedSolves: $selectedSolves, sessionsCanMoveTo: sessType != SessionTypes.playground.rawValue ? $sessionsCanMoveTo : nil)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 12) {
                                let groups = ((stopWatchManager.currentSession as! CompSimSession).solvegroups!.array as! [CompSimSolveGroup])
                                    
                                if groups.count != 0 {
                                    TimeBar(solvegroup: groups.last!, currentCalculatedAverage: $calculatedAverage, isSelectMode: $isSelectMode, current: true)
                                    
                                    if groups.last!.solves!.array.count != 0 {
                                        LazyVGrid(columns: columns, spacing: 12) {
                                            ForEach(groups.last!.solves!.array as! [Solves], id: \.self) { solve in
                                                TimeCard(solve: solve, currentSolve: $solve, isSelectMode: $isSelectMode, selectedSolves: $selectedSolves)
                                            }
                                        }
                                    }
                                    
                                    if groups.count > 1 {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                    
                                } else {
                                    // re-enable when we have a graphic
//                                    Text("display the empty message")
                                }
                                
                                
                                
                                #warning("TODO:  sorting")
                                
                                
                                
                                
                                ForEach(groups, id: \.self) { item in
                                    if item != groups.last! {
                                        TimeBar(solvegroup: item, currentCalculatedAverage: $calculatedAverage, isSelectMode: $isSelectMode, current: false)
                                    }
                                }
                                 
                                 
                                 
                            }
                            .padding(.horizontal)
                         
                         
                        }
                         
                    }
                    .padding(.vertical, -6)
                }
                .navigationTitle(isSelectMode ? "Select Solves" : "Session Times")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        #warning("MAKE THIS PICKER MENU")
                        if isSelectMode {
                            Menu {
                                if selectedSolves.count == 0 {
                                    Button() {
                                        withAnimation {
                                            selectedSolves = Set(stopWatchManager.timeListSolvesFiltered)
                                        }
                                    } label: {
                                        Label("Select all", systemImage: "squareshape.squareshape.dashed")
                                    }
                                    Button(role: .destructive) {
                                        isClearningSession = true
                                    } label: {
                                        Label("Clear Session", systemImage: "xmark.bin")
                                    }
                                } else {
                                    if stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue {
                                        SessionPickerMenu(sessions: sessionsCanMoveTo) { session in
                                            for object in selectedSolves {
                                                withAnimation {
                                                    stopWatchManager.moveSolve(solve: object, to: session)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Button {
                                        copySolve(solves: selectedSolves)
                                        
                                        selectedSolves.removeAll()
                                    } label: {
                                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                                    }
                                    
                                    Button(role: .destructive) {
                                        isSelectMode = false
                                        for object in selectedSolves {
                                            withAnimation {
                                                stopWatchManager.delete(solve: object)
                                            }
                                        }
                                        
                                        selectedSolves.removeAll()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue {
                            if isSelectMode {
                                Button {
                                    isSelectMode = false
                                    selectedSolves.removeAll()
                                } label: {
                                    Text("Cancel")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                                .tint(Color(uiColor: .systemGray))
                                .buttonStyle(.bordered)
                                .clipShape(Capsule())
                                .controlSize(.small)
                            } else {
                                Button {
                                    isSelectMode = true
                                } label: {
                                    Text("Edit")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(Color.accentColor)
                                }
                                .tint(.accentColor)
                                .buttonStyle(.bordered)
                                .clipShape(Capsule())
                                .controlSize(.small)
                            }
                        }
                    }
                }
                .safeAreaInset(safeArea: .tabBar)
            }
//            .if (stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue) { view in
//                view
//                    .searchable(text: $stopWatchManager.timeListFilter, placement: .navigationBarDrawer)
//            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        .confirmationDialog("Clear session?", isPresented: $isClearningSession, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                stopWatchManager.clearSession()
                isSelectMode = false
            }
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text("This will delete every solve in this session!")
        }
        
        .sheet(item: $solve) { item in
            TimeDetail(solve: item, currentSolve: $solve)
        }
        
        .sheet(item: $calculatedAverage) { item in
            StatsDetail(solves: item, session: stopWatchManager.currentSession)
        }
        
        .task {
            print("Task")
            updateSessionsCanMoveTo()
        }
        
        .onChange(of: stopWatchManager.currentSession) { newValue in
            #warning("make sure this actually is needed")
            print("CHANGED SESSION - TimeListView")
            updateSessionsCanMoveTo()
        }
        
        .onChange(of: selectedSolves) { newValue in
            if newValue.count == 0 {
                isSelectMode = false
                return
            }
            
            if stopWatchManager.currentSession.session_type != SessionTypes.playground.rawValue {
                return
            }
            
            let uniqueScrambles = Set(selectedSolves.map{$0.scramble_type})
            let scr_type: Int32!
            
            if uniqueScrambles.count > 1 {
                scr_type = -1
            } else {
                scr_type = uniqueScrambles.first!
            }
            
            sessionsCanMoveTo = getSessionsCanMoveTo(managedObjectContext: managedObjectContext, scrambleType: scr_type, currentSession: stopWatchManager.currentSession)
            
        }
    }
}
