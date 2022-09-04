import SwiftUI
import Foundation

struct SessionCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @State private var isShowingDeleteDialog = false
    @State private var isShowingCustomizeDialog = false
    
    var item: Sessions
    var allSessions: FetchedResults<Sessions>
    
    let pinned: Bool
    let session_type: SessionTypes
    let name: String
    let scramble_type: Int
    let solveCount: Int
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                (scene as? UIWindowScene)?.keyWindow
                            }).first?.frame.size
    
    @Namespace var namespace
    
    init (item: Sessions, allSessions: FetchedResults<Sessions>) {
        self.item = item
        self.allSessions = allSessions
        
        // Copy out the things so that it won't change to null coalesced defaults on deletion
        self.pinned = item.pinned
        self.session_type = SessionTypes(rawValue: item.session_type)!
        self.name = item.name ?? "Unknown session name"
        self.scramble_type = Int(item.scramble_type)
        self.solveCount = item.solves?.count ?? -1
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: colourScheme == .dark ? .systemGray4 : .systemGray5))
                .frame(height: pinned ? 110 : 65)
                .zIndex(0)
            
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colourScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .frame(width: stopWatchManager.currentSession == item ? 16 : windowSize!.width - 32, height: item.pinned ? 110 : 65)
                .offset(x: stopWatchManager.currentSession == item ? -((windowSize!.width - 16)/2) + 16 : 0)
            
                .zIndex(1)
            
            
        
            
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center, spacing: 0) {
                            ZStack {
                                if session_type != .standard {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(accentColour.opacity(0.33))
                                        .frame(width: 40, height: 40)
                                        .padding(.trailing, 12)
                                }
                                
                                switch session_type {
                                case .algtrainer:
                                    Image(systemName: "command.square")
                                        .font(.system(size: 26, weight: .semibold))
                                        .foregroundColor(accentColour)
                                        .padding(.trailing, 12)
                                case .playground:
                                    Image(systemName: "square.on.square")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(accentColour)
                                        .padding(.trailing, 12)
                                case .multiphase:
                                    Image(systemName: "square.stack")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(accentColour)
                                        .padding(.trailing, 12)
                                case .compsim:
                                    Image(systemName: "globe.asia.australia")
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(accentColour)
                                        .padding(.trailing, 12)
                                default:
                                    EmptyView()
                                }
                            }
                            
                            
                            VStack(alignment: .leading, spacing: -2) {
                                Text(name)
                                    .font(.title2.weight(.bold))
//                                    .foregroundColor(currentSession == item ? accentColour : (colourScheme == .dark ? Color.white : Color.black))
                                    .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                
                                Group {
                                    switch session_type {
                                    case .standard:
                                        Text(puzzle_types[scramble_type].name)
                                    case .playground:
                                        Text("Playground")
                                    case .multiphase:
                                        Text("Multiphase - \(puzzle_types[scramble_type].name)")
                                    case .compsim:
                                        Text("Comp Sim - \(puzzle_types[scramble_type].name)")
                                    default:
                                        EmptyView()
                                    }
                                }
                                .font(.subheadline.weight(.medium))
                                    .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
//                                .foregroundColor(currentSession == item ? accentColour : (colourScheme == .dark ? Color.white : Color.black))
                                .if(!pinned) { view in
                                    view.offset(y: -2)
                                }
                            }
                        }
                        
                        if pinned {
                            Spacer()
                            Text("\(solveCount) Solves")
                                .font(.subheadline.weight(.bold))
//                                .font(.system(size: 15, weight: .bold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                                .padding(.bottom, 4)
                        }
                    }
                    .offset(x: stopWatchManager.currentSession == item ? 10 : 0)
                    
                    Spacer()
                    
                    if session_type != .playground {
                        if item.pinned {
                            Image(puzzle_types[scramble_type].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
//                                .foregroundColor(currentSession == item ? accentColour : (colourScheme == .dark ? Color.white : Color.black))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                .padding(.vertical, 4)
                                .padding(.trailing, 12)
                        } else {
                            Image(puzzle_types[scramble_type].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
//                                .foregroundColor(currentSession == item ? accentColour : (colourScheme == .dark ? Color.white : Color.black))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                .padding(.trailing, 6)
                        }
                    }
                    
                    
                }
                .padding(.leading)
                .padding(.trailing, pinned ? 6 : 4)
                .padding(.vertical,  pinned ? 12 : 8)
            }
            
            .frame(height: pinned ? 110 : 65)
            
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .zIndex(2)
            
            if stopWatchManager.currentSession == item {
                HStack {
                    Capsule()
                        .fill(accentColour.opacity(0.6))
                        .frame(width: 4, height: (pinned ? 110 * 0.5 : 65 * 0.6))
                    
                    Spacer()
                }
                .offset(x: 5.5)
                .zIndex(3)
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.325)) {
                NSLog("setting current session to session with scramble type of \(item.scramble_type)")
                stopWatchManager.currentSession = item
            }
        }
        
        
        
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16, style: .continuous))
        
        .contextMenu(menuItems: {
            ContextMenuButton(delay: false,
                              action: { isShowingCustomizeDialog = true },
                              title: "Customise",
                              systemImage: "pencil", disableButton: false);
            
            ContextMenuButton(delay: true,
                              action: {
                withAnimation(.spring()) {
                    item.pinned.toggle()
                    try! managedObjectContext.save()
                }
            },
                              title: item.pinned ? "Unpin" : "Pin",
                              systemImage: item.pinned ? "pin.slash" : "pin", disableButton: false);
            Divider()
            
            ContextMenuButton(delay: false,
                              action: { isShowingDeleteDialog = true },
                              title: "Delete Session",
                              systemImage: "trash",
                              disableButton: allSessions.count <= 1)
                .foregroundColor(Color.red)
        })
        .padding(.horizontal)
        
        .sheet(isPresented: $isShowingCustomizeDialog) {
            CustomiseStandardSessionView(sessionItem: item)
        }
        
        .confirmationDialog(String("Are you sure you want to delete \"\(name)\"? All solves will be deleted and this cannot be undone."), isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                if item == stopWatchManager.currentSession {
                    var next: Sessions? = nil
                    for item in allSessions {
                        if item != stopWatchManager.currentSession {
                            next = item
                            break
                        }
                        /// **this should theoretically never happen, as the deletion option will be disabled if solves <= 1**
                        print("error: cannot find next session to replace current session")
                        
                    }
                    
                    if let next = next {
                        withAnimation {
                            stopWatchManager.currentSession = next
                        }
                        
                    }
                }
                
                withAnimation(.spring()) {
                    managedObjectContext.delete(item)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

