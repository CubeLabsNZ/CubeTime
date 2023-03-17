import SwiftUI
import Foundation

struct SessionCard: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @State private var isShowingDeleteDialog = false
    @State private var isShowingCustomizeDialog = false
    
    @ScaledMetric private var pinnedSessionHeight: CGFloat = 110
    @ScaledMetric private var regularSessionHeight: CGFloat = 65
    
    
    var item: Session
    var allSessions: FetchedResults<Session>
    
    let pinned: Bool
    let sessionType: SessionType
    let name: String
    let scrambleType: Int
    let solveCount: Int
    
    @Namespace var namespace
    
    init (item: Session, allSessions: FetchedResults<Session>) {
        self.item = item
        self.allSessions = allSessions
        
        // Copy out the things so that it won't change to null coalesced defaults on deletion
        self.pinned = item.pinned
        self.sessionType = SessionType(rawValue: item.sessionType)!
        self.name = item.name ?? "Unknown session name"
        self.scrambleType = Int(item.scrambleType)
        self.solveCount = item.solves?.count ?? -1
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 0) {
                    Group {
                        switch sessionType {
                        case .algtrainer:
                            Image(systemName: "command.square")
                                .font(.system(size: 26, weight: .semibold))
                            
                        case .playground:
                            Image(systemName: "square.on.square")
                                .font(.system(size: 22, weight: .semibold))
                            
                        case .multiphase:
                            Image(systemName: "square.stack")
                                .font(.system(size: 22, weight: .semibold))
                            
                        case .compsim:
                            Image(systemName: "globe.asia.australia")
                                .font(.system(size: 26, weight: .bold))
                            
                        default:
                            EmptyView()
                        }
                    }
                    .foregroundColor(Color("accent"))
                    .padding(.trailing, 12)
                    .background( Group {
                        if sessionType != .standard {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color("accent").opacity(0.33))
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 12)
                        }
                    })
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(name)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(Color("dark"))
                        
                        Group {
                            switch sessionType {
                            case .standard:
                                Text(puzzleTypes[scrambleType].name)
                            case .playground:
                                Text("Playground")
                            case .multiphase:
                                Text("Multiphase - \(puzzleTypes[scrambleType].name)")
                            case .compsim:
                                Text("Comp Sim - \(puzzleTypes[scrambleType].name)")
                            default:
                                EmptyView()
                            }
                        }
                        .font(.subheadline.weight(.regular))
                        .foregroundColor(Color("dark"))
                        .offset(y: pinned ? 0 : -2)
                    }
                }
                
                if pinned {
                    Spacer()
                    
                    Text("\(solveCount) Solves")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color("grey"))
                        .padding(.bottom, 4)
                }
            }
            .offset(x: stopwatchManager.currentSession == item ? 10 : 0)
            
            Spacer()
            
            if (sessionType != .playground) {
                Image(puzzleTypes[scrambleType].name)
                    .resizable()
                    .frame(width: item.pinned ? nil : 40, height: item.pinned ? nil : 40)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("dark"))
                    .padding(.trailing, item.pinned ? 12 : 8)
                    .padding(.vertical, item.pinned ? 6 : 0)
            }
        }
        .padding(.leading)
        .padding(.trailing, pinned ? 6 : 4)
        .padding(.vertical, pinned ? 12 : 8)
        
        .frame(height: pinned ? pinnedSessionHeight : regularSessionHeight)
        
        .background( Group {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("indent1"))
                .frame(height: pinned ? pinnedSessionHeight : regularSessionHeight)
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color("overlay0"))
                .frame(width: stopwatchManager.currentSession == item ? 16 : nil,
                       height: item.pinned ? pinnedSessionHeight : regularSessionHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        })
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            withAnimation(Animation.customDampedSpring) {
                if stopwatchManager.currentSession != item {
                    stopwatchManager.currentSession = item
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
                withAnimation(Animation.customDampedSpring) {
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
                .tint(Color("accent"))
        }
        
        .confirmationDialog(String("Are you sure you want to delete \"\(name)\"? All solves will be deleted and this cannot be undone."), isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                if item == stopwatchManager.currentSession {
                    var next: Session? = nil
                    for item in allSessions {
                        if item != stopwatchManager.currentSession {
                            next = item
                            break
                        }
                    }
                    
                    if let next = next {
                        withAnimation(Animation.customDampedSpring) {
                            stopwatchManager.currentSession = next
                        }
                    }
                }
                
                withAnimation(Animation.customDampedSpring) {
                    managedObjectContext.delete(item)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
