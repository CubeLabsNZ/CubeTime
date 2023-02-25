import SwiftUI
import Foundation

struct SessionCard: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize

    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    
    @State private var isShowingDeleteDialog = false
    @State private var isShowingCustomizeDialog = false
    
    var item: Sessions
    var allSessions: FetchedResults<Sessions>
    
    let pinned: Bool
    let session_type: SessionTypes
    let name: String
    let scramble_type: Int
    let solveCount: Int
    let parentGeo: GeometryProxy
    
    @Namespace var namespace
    
    init (item: Sessions, allSessions: FetchedResults<Sessions>, parentGeo: GeometryProxy) {
        self.item = item
        self.allSessions = allSessions
        
        // Copy out the things so that it won't change to null coalesced defaults on deletion
        self.pinned = item.pinned
        self.session_type = SessionTypes(rawValue: item.session_type)!
        self.name = item.name ?? "Unknown session name"
        self.scramble_type = Int(item.scramble_type)
        self.solveCount = item.solves?.count ?? -1
        
        self.parentGeo = parentGeo
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("indent2"))
                .frame(height: pinned ? 110 : 65)
                .zIndex(0)
            
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("overlay1"))
                .frame(width: stopWatchManager.currentSession == item
                       ? 16
                       : parentGeo.size.width - 32, height: item.pinned ? 110 : 65)
                .offset(x: stopWatchManager.currentSession == item
                        ? -((parentGeo.size.width - 16)/2) + 16
                        : 0)
            
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
                                    .foregroundColor(Color("dark"))
                                
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
                                    .foregroundColor(Color("dark"))
                                .if(!pinned) { view in
                                    view.offset(y: -2)
                                }
                            }
                        }
                        
                        if pinned {
                            Spacer()
                            Text("\(solveCount) Solves")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Color("grey"))
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
                                .foregroundColor(Color("dark"))
                                .padding(.vertical, 4)
                                .padding(.trailing, 12)
                        } else {
                            Image(puzzle_types[scramble_type].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color("dark"))
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
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .zIndex(2)
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.325)) {
                if stopWatchManager.currentSession != item {
                    stopWatchManager.currentSession = item
                }
            }
        }
        
        
        
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12, style: .continuous))
        
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
            CustomiseSessionView(sessionItem: item)
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

