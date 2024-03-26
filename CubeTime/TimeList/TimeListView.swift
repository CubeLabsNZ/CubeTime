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
            if let phaseCount = (stopwatchManager.currentSession as? MultiphaseSession)?.phaseCount {
                Menu("Phase") {
                    Picker("", selection: $stopwatchManager.timeListShownPhase) {
                        Text("All phases").tag(Optional<Int16>.none)
                        
                        ForEach(0..<phaseCount, id: \.self) { idx in
                            Text("Phase \(idx + 1)").tag(Optional<Int16>.some(idx))
                        }
                    }
                }
            }
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

                if (SessionType(rawValue: stopwatchManager.currentSession.sessionType) == .playground) {
                    Menu("Puzzle Type") {
                        Picker("", selection: $stopwatchManager.scrambleTypeFilter) {
                            Text("All Puzzles").tag(-1)
                            ForEach(Array(zip(PUZZLE_TYPES.indices, PUZZLE_TYPES)), id: \.0) { index, element in
                                Label(element.name, image: element.name).tag(index)
                            }
                        }
                    }
                }
            }
        } label: {
            CTBubble(type: .halfcoloured(nil), size: .large, outlined: false, square: true, hasShadow: hasShadow, hasBackground: true, hasMaterial: true, supportsDynamicResizing: true, expandWidth: true) {
                Image(systemName: "line.3.horizontal.decrease")
                    .matchedGeometryEffect(id: "label", in: animation)
                    .font(.body.weight(.medium))
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
            
            if (SessionType(rawValue: stopwatchManager.currentSession.sessionType) != .playground) {
                Text(PUZZLE_TYPES[Int(stopwatchManager.currentSession.scrambleType)].name)
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
            
            if (stopwatchManager.currentSession.sessionType != SessionType.compsim.rawValue) {
                
                // search bar
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color("overlay0"))
                        .shadowDark(x: 0, y: 1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .padding(.leading, searchExpanded ? 8 : 0)
                            .padding(.trailing, searchExpanded ? 4 : 0)
                            .foregroundColor(Color("accent"))
                            .font(.body.weight(.medium))
                        
                        #warning("todo make search bar search for comments too?")
                        if searchExpanded {
                            TextField("Search…", text: $stopwatchManager.timeListFilter)
                                .recursiveMono(style: stopwatchManager.timeListFilter.isEmpty ? .callout : .body, weight: .medium)
                                .foregroundColor(Color(stopwatchManager.timeListFilter.isEmpty ? "grey" : "dark"))
                                .frame(maxWidth: .infinity)

                            Button {
                                withAnimation(Animation.customEaseInOut) {
                                    stopwatchManager.timeListFilter = ""
                                    searchExpanded = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .font(.body.weight(.medium))
                            .buttonStyle(CTButtonStyle())
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
                
                
                // sort by menu
                SortByMenu(hasShadow: !searchExpanded, animation: animation)
                    .offset(x: searchExpanded ? -36 : 0)
            }
        }
        .padding(.horizontal)
        .if((UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
            view.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct CompSimTimeListInner: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Binding var solve: Solve?
    @Binding var calculatedAverage: CalculatedAverage?
    
    var body: some View {
        let columns: [GridItem] = {
            if sizeCategory > ContentSizeCategory.extraLarge {
                return [GridItem(spacing: 10), GridItem(spacing: 10)]
            } else if sizeCategory < ContentSizeCategory.small {
                return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
            } else {
                return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
            }
        }()
        
        ScrollView {
            LazyVStack {
                TimeListHeader()
                
                let groups = stopwatchManager.compsimSolveGroups!
                LazyVStack(spacing: 12) {
                    
                    if groups.count != 0 {
                        TimeBar(solvegroup: groups.first!, currentCalculatedAverage: $calculatedAverage, isSelectMode: .constant(false), current: true)
                        
                        if groups.first!.solves!.allObjects.count != 0 {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(groups.first!.orderedSolves, id: \.self) { solve in
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
                    ForEach(groups, id: \.self) { item in
                        if item != groups.first! {
                            TimeBar(solvegroup: item, currentCalculatedAverage: $calculatedAverage, isSelectMode: .constant(false), current: false)
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

struct TimeListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @State var solve: Solve?
    @State var calculatedAverage: CalculatedAverage?
    
    @State var sessionsCanMoveToPlaygroundContextMenu: [Session]?
    
    @State var isSelectMode = false
    
    @State var isCleaningSession = false
    
    var body: some View {
        let sessionType = stopwatchManager.currentSession.sessionType
        NavigationView {
            ZStack {
                Color((UIDevice.deviceIsPad && hSizeClass == .regular) ? "overlay1" : "base")
                    .ignoresSafeArea()
                
                let sessType = stopwatchManager.currentSession.sessionType
                
                Group {
                    if sessType != SessionType.compsim.rawValue {
                        VStack {
                            TimeListHeader()
                            
                            TimeListInner(isSelectMode: $isSelectMode, currentSolve: $solve)
                                .ignoresSafeArea()
                        }
                    } else {
                        CompSimTimeListInner(solve: $solve, calculatedAverage: $calculatedAverage)
                    }
                }
                .navigationTitle(isSelectMode ? "Select Solves" : "Times")
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
                                    
                                    if stopwatchManager.currentSession.sessionType != SessionType.compsim.rawValue {
                                        SessionPickerMenu(sessions: sessionType == SessionType.playground.rawValue ? sessionsCanMoveToPlaygroundContextMenu : stopwatchManager.sessionsCanMoveTo) { session in
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
                                CTBubble(type: .coloured(nil), size: .small, outlined: false, square: true, hasShadow: true, hasBackground: true, hasMaterial: true, supportsDynamicResizing: true, expandWidth: true) {
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
                        if stopwatchManager.currentSession.sessionType != SessionType.compsim.rawValue {
                            if isSelectMode {
                                CTButton(type: .coloured(nil), size: .small, onTapRun: {
                                    withAnimation(Animation.customDampedSpring) {
                                        stopwatchManager.timeListSelectAll?()
                                    }
                                }) {
                                    Text("Select All")
                                }
                                
                                CTButton(type: .disabled, size: .small, onTapRun: {
                                    withAnimation(Animation.customDampedSpring) {
                                        isSelectMode = false
                                    }
                                }) {
                                    Text("Cancel")
                                }
                            } else {
                                CTButton(type: .coloured(nil), size: .small, onTapRun: {
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
            StatsDetailView(solves: item)
                .tint(Color("accent"))
        }
        
        .onChange(of: stopwatchManager.timeListSolvesSelected) { newValue in
            if newValue.count == 0 {
                isSelectMode = false
                return
            }
            
            if stopwatchManager.currentSession.sessionType != SessionType.playground.rawValue {
                return
            }
            
            let uniqueScrambles = Set(stopwatchManager.timeListSolvesSelected.map{$0.scrambleType})
            
            if uniqueScrambles.count > 1 {
                sessionsCanMoveToPlaygroundContextMenu = stopwatchManager.allPlaygroundSessions
            } else if uniqueScrambles.count == 1 {
                let scr_type = uniqueScrambles.first!
                sessionsCanMoveToPlaygroundContextMenu = stopwatchManager.sessionsCanMoveToPlayground[Int(scr_type)]
            }
        }
    }
}
