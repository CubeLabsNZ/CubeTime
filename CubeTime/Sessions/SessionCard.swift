import SwiftUI
import Foundation

struct SessionCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @Binding var currentSession: Sessions
    @State private var isShowingDeleteDialog = false
    @State var customizing = false
    var item: Sessions
    var numSessions: Int
    
    private let windowSize = UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                                (scene as? UIWindowScene)?.keyWindow
                            }).first?.frame.size
    
    @Namespace var namespace
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemGray5))
                .frame(height: item.pinned ? 110 : 65)
                .zIndex(0)
            
            
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(colourScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .frame(width: currentSession == item ? 16 : windowSize!.width - 32, height: item.pinned ? 110 : 65)
                .offset(x: currentSession == item ? -((windowSize!.width - 16)/2) + 16 : 0)
            
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
                            
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(item.name ?? "Unkown session name")
                                    .font(.system(size: 22, weight: .bold, design: .default))
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
                                .font(.system(size: item.pinned ? 15 : 16, weight: item.pinned ? .medium : .regular, design: .default))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                .if(!item.pinned) { view in
                                    view.offset(y: -2)
                                }
                            }
                        }
                        
                        if item.pinned {
                            Spacer()
                            Text("\(item.solves?.count ?? -1) Solves")
                                .font(.system(size: 15, weight: .bold, design: .default))
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
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                                .padding(.top, 4)
                                .padding(.bottom, 4)
                                .padding(.trailing, 12)
                        } else {
                            Image(puzzle_types[Int(item.scramble_type)].name)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
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
        }
//        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        
        .onTapGesture {
            withAnimation(.spring(response: 0.325)) {
                currentSession = item
            }
        }
        
        .sheet(isPresented: $customizing) {
            CustomiseStandardSessionView(sessionItem: item)
        }
        
        .contextMenu(menuItems: {
            ContextMenuButton(delay: false,
                              action: { customizing = true },
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
            
            ContextMenuButton(delay: true, action: {
                isShowingDeleteDialog = true
            },
                              title: "Delete Session",
                              systemImage: "trash",
                              disableButton: numSessions <= 1 || item == currentSession)
                .foregroundColor(Color.red)
        })
        .padding(.horizontal)
        
        
        .confirmationDialog(String("Are you sure you want to delete \"\(item.name ?? "Unknown session name")\"? All solves will be deleted and this cannot be undone."), isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
            Button("Confirm", role: .destructive) {
                withAnimation(.spring()) {
                    managedObjectContext.delete(item)
                    try! managedObjectContext.save()
                }
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
    }
}

