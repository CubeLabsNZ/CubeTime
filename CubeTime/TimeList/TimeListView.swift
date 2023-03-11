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
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @ScaledMetric(wrappedValue: 35, relativeTo: .body) private var frameHeight: CGFloat
    
    let hasShadow: Bool
    var animation: Namespace.ID
    
    
    var body: some View {
        Menu {
            #warning("TODO: headers not working")
            Section("Sort by") {
                Picker("", selection: $stopwatchManager.timeListSortBy) {
                    Label("Date", systemImage: "calendar").tag(SortBy.date)
                    Label("Time", systemImage: "stopwatch").tag(SortBy.time)
                }
                .labelsHidden()
            }

            Section("Order by") {
                Picker("", selection: $stopwatchManager.timeListAscending) {
                    Label("Ascending", systemImage: "arrow.up").tag(true)
                    Label("Descending", systemImage: "arrow.down").tag(false)
                }
            }

            Section("Filters") {
                Toggle(isOn: $stopwatchManager.hasPenaltyOnly) {
                    Label("Has Penalty", systemImage: "exclamationmark.triangle")
                }
                
                Toggle(isOn: $stopwatchManager.hasCommentOnly) {
                    Label("Has Comment", systemImage: "quote.opening")
                }

                Menu("Puzzle Type") {
                    Picker("", selection: $stopwatchManager.scrambleTypeFilter) {
                        Text("All Puzzles").tag(-1)
                        ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                            Label(element.name, image: element.name).tag(index)
                        }
                    }
                }
            }
        } label: {
            HierarchicalButtonBase(type: .halfcoloured, size: .large, outlined: false, square: true, hasShadow: hasShadow, hasBackground: true, expandWidth: true) {
                Image(systemName: "line.3.horizontal.decrease")
                    .matchedGeometryEffect(id: "label", in: animation)
            }
            .animation(Animation.customEaseInOut, value: self.hasShadow)
            .frame(width: frameHeight, height: frameHeight)
        }
    }
}


struct SessionHeader: View {
    @ScaledMetric(wrappedValue: 35, relativeTo: .body) private var frameHeight: CGFloat

    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    var body: some View {
        HStack {
            SessionIconView(session: stopwatchManager.currentSession)
            
            Text(stopwatchManager.currentSession.name ?? "Unknown Session Name")
                .font(.body.weight(.medium))
            
            Spacer()
            
            if (SessionType(rawValue: stopwatchManager.currentSession.session_type) != .playground) {
                Text(puzzle_types[Int(stopwatchManager.currentSession.scramble_type)].name)
                    .font(.body.weight(.medium))
                    .padding(.trailing)
            }
        }
        .frame(height: frameHeight)
        .background(
            Color("overlay1")
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        )
    }
}

struct TimeListHeader: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @ScaledMetric(wrappedValue: 35, relativeTo: .body) private var barHeight: CGFloat
    @ScaledMetric(wrappedValue: -43, relativeTo: .body) private var offset: CGFloat
    
    @State var searchExpanded = false
    @State var pressing = false
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 8) {
            if !searchExpanded {
                if (!(UIDevice.deviceIsPad && hSizeClass == .regular)) {
                    SessionHeader()
                }
            }
            
            // search bar
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color("overlay0"))
                    .shadowDark(x: 0, y: 1)
                
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.horizontal, searchExpanded ? 9 : 0)
                        .foregroundColor(Color("accent"))
                        .font(.body.weight(.medium))
                    
                    #warning("todo make search bar search for comments too?")
                    if searchExpanded {
                        TextField("Search for a time...", text: $stopwatchManager.timeListFilter)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color(stopwatchManager.timeListFilter.isEmpty ? "grey" : "dark"))
                        
                        HStack(spacing: 8) {
                            Spacer()
                            
                            Button {
                                withAnimation(Animation.customEaseInOut) {
                                    stopwatchManager.timeListFilter = ""
                                    searchExpanded = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        .font(.body)
                        .buttonStyle(AnimatedButton())
                        .foregroundColor(searchExpanded ? Color("accent") : Color.clear)
                        .padding(.horizontal, 8)
                    }
                }
                .mask(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .frame(width: searchExpanded ? nil : barHeight)
                )
            }
            .frame(width: searchExpanded ? nil : barHeight, height: barHeight)
            .fixedSize(horizontal: !searchExpanded, vertical: true)

            .scaleEffect(pressing ? 0.96 : 1.00)
            .opacity(pressing ? 0.80 : 1.00)
            .gesture(
                searchExpanded ? nil :
                DragGesture(minimumDistance: 0)
                    .onChanged{ _ in
                        withAnimation(Animation.customFastSpring) {
                            pressing = true
                        }
                    }
                    .onEnded{ _ in
                        withAnimation(Animation.customFastSpring) {
                            pressing = false
                        }
                        withAnimation(Animation.customEaseInOut) {
                            searchExpanded = true
                        }
                    }
            )
            
            .padding(.trailing, searchExpanded ? offset : 0)
            
            SortByMenu(hasShadow: !searchExpanded, animation: animation)
                .offset(x: searchExpanded ? -43 : 0)
        }
        .padding(.horizontal)
        .if((UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
            view.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct TimeListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @State var solve: Solves?
    @State var calculatedAverage: CalculatedAverage?
    
    @State var sessionsCanMoveToPlaygroundContextMenu: [Sessions]?
    
    @State var isSelectMode = false
    
    @State var isCleaningSession = false
    
    private var columns: [GridItem] {
        if sizeCategory > ContentSizeCategory.extraLarge {
            return [GridItem(spacing: 10), GridItem(spacing: 10)]
        } else if sizeCategory < ContentSizeCategory.small {
            return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
        } else {
            return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
        }
    }
    var body: some View {
        let sess_type = stopwatchManager.currentSession.session_type
        NavigationView {
            ZStack {
                Color((UIDevice.deviceIsPad && hSizeClass == .regular) ? "overlay1" : "base")
                    .ignoresSafeArea()
                
                let sessType = stopwatchManager.currentSession.session_type
                
                Group {
                    if sessType != SessionType.compsim.rawValue {
                        VStack {
                            TimeListHeader()
                            
                            TimeListInner(isSelectMode: $isSelectMode, currentSolve: $solve)
                                .ignoresSafeArea()
                        }
                    } else {
                        ScrollView {
                            LazyVStack {
                                TimeListHeader()
                                
                                let groups = stopwatchManager.compsimSolveGroups!
                                LazyVStack(spacing: 12) {
                                    if groups.count != 0 {
                                        TimeBar(solvegroup: groups.last!, currentCalculatedAverage: $calculatedAverage, isSelectMode: $isSelectMode, current: true)
                                        
                                        if groups.last!.solves!.array.count != 0 {
                                            LazyVGrid(columns: columns, spacing: 12) {
                                                ForEach(groups.last!.solves!.array as! [Solves], id: \.self) { solve in
                                                    TimeCard(solve: solve, currentSolve: $solve)
                                                }
                                            }
                                        }
                                        
                                        if groups.count > 1 {
                                            ThemedDivider()
                                                .padding(.horizontal, 8)
                                        }
                                    } else {
                                        // re-enable when we have a graphic
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
                        .if(!(UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
                            view.safeAreaInset(safeArea: .tabBar)
                        }
                    }
                }
                .navigationTitle(isSelectMode ? "Select Solves" : "Session Times")
                .navigationBarTitleDisplayMode((UIDevice.deviceIsPad && hSizeClass == .regular) ? .inline : .large)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        #warning("MAKE THIS PICKER MENU")
                        if isSelectMode {
                            Menu {
                                if stopwatchManager.timeListSolvesSelected.count == 0 {
                                    Button(role: .destructive) {
                                        isCleaningSession = true
                                    } label: {
                                        Label("Clear Session", systemImage: "xmark.bin")
                                    }
                                } else {
                                    Button {
                                        copySolve(solves: stopwatchManager.timeListSolvesSelected)
                                        
                                        stopwatchManager.timeListSolvesSelected.removeAll()
                                    } label: {
                                        Label("Copy", systemImage: "doc.on.doc")
                                    }
                                    
                                    Menu {
                                        Button {
                                            for object in stopwatchManager.timeListSolvesSelected {
                                                stopwatchManager.changePen(solve: object, pen: .none)
                                            }
                                            
                                            stopwatchManager.timeListSolvesSelected.removeAll()
                                        } label: {
                                            Label("No Penalty", systemImage: "checkmark.circle")
                                        }
                                        
                                        Button {
                                            for object in stopwatchManager.timeListSolvesSelected {
                                                stopwatchManager.changePen(solve: object, pen: .plustwo)
                                            }
                                            
                                            stopwatchManager.timeListSolvesSelected.removeAll()
                                        } label: {
                                            Label("+2", image: "+2.label")
                                        }
                                        
                                        Button {
                                            for object in stopwatchManager.timeListSolvesSelected {
                                                stopwatchManager.changePen(solve: object, pen: .dnf)
                                            }
                                            
                                            stopwatchManager.timeListSolvesSelected.removeAll()
                                        } label: {
                                            Label("DNF", systemImage: "xmark.circle")
                                        }
                                    } label: {
                                        Label("Penalty", systemImage: "exclamationmark.triangle")
                                    }
                                    
                                    if stopwatchManager.currentSession.session_type != SessionType.compsim.rawValue {
                                        SessionPickerMenu(sessions: sess_type == SessionType.playground.rawValue ? sessionsCanMoveToPlaygroundContextMenu : stopwatchManager.sessionsCanMoveTo) { session in
                                            for object in stopwatchManager.timeListSolvesSelected {
                                                withAnimation(Animation.customDampedSpring) {
                                                    stopwatchManager.moveSolve(solve: object, to: session)
                                                }
                                            }
                                            stopwatchManager.timeListSolvesSelected.removeAll()
                                        }
                                    }
                                    
                                    Divider()
                                    
                                    Button(role: .destructive) {
                                        isSelectMode = false
                                        for object in stopwatchManager.timeListSolvesSelected {
                                            stopwatchManager.delete(solve: object)
                                        }
                                        
                                        stopwatchManager.timeListSolvesSelected.removeAll()
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            } label: {
                                HierarchicalButtonBase(type: .coloured, size: .small, outlined: false, square: true, hasShadow: true, hasBackground: true, expandWidth: true) {
                                    Image(systemName: "ellipsis")
                                        .frame(width: 28, height: 28)
                                        .imageScale(.medium)
                                }
                                .frame(width: 28, height: 28)
                            }
                            .frame(width: 28, height: 28)
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if stopwatchManager.currentSession.session_type != SessionType.compsim.rawValue {
                            if isSelectMode {
                                HierarchicalButton(type: .coloured, size: .small, onTapRun: {
                                    withAnimation(Animation.customDampedSpring) {
                                        stopwatchManager.timeListSelectAll?()
                                    }
                                }) {
                                    Text("Select All")
                                }
                                
                                HierarchicalButton(type: .disabled, size: .small, onTapRun: {
                                    withAnimation(Animation.customDampedSpring) {
                                        isSelectMode = false
                                    }
                                }) {
                                    Text("Cancel")
                                }
                            } else {
                                HierarchicalButton(type: .coloured, size: .small, onTapRun: {
                                    isSelectMode = true
                                }) {
                                    Text("Select")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
        .confirmationDialog("Clear session?", isPresented: $isCleaningSession, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                stopwatchManager.clearSession()
                isSelectMode = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to continue? This will delete every solve in this session!")
        }
        
        .sheet(item: $solve) { item in
            TimeDetailView(for: item, currentSolve: $solve)
                .tint(Color("accent"))
        }
        
        .sheet(item: $calculatedAverage) { item in
            StatsDetailView(solves: item, session: stopwatchManager.currentSession)
                .tint(Color("accent"))
        }
        
        .onChange(of: stopwatchManager.timeListSolvesSelected) { newValue in
            NSLog("num of selected solves: \(newValue.count)")
            if newValue.count == 0 {
                isSelectMode = false
                return
            }
            
            if stopwatchManager.currentSession.session_type != SessionType.playground.rawValue {
                return
            }
            
            let uniqueScrambles = Set(stopwatchManager.timeListSolvesSelected.map{$0.scramble_type})
            
            #if DEBUG
            NSLog("TIMELISTVIEW SELECT: \(uniqueScrambles)")
            #endif
            
            if uniqueScrambles.count > 1 {
                sessionsCanMoveToPlaygroundContextMenu = stopwatchManager.allPlaygroundSessions
            } else if uniqueScrambles.count == 1 {
                let scr_type = uniqueScrambles.first!
                sessionsCanMoveToPlaygroundContextMenu = stopwatchManager.sessionsCanMoveToPlayground[Int(scr_type)]
            }
        }
    }
}
