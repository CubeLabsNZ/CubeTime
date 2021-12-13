//
//  StatsView.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import SwiftUI
import CoreData


struct NewStandardSessionViewBlocks: ViewModifier {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    func body(content: Content) -> some View {
        content
            .background(colorScheme == .light ? Color.white : Color(uiColor: .systemGray6))
            .cornerRadius(10)
            
            .padding(.trailing)
            .padding(.leading)
    }
}

struct CustomiseSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    @State private var name: String = ""
    
    @State private var sessionEventType: Int32 = 0
    
    
    @State var pinnedSession: Bool /// TODO: link to database
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    VStack (alignment: .center, spacing: 0) {
                        Image(puzzle_types[Int(sessionEventType)].name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.top)
                            .padding(.bottom)
                            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 4)
                            
                        
                        TextField("Session Name", text: $name)
                            .padding()
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                            
                    }
                    .frame(height: 220)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Session Event")
                                .font(.system(size: 17, weight: .medium))
                            
                            
                            Spacer()

                            Picker("", selection: $sessionEventType) {
                                    ForEach(Array(puzzle_types.enumerated()), id: \.offset) {index, element in
                                    Text(element.name).tag(Int32(index))
                                }
                            }
                            .pickerStyle(.menu)
                            .font(.system(size: 17, weight: .regular))
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    VStack (spacing: 0) {
                        LazyVGrid(columns: sessionEventTypeColumns, spacing: 0) {
                            ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                                Button {
                                    sessionEventType = Int32(index)
                                    
                                } label: {
                                    ZStack {
                                        Image("circular-" + element.name)
                                        
                                        Circle()
                                            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: (index == sessionEventType) ? 3 : 0)
                                            .frame(width: 54, height: 54)
                                            .offset(x: -0.2)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 180)
                    .modifier(NewStandardSessionViewBlocks())

                    VStack (spacing: 0) {
                        HStack {
                            Toggle(isOn: $pinnedSession) {
                                Text("Pin Session?")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .tint(.yellow)
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("Customise Session", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = Sessions(context: managedObjectContext)
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        NSLog("sessioneventyype is \(sessionEventType)")
                        sessionItem.scramble_type = sessionEventType
                        do {
                            try managedObjectContext.save()
                        } catch {
                            if let error = error as NSError? {
                                // Replace this implementation with code to handle the error appropriately.
                                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                
                                /*
                                 Typical reasons for an error here include:
                                 * The parent directory does not exist, cannot be created, or disallows writing.
                                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                                 * The device is out of space.
                                 * The store could not be migrated to the current model version.
                                 Check the error message to determine what the actual problem was.
                                 */
                                fatalError("Unresolved error \(error), \(error.userInfo)")
                            }
                        }
                        
                    } label: {
                        Text("Done")
                    }
                    .disabled(self.name.isEmpty)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}


@available(iOS 15.0, *)
struct NewStandardSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    
    @Binding var showNewSessionPopUp: Bool
    @Binding var currentSession: Sessions
    @State private var name: String = ""
    
    @State private var sessionEventType: Int32 = 0
    
    //@State private var sessionColour: Color?
    @State private var sessionColour: Color = .indigo
    
    @State var pinnedSession: Bool

    @Binding var currentSession: Sessions
    
    let sessionColors: [Color] = [.indigo, .purple, .pink, .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue]
    
    
    let sessionColorColumns = [
        //GridItem(.fixed(40))
        GridItem(.adaptive(minimum: 40)) /// TODO FIX ~~AND ALSO USE IN THE TIMES VIEW BECAUSE IT SHOULD DYNAMICALLY ADJUST FOR SMALLER SCREENS (FIXED 3 COLUMNS!)~~
    ]
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    
    var body: some View {
        ZStack {
            Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    
                    VStack (alignment: .center, spacing: 0) {
//                        Image(systemName: "square.fill")
                        Image(puzzle_types[Int(sessionEventType)].name)
//                            .font(.system(size: 120))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.top)
                            .padding(.bottom)
                            .shadow(color: .black.opacity(0.24), radius: 12, x: 0, y: 4)
                            
                        
                        TextField("Session Name", text: $name)
                            .padding()
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(uiColor: .systemGray5))
                            .cornerRadius(10)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                            
                    }
                    .frame(height: 220)
                    .modifier(NewStandardSessionViewBlocks())
                    /*
                    .background(Color.white)
                    .cornerRadius(10)
                    .frame(height: 220)
                    
                    .padding(.trailing)
                    .padding(.leading)
                    */
                    
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Session Event")
                                .font(.system(size: 17, weight: .medium))
                            
                            
                            Spacer()

                            Picker("", selection: $sessionEventType) {
                                    ForEach(Array(puzzle_types.enumerated()), id: \.offset) {index, element in
                                    Text(element.name).tag(Int32(index))

                                    //.foregroundColor(Color(uiColor: .systemGray4))
                                }
                            }
                            .pickerStyle(.menu)
                            .font(.system(size: 17, weight: .regular))


                            //Text("Square-1")
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    VStack (spacing: 0) {
                        LazyVGrid(columns: sessionEventTypeColumns, spacing: 0) {
                            ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                                Button {
                                    sessionEventType = Int32(index)


                                } label: {
                                    ZStack {
                                        Image("circular-" + element.name)
                                        
                                        Circle()
                                            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: (index == sessionEventType) ? 3 : 0)
                                            .frame(width: 54, height: 54)
                                            .offset(x: -0.2)
                                            
                                        
                                    }
                                    
//                                    Image("circular-Square-1")
//                                    Image("circular-Square-1-alt")
                                }


                            }
                            
                            
                        }
                        .padding()
                    }
                    .frame(height: 180)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    
                    

                    
                    VStack (spacing: 0) {
                        HStack {
                            //Text("Pin Session?")
                              //  .font(.system(size: 17, weight: .medium))
                            
                            
                            //Spacer()
                            
                            
                            Toggle(isOn: $pinnedSession) {
                                Text("Pin Session?")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .tint(.yellow)
                            
                            
                            //Text("Square-1")
                        }
                        .padding()
                    }
                    .frame(height: 45)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    Spacer()
                    
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle("New Standard Session", displayMode: .inline)
//            .ignoresSafeArea(.keyboard)
            //.navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let sessionItem = Sessions(context: managedObjectContext)
                        sessionItem.name = name
                        sessionItem.pinned = pinnedSession
                        NSLog("sessioneventyype is \(sessionEventType)")
                        sessionItem.scramble_type = sessionEventType
                        try! managedObjectContext.save()
                        currentSession = sessionItem
                        showNewSessionPopUp = false
                        currentSession = sessionItem
                        
                        
                    } label: {
                        Text("Create")
                    }
                    .disabled(self.name.isEmpty)
                }
            }
            
            
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

@available(iOS 15.0, *)
struct NewSessionPopUpView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colourScheme
    @State private var showNewStandardSessionView = false
    
    @State private var testBool = false
    
    @Binding var currentSession: Sessions
    @Binding var showNewSessionPopUp: Bool
    @Binding var currentSession: Sessions
    
    /*
     init(showNewSessionPopUp: Binding<Bool>) {
     //UITableView.appearance().separatorStyle = .none
     UITableViewCell.appearance().backgroundColor = .white
     UITableView.appearance().backgroundColor = .systemGray6
     
     //showNewSessionView = false
     //@Binding showNewSessionPopUp = false
     }
     */
    
    
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    VStack(alignment: .center) {
                        Text("Add New Session")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .padding(.bottom, 8)
                            .padding(.top, UIScreen.screenHeight/12)
                        Text("You can choose from four different types of sessions, out of the following: ")
                            .font(.system(size: 17, weight: .regular, design: .default))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Normal Sessions")
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .padding(.leading, 20)
                            .padding(.bottom, 8)
                        
                        HStack {
                            Image(systemName: "timer.square")
                                .font(.system(size: 30, weight: .regular))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                                .symbolRenderingMode(.hierarchical)
                                .padding(.leading, 8)
                                .padding(.trailing, 4)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                            Text("Standard Session")
                                .font(.system(size: 17, weight: .regular, design: .default))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                            //.padding(10)
                            Spacer()
                        }
                        
                        .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black))
                        .onTapGesture {
                            showNewStandardSessionView = true
                        }
                        .cornerRadius(10, corners: .topRight)
                        .cornerRadius(10, corners: .topLeft)
                        .padding(.leading)
                        .padding(.trailing)
                        
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(uiColor: .systemGray6))
                                .frame(height: 1)
                                .padding(.leading)
                                .padding(.trailing)
                            
                            Divider()
                                .padding(.leading, 64)
                                .padding(.trailing)
                        }
                        
                        
                        
                        HStack {
                            Image(systemName: "command.square")
                                .font(.system(size: 30, weight: .regular))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                                .symbolRenderingMode(.hierarchical)
                                .padding(.leading, 8)
                                .padding(.trailing, 4)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                            Text("Algorithm Trainer (WIP)")
                                .font(.system(size: 17, weight: .regular, design: .default))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                            
                            Spacer()
                        }
                        .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                                        .clipShape(Rectangle()))
                        .onTapGesture {
                            print("alg trainer pressed")
                        }
                        .padding(.leading)
                        .padding(.trailing)
                        
                        
                        ZStack {
                            Rectangle()
                                .fill(Color(uiColor: .systemGray6))
                                .frame(height: 1)
                                .padding(.leading)
                                .padding(.trailing)
                            //                            Divider()
                            ////                                .background(Color(UIColor.systemGray6))
                            //                                .background(Color.red)
                            //                                .padding(.leading)
                            //                                .padding(.trailing)
                            
                            
                            Divider()
                                .padding(.leading, 64)
                                .padding(.trailing)
                        }
                        
                        
                        
                        
                        HStack {
                            Image(systemName: "square.on.square")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                                .symbolRenderingMode(.hierarchical)
                                .padding(.leading, 8)
                                .padding(.trailing, 4)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                            Text("Playground (WIP)")
                                .font(.system(size: 17, weight: .regular, design: .default))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                            
                            Spacer()
                        }
                        .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black))
                        .onTapGesture {
                            print("playground pressed")
                        }
                        .cornerRadius(10, corners: .bottomRight)
                        .cornerRadius(10, corners: .bottomLeft)
                        .padding(.leading)
                        .padding(.trailing)
                        
                        
                        
                        
                        
                        Text("Other Sessions")
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .padding(.top, 48)
                            .padding(.leading, 20)
                            .padding(.bottom, 8)
                        
                        
                        
                        HStack {
                            Image(systemName: "globe.asia.australia")
                                .font(.system(size: 26, weight: .medium))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                                .symbolRenderingMode(.hierarchical)
                                .padding(.leading, 8)
                                .padding(.trailing, 4)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                            Text("Comp Sim Mode (WIP)")
                                .font(.system(size: 17, weight: .regular, design: .default))
                                .foregroundColor(colourScheme == .light ? .black : .white)
                            
                            Spacer()
                        }
                        .background(Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                                        .clipShape(RoundedRectangle(cornerRadius: 10)))
                        .onTapGesture {
                            print("comp sim pressed")
                        }
                        .padding(.leading)
                        .padding(.trailing)
                        
                        
                        NavigationLink("", destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp, pinnedSession: false, currentSession: $currentSession), isActive: $showNewStandardSessionView)
                        
                        /// TODO: **ADD NAV LINKS FOR ALL THE OTHER PAGES** and include for the on tap
                        
                        
                        /*
                         .onAppear { UITableView.appearance().isScrollEnabled = false }
                         .onDisappear{ UITableView.appearance().isScrollEnabled = true }
                         */
                        
                        
                        Spacer()
                        
                    }
                    
                    
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button {
                                print("new session view closed")
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 26, weight: .semibold))
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                                    .foregroundStyle(colourScheme == .light ? .black : .white)
                                    .padding(.top)
                                    .padding(.trailing)
                            }
                        }
                        Spacer()
                    }
                )
            }
        }
    }
}

@available(iOS 15.0, *)
struct ContextMenuButton: View {
    var action: () -> Void
    var title: String
    var systemImage: String? = nil
    var disableButton: Bool? = nil
    
    var body: some View {
        Button(role: title == "Delete Session" ? .destructive : nil, action: delayedAction) {
            HStack {
                Text(title)
                if image != nil {
                    Image(uiImage: image!)
                }
            }
        }.disabled(disableButton ?? false)
    }
    
    private var image: UIImage? {
        if let systemName = systemImage {
            let config = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .body), scale: .medium)
            
            return UIImage(systemName: systemName, withConfiguration: config)
        } else {
            return nil
        }
    }
    private func delayedAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.action()
        }
    }
}



@available(iOS 15.0, *)
struct SessionCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Binding var currentSession: Sessions
    @State private var isShowingDeleteDialog = false
    var item: Sessions
    var numSessions: Int
    
    @Namespace var namespace
    
    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color(UIColor.systemGray5))
//                .frame(height: item.pinned ? 110 : 65)
//                .padding(.leading)
//                .padding(.trailing)
//
//            HStack {
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color.white)
//                    .frame(width: currentSession == item ? 16 : UIScreen.screenWidth - 32, height: item.pinned ? 110 : 65)
//
//
//                    .matchedGeometryEffect(id: "bar", in: namespace, properties: .frame)
//                    .animation(.spring())
//
//
//                Spacer()
//            }
//            .padding(.leading)
//            .padding(.trailing)
//
//
//        }
        
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemGray5))
                .frame(height: item.pinned ? 110 : 65)
            
//                .animation(.spring(response: 0.325))
                .zIndex(0)
        
            
            RoundedRectangle(cornerRadius: 16)
                .fill(colourScheme == .dark ? Color(uiColor: .systemGray6) : Color.white)
                .frame(width: currentSession == item ? 16 : UIScreen.screenWidth - 32, height: item.pinned ? 110 : 65)
            
            
//                .matchedGeometryEffect(id: "bar", in: namespace, properties: .frame)
            
//                .animation(.spring(response: 0.325))
                .offset(x: currentSession == item ? -((UIScreen.screenWidth - 16)/2) + 16 : 0)
            
                .zIndex(1)
            
            
            
//                .offset(x: -((UIScreen.screenWidth-16)/2))
        
            
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        if item.pinned {
                            Text(item.name ?? "Unkown session name")
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                            Text(puzzle_types[Int(item.scramble_type)].name)
        //                        .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                            Spacer()
                            Text("\(item.solves?.count ?? -1) Solves")
                                .font(.system(size: 15, weight: .bold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                                .padding(.bottom, 4)
                        } else {
                            Text(item.name ?? "Unkown session name")
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                            Text(puzzle_types[Int(item.scramble_type)].name)
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(colourScheme == .dark ? Color.white : Color.black)
                        }
                    }
                    .offset(x: currentSession == item ? 10 : 0)
                    
                    Spacer()
                    
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
                .padding(.leading)
                .padding(.trailing, item.pinned ? 6 : 4)
                .padding(.top, item.pinned ? 12 : 8)
                .padding(.bottom, item.pinned ? 12 : 8)
            }
            
            .frame(height: item.pinned ? 110 : 65)
        
//            .background(currentSession == item ? Color.clear : Color.white)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .zIndex(2)
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        
//        .animation(.spring())
        .onTapGesture {
            withAnimation(.spring(response: 0.325)) {
                currentSession = item
            }
        }
        
        .contextMenu(menuItems: {
            ContextMenuButton(action: {
                print("customise pressed")
                
            },
                              title: "Customise",
                              systemImage: "pencil");
            ContextMenuButton(action: {
                withAnimation(.spring()) {
                    item.pinned.toggle()
                    try! managedObjectContext.save()
                }
            },
                              title: item.pinned ? "Unpin" : "Pin",
                              systemImage: item.pinned ? "pin.slash" : "pin");
            Divider()
            
            ContextMenuButton(action: {
                isShowingDeleteDialog = true
            },
                              title: "Delete Session",
                              systemImage: "trash",
                              disableButton: numSessions <= 1)
                .foregroundColor(Color.red)
        })
        .padding(.trailing)
        .padding(.leading)
        
                
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

        
        
        
        
//        .contextMenu {
//            Button {
//                print("Customise pressed")
//            } label: {
//                Label("Customise", systemImage: "pencil")
//            }
//
//            Button {
//                item.pinned.toggle()
//                try! managedObjectContext.save()
//            } label: {
//                Label(item.pinned ? "Unpin" : "Pin", systemImage: item.pinned ? "pin.slash" : "pin") /// TODO: add custom icons because no good icons
//            }
//
//            Divider()
//
//            Button (role: .destructive) {
//                print("session delete pressed")

//            } label: {
//                Label {
//                    Text("Delete Session")
//                        .foregroundColor(Color.red)
//                } icon: {
//                    Image(systemName: "trash")
//                        .foregroundColor(Color.green) /// FIX: colours not working
//                }
//            }
//        }
        
        
    }
}


@available(iOS 15.0, *)
struct SessionsView: View {
    @Binding var currentSession: Sessions
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    
    @State var showNewSessionPopUp = false
    
    
    var solveCount: Int = 1603
    
    
    
    // I know that this is bad
    // I tried to use SectionedFetchRequest to no avail
    // send a PR if you can make this good :)
    @FetchRequest(
        entity: Sessions.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Sessions.name, ascending: true)
        ],
        predicate: NSPredicate(format: "pinned == YES")
    ) var pinnedSessions: FetchedResults<Sessions>
    
    @FetchRequest(
        entity: Sessions.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Sessions.name, ascending: true)
        ],
        predicate: NSPredicate(format: "pinned == NO")
    ) var unPinnedSessions: FetchedResults<Sessions>
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black) 
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack (spacing: 10) {
                        ForEach(pinnedSessions) { item in
                            SessionCard(currentSession: $currentSession, item: item, numSessions: pinnedSessions.count + unPinnedSessions.count)
                                .environment(\.managedObjectContext, managedObjectContext)
                                
                        }
                        ForEach(unPinnedSessions) { item in
                            SessionCard(currentSession: $currentSession, item: item, numSessions: pinnedSessions.count + unPinnedSessions.count)
                                .environment(\.managedObjectContext, managedObjectContext)
                                
                        }
                    }
                }
                .navigationTitle("Your Sessions")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("button tapped")
                        } label: {
                            Text("Edit")
                        }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
                
                
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            showNewSessionPopUp = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .padding(.leading, -4)
                            Text("New Session")
                                .font(.system(size: 18, weight: .medium))
                        }
                        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 3)
                        .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 0.5))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .background(.ultraThinMaterial, in: Capsule())
                        .sheet(isPresented: $showNewSessionPopUp) {
                            NewSessionPopUpView(showNewSessionPopUp: $showNewSessionPopUp, currentSession: $currentSession)
                                .environment(\.managedObjectContext, managedObjectContext)
                        }
                        .padding(.leading)
                        .padding(.bottom, 8)
                        
                        Spacer()
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12).fill(Color.clear).frame(height: 50).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
            }
        }
    }
}

