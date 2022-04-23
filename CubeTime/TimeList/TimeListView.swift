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
    @Published var solves: [Solves]
    private var allsolves: [Solves]
    @Binding var currentSession: Sessions
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
    var ascending = false
    
    init (currentSession: Binding<Sessions>) {
        self._currentSession = currentSession
        self.allsolves = currentSession.wrappedValue.solves!.allObjects as! [Solves]
        self.solves = allsolves
        resort()
    }
    
    func delete(_ solve: Solves) {
        guard let index = allsolves.firstIndex(of: solve) else { return }
        allsolves.remove(at: index)
        guard let index = solves.firstIndex(of: solve) else { return }
        solves.remove(at: index)
    }
    
    func resort() {
        allsolves = allsolves.sorted{
            if sortBy == 0 {
                if ascending {
                    return $0.date! < $1.date!
                } else {
                    return $0.date! > $1.date!
                }
            } /*else {
                if ascending {
                    return timeWithPlusTwoForSolve($0) < timeWithPlusTwoForSolve($1)
                } else {
                    return timeWithPlusTwoForSolve($0) > timeWithPlusTwoForSolve($1)
                }
            }*/
            else {
                let pen0 = PenTypes(rawValue: $0.penalty)!
                let pen1 = PenTypes(rawValue: $1.penalty)!
                
                if (pen0 != .dnf && pen1 != .dnf) || (pen0 == .dnf && pen1 == .dnf) {
                    if ascending {
                        return timeWithPlusTwoForSolve($0) < timeWithPlusTwoForSolve($1)
                    } else {
                        return timeWithPlusTwoForSolve($0) > timeWithPlusTwoForSolve($1)
                    }
                } else if pen0 == .dnf && pen1 != .dnf {
                    return !ascending
                } else {
                    return ascending
                }
            }
        }
        solves = allsolves
        refilter()
    }
    
    
    func refilter() {
        if filter == "" {
            solves = allsolves
        } else {
            solves = allsolves.filter{ formatSolveTime(secs: $0.time).hasPrefix(filter) }
        }
    }
}



struct TimeListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Binding var currentSession: Sessions
    
    @StateObject var timeListManager: TimeListManager
    
    @State var solve: Solves?
    @State var calculatedAverage: CalculatedAverage?
    
    @State var isSelectMode = false
    @State var selectedSolves: [Solves] = []
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                    (scene as? UIWindowScene)?.keyWindow
                                }).first?.frame.size
    
    private var columns: [GridItem] {
        NSLog("\(UIScreen.screenWidth)")
        NSLog("\(windowSize!.width)")
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
        } else {
            if hSizeClass == .regular {
                return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
            } else {
                if windowSize!.width > UIScreen.screenWidth/2 {
                    return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
                } else {
                    return [GridItem(spacing: 10), GridItem(spacing: 10), GridItem(spacing: 10)]
                }
            }

        }
    }
    
    init (currentSession: Binding<Sessions>, managedObjectContext: NSManagedObjectContext) {
        self._currentSession = currentSession
        // TODO FIXME use a smarter way of this for more performance
        self._timeListManager = StateObject(wrappedValue: TimeListManager(currentSession: currentSession))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                
                ScrollView() {
                    LazyVStack {
                        HStack (alignment: .center) {
                            Text(currentSession.name!)
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            Spacer()
                            
                            switch SessionTypes(rawValue: currentSession.session_type)! {
                            case .standard:
                                Text(puzzle_types[Int(currentSession.scramble_type)].name)
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                            case .multiphase:
                                HStack(spacing: 2) {
                                    Image(systemName: "square.stack")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                    
                                    Text(puzzle_types[Int(currentSession.scramble_type)].name)
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                                
                            case .compsim:
                                HStack(spacing: 2) {
                                    Image(systemName: "globe.asia.australia")
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                    
                                    Text(puzzle_types[Int(currentSession.scramble_type)].name)
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                            
                            case .playground:
                                Text("Playground")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                            
                            default:
                                Text(puzzle_types[Int(currentSession.scramble_type)].name)
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                            }
                        }
                        .padding(.horizontal)
                        
                        // REMOVE THIS IF WHEN SORT IMPELEMNTED FOR COMP SIM SESSIONS
                        if currentSession.session_type != SessionTypes.compsim.rawValue {
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
                            
                        }
                        
                        
                        if currentSession.session_type != SessionTypes.compsim.rawValue {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(timeListManager.solves, id: \.self) { item in
                                    TimeCard(solve: item, timeListManager: timeListManager, currentSolve: $solve, isSelectMode: $isSelectMode, selectedSolves: $selectedSolves)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            LazyVStack(spacing: 12) {
                                let groups = ((currentSession as! CompSimSession).solvegroups!.array as! [CompSimSolveGroup])
                                
                                if groups.count != 0 {
                                    TimeBar(solvegroup: groups.last!, timeListManager: timeListManager, currentCalculatedAverage: $calculatedAverage, isSelectMode: $isSelectMode)
                                    
                                    if groups.last!.solves!.array.count != 0 {
                                        LazyVGrid(columns: columns, spacing: 12) {
                                            ForEach(groups.last!.solves!.array as! [Solves], id: \.self) { solve in
                                                TimeCard(solve: solve, timeListManager: timeListManager, currentSolve: $solve, isSelectMode: $isSelectMode, selectedSolves: $selectedSolves)
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
                                
                                
                                
                                // TODO sorting
                                
                                
                                
                                
                                ForEach(groups, id: \.self) { item in
                                    if item != groups.last! {
                                        TimeBar(solvegroup: item, timeListManager: timeListManager, currentCalculatedAverage: $calculatedAverage, isSelectMode: $isSelectMode)
                                    }
                                }
                                 
                                 
                                 
                            }
                            .padding(.horizontal)
                         
                         
                        }
                         
                    }
                    .padding(.vertical, -6)
                }
                .navigationTitle(isSelectMode ? "Select Solves" : "Session Times")
//                .navigationBarTitleDisplayMode(isSelectMode ? .inline : .large)
                
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if isSelectMode {
                            Button {
                                isSelectMode = false
                                for object in selectedSolves {
                                    managedObjectContext.delete(object)
                                    withAnimation {
                                        timeListManager.delete(object)
                                    }
                                }
                                selectedSolves.removeAll()
                                withAnimation {
                                    if managedObjectContext.hasChanges {
                                        try! managedObjectContext.save()
                                    }
                                }
                            } label: {
                                Text("Delete Solves")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color.red)
                            }
                            .tint(.red)
                            .buttonStyle(.bordered)
                            .clipShape(Capsule())
                            .controlSize(.small)
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if currentSession.session_type != SessionTypes.compsim.rawValue {
                            if isSelectMode {
                                Button {
                                    isSelectMode = false
                                    selectedSolves.removeAll()
                                } label: {
                                    Text("Cancel")
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
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
            }
            .if (currentSession.session_type != SessionTypes.compsim.rawValue) { view in
                view
                    .searchable(text: $timeListManager.filter, placement: .navigationBarDrawer)
            }
            
        }
        .accentColor(accentColour)
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $solve) { item in
            TimeDetail(solve: item, currentSolve: $solve, timeListManager: timeListManager)
                .environment(\.managedObjectContext, managedObjectContext)
        }
        
        .sheet(item: $calculatedAverage) { item in
            StatsDetail(solves: item, session: currentSession)
        }
    }
}
