import SwiftUI
import Foundation

struct SessionCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @State private var isShowingDeleteDialog = false
    @State private var isShowingCustomizeDialog = false
    
    @Binding var currentSession: Sessions
    var item: Sessions
    var allSessions: FetchedResults<Sessions>
    
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: colourScheme == .dark ? .systemGray4 : .systemGray5))
                .frame(height: item.pinned ? 110 : 65)
                .zIndex(0)
            
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colourScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .frame(width: currentSession == item ? 16 : UIScreen.screenWidth - 32, height: item.pinned ? 110 : 65)
                .offset(x: currentSession == item ? -((UIScreen.screenWidth - 16)/2) + 16 : 0)
            
                .zIndex(1)
            
            
        
            
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center, spacing: 0) {
                            ZStack {
                                if SessionTypes(rawValue: item.session_type)! != .standard {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(accentColour.opacity(0.33))
                                        .frame(width: 40, height: 40)
                                        .padding(.trailing, 12)
                                }
                                
                                switch SessionTypes(rawValue: item.session_type)! {
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
                                Text(item.name ?? "Unknown session name")
                                    .font(.title2.weight(.bold))
//                                    .foregroundColor(currentSession == item ? accentColour : (colourScheme == .dark ? Color.white : Color.black))
                                    .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                
                                Group {
                                    switch SessionTypes(rawValue: item.session_type)! {
                                    case .standard:
                                        Text(puzzle_types[Int(item.scramble_type)].name)
                                    case .playground:
                                        Text("Playground")
                                    case .multiphase:
                                        Text("Multiphase - \(puzzle_types[Int(item.scramble_type)].name)")
                                    case .compsim:
                                        Text("Comp Sim - \(puzzle_types[Int(item.scramble_type)].name)")
                                    default:
                                        EmptyView()
                                    }
                                }
                                .font(.subheadline.weight(.medium))
                                    .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
//                                .foregroundColor(currentSession == item ? accentColour : (colourScheme == .dark ? Color.white : Color.black))
                                .if(!item.pinned) { view in
                                    view.offset(y: -2)
                                }
                            }
                        }
                        
                        if item.pinned {
                            Spacer()
                            Text("\(item.solves?.count ?? -1) Solves")
                                .font(.subheadline.weight(.bold))
//                                .font(.system(size: 15, weight: .bold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                                .padding(.bottom, 4)
                        }
                    }
                    .offset(x: currentSession == item ? 10 : 0)
                    
                    Spacer()
                    
                    if item.session_type != SessionTypes.playground.rawValue {
                        if item.pinned {
                            Image(puzzle_types[Int(item.scramble_type)].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
//                                .foregroundColor(currentSession == item ? accentColour : (colourScheme == .dark ? Color.white : Color.black))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                .padding(.vertical, 4)
                                .padding(.trailing, 12)
                        } else {
                            Image(puzzle_types[Int(item.scramble_type)].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
//                                .foregroundColor(currentSession == item ? accentColour : (colourScheme == .dark ? Color.white : Color.black))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                .padding(.trailing, 6)
                        }
                    }
                    
                    
                }
                .padding(.leading)
                .padding(.trailing, item.pinned ? 6 : 4)
                .padding(.top, item.pinned ? 12 : 8)
                .padding(.bottom, item.pinned ? 12 : 8)
            }
            
            .frame(height: item.pinned ? 110 : 65)
            
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .zIndex(2)
            
            if currentSession == item {
                HStack {
                    Capsule()
                        .fill(accentColour.opacity(0.6))
                        .frame(width: 4, height: (item.pinned ? 110 * 0.5 : 65 * 0.6))
                    
                    Spacer()
                }
                .offset(x: 5.5)
                .zIndex(3)
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.325)) {
                currentSession = item
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
            
            ContextMenuButton(delay: true,
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
        
        .confirmationDialog(String("Are you sure you want to delete \"\(item.name ?? "Unknown session name")\"? All solves will be deleted and this cannot be undone."), isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                var next: Sessions? = nil
                for item in allSessions {
                    if item != currentSession {
                        next = item
                        break
                    }
                    /// **this should theoretically never happen, as the deletion option will be disabled if solves <= 1**
                    print("error: cannot find next session to replace current session")
                    
                }
                
                if let next = next {
                    withAnimation(.spring()) {
                        managedObjectContext.delete(item)
                        try! managedObjectContext.save()
                    }
                    
                    currentSession = next
                }
                
                
                
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

