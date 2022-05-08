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
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.verticalSizeClass) var vSizeClass
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                
                ScrollView() {
                    LazyVStack {
                        HStack (alignment: .center) {
                            Text(stopWatchManager.currentSession.name!)
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            Spacer()
                            
                            switch SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! {
                            case .standard:
                                Text(puzzle_types[Int(stopWatchManager.currentSession.scramble_type)].name)
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                            case .multiphase:
                                HStack(spacing: 2) {
                                    Image(systemName: "square.stack")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                    
                                    Text(puzzle_types[Int(stopWatchManager.currentSession.scramble_type)].name)
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                                
                            case .compsim:
                                HStack(spacing: 2) {
                                    Image(systemName: "globe.asia.australia")
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                    
                                    Text(puzzle_types[Int(stopWatchManager.currentSession.scramble_type)].name)
                                        .font(.system(size: 16, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                            
                            case .playground:
                                Text("Playground")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                            
                            default:
                                Text(puzzle_types[Int(stopWatchManager.currentSession.scramble_type)].name)
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(uiColor: .systemGray))
                            }
                        }
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
                                            .font(.system(size: 20, weight: .medium))
                                    }
    //                                        .padding(.trailing, 16.5)
                                    .padding(.trailing)
                                    .padding(.top, -6)
                                    .padding(.bottom, 4)
                                }
                            }
                            
                        }
                        
                        
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
                                    TimeBar(solvegroup: groups.last!, currentCalculatedAverage: $calculatedAverage, isSelectMode: $isSelectMode)
                                    
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
                                
                                
                                
                                // TODO sorting
                                
                                
                                
                                
                                ForEach(groups, id: \.self) { item in
                                    if item != groups.last! {
                                        TimeBar(solvegroup: item, currentCalculatedAverage: $calculatedAverage, isSelectMode: $isSelectMode)
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
                                    withAnimation {
                                        stopWatchManager.delete(solve: object)
                                    }
                                }
                                selectedSolves.removeAll()
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
                        if stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue {
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
            .if (stopWatchManager.currentSession.session_type != SessionTypes.compsim.rawValue) { view in
                view
                    .searchable(text: $stopWatchManager.timeListFilter, placement: .navigationBarDrawer)
            }
            
        }
        .accentColor(accentColour)
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $solve) { item in
            TimeDetail(solve: item, currentSolve: $solve)
        }
        
        .sheet(item: $calculatedAverage) { item in
            StatsDetail(solves: item, session: stopWatchManager.currentSession)
        }
    }
}
