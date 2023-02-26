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

struct SortByMenu: View {
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    let shadow: Bool
    var animation: Namespace.ID
    
    @State var penonly = false
    
    var body: some View {
        Menu {
            #warning("TODO: headers not working")
            Section("Sort by") {
                Picker("", selection: $stopWatchManager.timeListSortBy) {
                    Label("Date", systemImage: "calendar").tag(SortBy.date)
                    Label("Time", systemImage: "stopwatch").tag(SortBy.time)
                }
                .labelsHidden()
            }

            Section("Order by") {
                Picker("", selection: $stopWatchManager.timeListAscending) {
                    Label("Ascending", systemImage: "arrow.up").tag(true)
                    Label("Descending", systemImage: "arrow.down").tag(false)
                }
            }

            Section("Filters") {
                Toggle(isOn: $penonly) {
                    Label("Has Penalty", systemImage: "exclamationmark.triangle")
                }

                Menu("Phase number") {
                    Picker("", selection: .constant(0)) {
                        Text("Total").tag(0)
                        Text("1").tag(0)
                        Text("2").tag(1)
                    }
                }
            }
        } label: {
            HierarchialButtonBase(type: .halfcoloured, size: .large, outlined: false, square: true, hasShadow: shadow, hasBackground: true) {
                Image(systemName: "line.3.horizontal.decrease")
                    .matchedGeometryEffect(id: "label", in: animation)
            }
            .animation(Animation.customEaseInOut, value: self.shadow)
            .frame(width: 35, height: 35)
        }
    }
}


struct SessionHeader: View {
    @EnvironmentObject var stopwatchManager: StopWatchManager
    
    var body: some View {
        HStack {
            SessionIconView(session: stopwatchManager.currentSession)
            
            Text(stopwatchManager.currentSession.name ?? "Unknown Session Name")
                .font(.system(size: 17, weight: .medium))
            
            Spacer()
            
            if (SessionTypes(rawValue: stopwatchManager.currentSession.session_type) != .playground) {
                Text(puzzle_types[Int(stopwatchManager.currentSession.scramble_type)].name)
                    .font(.system(size: 17, weight: .medium))
                    .padding(.trailing)
            }
        }
        .frame(height: 35)
        .background(
            Color("overlay1")
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        )

    }
}


struct TimeListHeader: View {
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @State var searchExpanded = false
    @State var pressing = false
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 8) {
            if !searchExpanded {
                SessionHeader()
            }
            
            // search bar
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color("overlay0"))
                    .shadowDark(x: 0, y: 1)
                
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.horizontal, searchExpanded ? 9 : 0)
                        .foregroundColor(Color.accentColor)
                        .font(.body.weight(.medium))
                    
                    if searchExpanded {
                        TextField("Search for a time...", text: .constant(""))
                            .frame(width: .infinity)
                            .foregroundColor(Color("grey"))
                        
                        HStack(spacing: 8) {
                            Spacer()
                            
                            Button {
                                withAnimation(Animation.customEaseInOut) {
                                    searchExpanded = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        .font(.body)
                        .buttonStyle(AnimatedButton())
                        .foregroundColor(searchExpanded ? Color.accentColor : Color.clear)
                        .padding(.horizontal, 8)
                    }
                }
                .mask(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .frame(width: searchExpanded ? nil : 35)
                )
            }
            .frame(width: searchExpanded ? nil : 35, height: 35)
            .fixedSize(horizontal: !searchExpanded, vertical: true)
            
            .scaleEffect(pressing ? 0.96 : 1.00)
            .opacity(pressing ? 0.80 : 1.00)
            .gesture(
                searchExpanded ? nil :
                DragGesture(minimumDistance: 0)
                    .onChanged{ _ in
                        pressing = true
                    }
                    .onEnded{ _ in
                        pressing = false
                        withAnimation(Animation.customEaseInOut) {
                            searchExpanded = true
                        }
                    }
            )
            
            .padding(.trailing, searchExpanded ? -43 : 0)
            
            SortByMenu(shadow: !searchExpanded, animation: animation)
                .offset(x: searchExpanded ? -43 : 0)
        }
        .padding(.horizontal)
    }
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
                Color("base")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack {
                        TimeListHeader()

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
                    .padding(.top, -6)
                }
                .navigationTitle(isSelectMode ? "Select Solves" : "Session Times")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        #warning("MAKE THIS PICKER MENU")
                        if isSelectMode {
                            Menu {
                                if selectedSolves.count == 0 {
                                    Button(role: .destructive) {
                                        isClearningSession = true
                                    } label: {
                                        Label("Clear Session", systemImage: "xmark.bin")
                                    }
                                } else {
                                    Button {
                                        copySolve(solves: selectedSolves)
                                        
                                        selectedSolves.removeAll()
                                    } label: {
                                        Label("Copy", systemImage: "doc.on.doc")
                                    }
                                    
                                    Menu {
                                        Button {
                                            for object in selectedSolves {
                                                stopWatchManager.changePen(solve: object, pen: .none)
                                            }
                                            
                                            selectedSolves.removeAll()
                                        } label: {
                                            Label("No Penalty", systemImage: "checkmark.circle")
                                        }
                                        
                                        Button {
                                            for object in selectedSolves {
                                                stopWatchManager.changePen(solve: object, pen: .plustwo)
                                            }
                                            
                                            selectedSolves.removeAll()
                                        } label: {
                                            Label("+2", image: "+2.label")
                                        }
                                        
                                        Button {
                                            for object in selectedSolves {
                                                stopWatchManager.changePen(solve: object, pen: .dnf)
                                            }
                                            
                                            selectedSolves.removeAll()
                                        } label: {
                                            Label("DNF", systemImage: "xmark.circle")
                                        }
                                    } label: {
                                        Label("Penalty", systemImage: "exclamationmark.triangle")
                                    }
                                    
                                    if stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue {
                                        SessionPickerMenu(sessions: sessionsCanMoveTo) { session in
                                            for object in selectedSolves {
                                                withAnimation(Animation.customDampedSpring) {
                                                    stopWatchManager.moveSolve(solve: object, to: session)
                                                }
                                                
                                                selectedSolves.removeAll()
                                            }
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    Button(role: .destructive) {
                                        isSelectMode = false
                                        for object in selectedSolves {
                                            stopWatchManager.delete(solve: object)
                                        }
                                        
                                        selectedSolves.removeAll()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            } label: {
                                HierarchialButtonBase(type: .coloured, size: .small, outlined: false, square: true, hasShadow: true, hasBackground: true) {
                                    Image(systemName: "ellipsis")
                                        .imageScale(.medium)
                                }
                            }
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue {
                            if isSelectMode {
                                HierarchialButton(type: .coloured, size: .small, onTapRun: {
                                    withAnimation(Animation.customDampedSpring) {
                                        selectedSolves = Set(stopWatchManager.timeListSolvesFiltered)
                                    }
                                }) {
                                    Text("Select All")
                                }
                                
                                HierarchialButton(type: .disabled, size: .small, onTapRun: {
                                    isSelectMode = false
                                    withAnimation(Animation.customDampedSpring) {
                                        selectedSolves.removeAll()
                                    }
                                }) {
                                    Text("Cancel")
                                }
                            } else {
                                HierarchialButton(type: .coloured, size: .small, onTapRun: {
                                    isSelectMode = true
                                }) {
                                    Text("Select")
                                }
                            }
                        }
                    }
                }
                .safeAreaInset(safeArea: .tabBar)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        .confirmationDialog("Clear session?", isPresented: $isClearningSession, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                stopWatchManager.clearSession()
                isSelectMode = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to continue? This will delete every solve in this session!")
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
