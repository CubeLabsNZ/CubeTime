import SwiftUI
import Foundation


struct SessionCardBase: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @ScaledMetric private var pinnedSessionHeight: CGFloat = 110
    @ScaledMetric private var regularSessionHeight: CGFloat = 65
    
    var item: Session
    
    let pinned: Bool
    let sessionType: SessionType
    let name: String
    let scrambleType: Int
    let solveCount: Int
    
    let forExportUse: Bool
    
    var selected: Bool
    
    init(item: Session, pinned: Bool, sessionType: SessionType, name: String, scrambleType: Int, solveCount: Int, selected: Bool, forExportUse: Bool=false) {
        self.item = item
        
        self.pinned = pinned
        self.sessionType = sessionType
        self.name = name
        self.scrambleType = scrambleType
        self.solveCount = solveCount
        
        self.selected = selected
        
        self.forExportUse = forExportUse
    }
    
    @Namespace var namespace
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(name)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(Color("dark"))
                    
                    HStack(spacing: 4) {
                        CTSessionBubble(session: item)
                    }
                }
                
                if pinned {
                    Spacer()
                    
                    CTBubble(type: .coloured(nil), size: .bubble, hasMaterial: false) {
                        Text("\(solveCount) Solves")
                            .padding(.horizontal, 2)
                    }
                }
            }
            .padding(.leading, self.selected && !self.forExportUse ? 24 : 10)
            .padding(.vertical, 10)
            .offset(y: -1)
            
            Spacer()
            
            if !forExportUse {
                Image(PUZZLE_TYPES[scrambleType].imageName)
                    .resizable()
                    .frame(width: 45, height: 45)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("dark"))
                    .padding([.vertical, .trailing], 10)
                    .frame(maxHeight: .infinity, alignment: .topTrailing)
            } else if selected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("accent"), Color("overlay0"))
                    .padding(.trailing, 24)
            }
        }
        
        
        .frame(height: pinned ? pinnedSessionHeight : regularSessionHeight, alignment: .center)
        
        .background(
            Group {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color("indent1"))
                    .frame(height: pinned ? pinnedSessionHeight : regularSessionHeight)
                
                if (forExportUse) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("overlay0"))
                        .frame(width: nil,
                               height: item.pinned ? pinnedSessionHeight : regularSessionHeight)
                        .opacity(selected ? 0 : 1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("overlay0"))
                        .frame(width: selected ? 16 : nil,
                               height: item.pinned ? pinnedSessionHeight : regularSessionHeight)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .shadowDark(x: 1, y: 0)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


struct SessionCard: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var isShowingDeleteDialog = false
    @State private var isShowingCustomizeDialog = false
    
    
    var item: Session
    var allSessions: FetchedResults<Session>
    
    init (item: Session, allSessions: FetchedResults<Session>) {
        self.item = item
        self.allSessions = allSessions
    }
    
    var body: some View {
        SessionCardBase(item: item,
                        pinned: item.pinned,
                        sessionType: SessionType(rawValue: item.sessionType)!,
                        name: item.name ?? "Unknown session name",
                        scrambleType: Int(item.scrambleType),
                        solveCount: item.solves?.count ?? -1,
                        selected: item == stopwatchManager.currentSession)
        
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
                              title: String(localized: "Customise"),
                              systemImage: "pencil", disableButton: false);
            
            ContextMenuButton(delay: true,
                              action: {
                withAnimation(Animation.customDampedSpring) {
                    item.pinned.toggle()
                    try! managedObjectContext.save()
                }
            },
                              title: item.pinned ? String(localized: "Unpin") : String(localized: "Pin"),
                              systemImage: item.pinned ? "pin.slash" : "pin", disableButton: false);
            Divider()
            
            ContextMenuButton(delay: false,
                              action: { isShowingDeleteDialog = true },
                              title: String(localized: "Delete Session"),
                              systemImage: "trash",
                              disableButton: allSessions.count <= 1)
            .foregroundColor(Color.red)
        })
        .padding(.horizontal)
        
        .sheet(isPresented: $isShowingCustomizeDialog) {
            CustomiseSessionView(sessionItem: item)
                .tint(Color("accent"))
        }
        
        .confirmationDialog(String(localized: "Are you sure you want to delete \"\(self.item.name ?? "this session")\"? All solves will be deleted and this cannot be undone."), isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
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
