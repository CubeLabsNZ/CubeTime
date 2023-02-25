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
    
    let background: Bool
    
    var animation: Namespace.ID
    
    @State var penonly = false
    
    var body: some View {
        Menu {
            Section {
                Picker("Sort Method", selection: $stopWatchManager.timeListSortBy) {
                    Label("Date", systemImage: "calendar").tag(SortBy.date)
                    Label("Time", systemImage: "stopwatch").tag(SortBy.time)
                }
            } header: {
                Text("Sort")
            }
            
            Section {
                Picker("Sort Direction", selection: $stopWatchManager.timeListAscending) {
                    Label("Ascending", systemImage: "arrow.up").tag(true)
                    Label("Descending", systemImage: "arrow.down").tag(false)
                }
            } header: {
                Text("Order")
            }
            
            Section("Filters") {
                Toggle(isOn: $penonly) {
                    Label("Has Penalty", systemImage: "exclamationmark.triangle")
                }
                    
                Menu("Phase number") {
                    Picker("Sort Method", selection: .constant(0)) {
                        Text("Total").tag(0)
                        Text("1").tag(0)
                        Text("2").tag(1)
                    }
                }
            }
        } label: {
            Label("Sort", systemImage: "line.3.horizontal.decrease")
                .frame(width: 35, height: 35)
                .if (background) { view in
                    view
                        .background(
                            Color("overlay0")
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                    
                }
                .labelStyle(.iconOnly)
                .matchedGeometryEffect(id: "label", in: animation)
        }
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
                HStack {
                    SessionIconView(session: stopWatchManager.currentSession)
                    Text(stopWatchManager.currentSession.name ?? "Unknown Session Name")
                        .font(.system(size: 17, weight: .medium))
                        .padding(.trailing, 4)
                    Spacer()
                }
                .background(
                    Color("overlay1")
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .shadowLight(x: 0, y: 2)
                        .animation(.spring(), value: stopWatchManager.playgroundScrambleType)
                )
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color("overlay0"))
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.horizontal, searchExpanded ? 9 : 0)
                        .foregroundColor(Color.accentColor)
                        .font(.body.weight(.medium))
                    
                    if searchExpanded {
                        
                        TextField("Search for a time...", text: .constant(""))
                            .frame(width: .infinity)
                        
                        
                        HStack(spacing: 8) {
                            Spacer()
                            
                            SortByMenu(background: false, animation: animation)
                            
                            Button {
                                withAnimation {
                                    searchExpanded = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        .font(.body)
                        .buttonStyle(AnimatedButton())
                        .foregroundColor(Color.accentColor)
                        .padding(.horizontal, 8)
                    }
                }
            }
            .frame(width: searchExpanded ? nil : 35, height: 35)
            .scaleEffect(pressing ? 0.96 : 1.00)
            .opacity(pressing ? 0.80 : 1.00)
            .animation(.easeIn(duration: 0.1), value: pressing)
            .gesture(
                searchExpanded ? nil :
                DragGesture(minimumDistance: 0)
                    .onChanged{ _ in
                        pressing = true
                    }
                    .onEnded{ _ in
                        pressing = false
                        withAnimation {
                            searchExpanded = true
                        }
                    }
            )
            .fixedSize(horizontal: !searchExpanded, vertical: true)
            
            
            if !searchExpanded {
                SortByMenu(background: true, animation: animation)
            }
        }
        .padding(.top, 2)
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
    
    @State var isSelectMode = false
    @State var selectedSolves: [Solves] = []
    
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("base")
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack {
                        TimeListHeader()
                        
                        if stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(stopWatchManager.timeListSolvesFiltered, id: \.self) { item in
                                    TimeCard(solve: item, currentSolve: $solve, isSelectMode: $isSelectMode, selectedSolves: $selectedSolves)
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
                        if isSelectMode && (selectedSolves.count != 0) {
                            Menu {
                                Menu {
                                    Button("Move to a Normal Session") {
                                        print("1 tapped")
                                    }
                                    
                                    Button("Move to a Playground Session") {
                                        print("2 tapped")
                                    }
                                } label: {
                                    HStack {
                                        Text("Move")
                                        
                                        Image(systemName: "arrow.right")
                                    }
                                }
                                
                                Button {
                                    copySolve(solves: selectedSolves)
                                    
                                    selectedSolves.removeAll()
                                } label: {
                                    HStack {
                                        Text("Copy to Clipboard")
                                        
                                        Image(systemName: "doc.on.doc")
                                    }
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
                                    HStack {
                                        Text("Delete")
                                        
                                        Image(systemName: "trash")
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
                                    Text("Select")
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $solve) { item in
            TimeDetail(solve: item, currentSolve: $solve)
        }
        
        .sheet(item: $calculatedAverage) { item in
            StatsDetail(solves: item, session: stopWatchManager.currentSession)
        }
    }
}
