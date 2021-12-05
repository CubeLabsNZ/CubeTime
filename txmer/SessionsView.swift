//
//  StatsView.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import SwiftUI
import CoreData

struct NewStandardSessionViewBlocks: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(10)
            
            .padding(.trailing)
            .padding(.leading)
    }
}


@available(iOS 15.0, *)
struct NewStandardSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var showNewSessionPopUp: Bool
    @State private var name: String = ""
    
    @State private var sessionEventType = "3x3"
    
    //@State private var sessionColour: Color?
    @State private var sessionColour: Color = .indigo
    
    @State var pinnedSession: Bool /// TODO: link to database
    
    let allEventTypes = ["3x3": "3x3", "2x2": "2x2", "4x4": "4x4", "5x5": "5x5", "6x6": "6x6", "7x7": "7x7", "Square-1": "square-1", "Pyraminx": "pyra", "Skewb": "skewb", "Clock": "clock", "Megaminx": "mega", "OH": "oh", "3x3 Blindfolded": "3bld", "4x4 Blindfolded": "4bld", "5x5 Blindfolded": "5bld"]
    
    let sessionColors: [Color] = [.indigo, .purple, .pink, .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue]
    
    
    let sessionColorColumns = [
        //GridItem(.fixed(40))
        GridItem(.adaptive(minimum: 40)) /// TODO FIX ~~AND ALSO USE IN THE TIMES VIEW BECAUSE IT SHOULD DYNAMICALLY ADJUST FOR SMALLER SCREENS (FIXED 3 COLUMNS!)~~
    ]
    
    let sessionEventTypeColumns = [GridItem(.adaptive(minimum: 40))]
    
    
    var body: some View {
        
        
        
        
        
        
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 16) {
                    
                    VStack (alignment: .center, spacing: 0) {
                        Image(systemName: "square.fill")
                            .font(.system(size: 120))
                            .padding(.top, 8)
                            .padding(.bottom, 8)
                            .shadow(color: .black.opacity(0.16), radius: 12, x: 0, y: 3)
                            
                        
                        TextField("Session Name", text: $name)
                            .padding()
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(TextAlignment.center)
                            .background(Color(UIColor.systemGray5))
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
                        LazyVGrid(columns: sessionEventTypeColumns, spacing: 10) {
                            ForEach(allEventTypes.sorted(by: >), id: \.key) { event, icon in
                                Button {
                                    sessionEventType = icon
                                    
                                    
                                } label: {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 40))
                                }
                                
                                
                            }
                            
                        }
                        .padding()
                    }
                    .frame(height: 130)
                    .modifier(NewStandardSessionViewBlocks())
                    
                    
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Session Event")
                                .font(.system(size: 17, weight: .medium))
                            
                            
                            Spacer()
                            
                            Picker("", selection: $sessionEventType) {
//                                ForEach(allEventTypes, id: \.self) {
//                                    Text($0)
//
//                                        //.foregroundColor(Color(UIColor.systemGray4))
//                                }
                                
                                Text("1")
                                Text("2")
                                Text("3")
                                Text("4")
                                Text("5")
                                Text("6")
                                
                            }
                            .pickerStyle(.menu)
                            .font(.system(size: 17, weight: .regular))
                            .accentColor(Color(UIColor.systemGray))
                            
                            
                            //Text("Square-1")
                        }
                        .padding()
                    }
                    .frame(height: 45)
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
                    
                    VStack (spacing: 0) {
                        LazyVGrid(columns: sessionColorColumns, spacing: 10) {
                            ForEach(sessionColors, id: \.self) { colour in
                                Button {
                                    sessionColour = colour
                                    
                                    
                                } label: {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(colour)
                                        .font(.system(size: 40))
                                }
                                
                                
                            }
                            
                        }
                        .padding()
                    }
                    .frame(height: 130)
                    .modifier(NewStandardSessionViewBlocks())
            
                    Text("current colour selected")
                        .foregroundColor(sessionColour)
                    
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
                        
                        showNewSessionPopUp = false
                        
                    } label: {
                        Text("Create") /// TODO: make so when there is no text in the textfield grey out the create button
                        //.font(.system(size: 17, weight: .medium))
                        //.foregroundColor(Color.red)
                    }
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
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}


@available(iOS 15.0, *)
struct NewSessionPopUpView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @State private var showNewSessionView = false
    
    @State private var testBool = false
    
    @Binding var showNewSessionPopUp: Bool
    
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
                    HStack {
                        Spacer()
                        
                        Button {
                            print("new session view closed")
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.black)
                                .padding(.top)
                                .padding(.trailing)
                        }
                    }
                    
                    
                    VStack(alignment: .center) {
                        Text("Add New Session")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .padding(.bottom, 8)
                            .padding(.top, 36)
                        Text("You can choose from four different types of sessions, out of the following: ")
                            .font(.system(size: 17, weight: .regular, design: .default))
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                    }
                    
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Normal Sessions")
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .padding(.leading, 20)
                            .padding(.bottom, 8)
                        
                        NavigationLink(destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp, pinnedSession: false)) {
                            Button {
                                showNewSessionView.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "timer.square")
                                        .font(.system(size: 30, weight: .regular))
                                        .foregroundColor(.black)
                                        .symbolRenderingMode(.hierarchical)
                                        .padding(.leading, 8)
                                        .padding(.trailing, 4)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                    Text("Standard Session")
                                        .font(.system(size: 17, weight: .regular, design: .default))
                                        .foregroundColor(.black)
                                        //.padding(10)
                                    Spacer()
                                }
                            }
//                            .background(Color(UIColor.systemGray6).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)))
                            .background(Color(UIColor.systemGray6))

                            .cornerRadius(10, corners: .topRight)
                            .cornerRadius(10, corners: .topLeft)
                            .padding(.leading)
                            .padding(.trailing)
                        
                        }
                        
                        Divider()
                            .padding(.leading, 64)
                            .padding(.trailing)
                        
                        NavigationLink(destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp, pinnedSession: false)) {
                            Button {
                                showNewSessionView.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "command.square")
                                        .font(.system(size: 30, weight: .regular))
                                        .foregroundColor(.black)
                                        .symbolRenderingMode(.hierarchical)
                                        .padding(.leading, 8)
                                        .padding(.trailing, 4)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                    Text("Algorithm Trainer (WIP)")
                                        .font(.system(size: 17, weight: .regular, design: .default))
                                        .foregroundColor(.black)
                                        
                                    Spacer()
                                }
                            }
                            .background(Color(UIColor.systemGray6)
                                            .clipShape(Rectangle()))
                            .padding(.leading)
                            .padding(.trailing)
                            
                        }
                        
                        Divider()
                            .padding(.leading, 64)
                            .padding(.trailing)
                        
                        NavigationLink(destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp, pinnedSession: false)) {
                            Button {
                                showNewSessionView.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "square.on.square")
                                        .font(.system(size: 26, weight: .medium))
                                        .foregroundColor(.black)
                                        .symbolRenderingMode(.hierarchical)
                                        .padding(.leading, 8)
                                        .padding(.trailing, 4)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                    Text("Playground (WIP)")
                                        .font(.system(size: 17, weight: .regular, design: .default))
                                        .foregroundColor(.black)
                                        
                                    Spacer()
                                }
                            }
                            .background(Color(UIColor.systemGray6))

                            .cornerRadius(10, corners: .bottomRight)
                            .cornerRadius(10, corners: .bottomLeft)
                            .padding(.leading)
                            .padding(.trailing)
                            
                        }
                        
                        
                        Text("Other Sessions")
                            .font(.system(size: 22, weight: .bold, design: .default))
                            .padding(.top, 48)
                            .padding(.leading, 20)
                            .padding(.bottom, 8)
                        
                        NavigationLink(destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp, pinnedSession: false)) {
                            Button {
                                showNewSessionView.toggle()
                                NSLog(String(showNewSessionPopUp))
                                NSLog(String(testBool))
                            } label: {
                                HStack {
                                    Image(systemName: "globe.asia.australia")
                                        .font(.system(size: 26, weight: .medium))
                                        .foregroundColor(.black)
                                        .symbolRenderingMode(.hierarchical)
                                        .padding(.leading, 8)
                                        .padding(.trailing, 4)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                    Text("Comp Sim Mode (WIP)")
                                        .font(.system(size: 17, weight: .regular, design: .default))
                                        .foregroundColor(.black)
                                        
                                    Spacer()
                                }
                            }
                            .background(Color(UIColor.systemGray6)
                                            .clipShape(RoundedRectangle(cornerRadius: 10)))

                            .padding(.leading)
                            .padding(.trailing)
                            
                        }
                        
                        
                    }
                    
                    
                    
                    
                    NavigationLink("", destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp, pinnedSession: false), isActive: $showNewSessionView)
                    
                    
                    /*
                     .onAppear { UITableView.appearance().isScrollEnabled = false }
                     .onDisappear{ UITableView.appearance().isScrollEnabled = true }
                     */
                    
                    
                    Spacer()
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
                
                
                
            }
            
            /*
             .toolbar {
             ToolbarItem(placement: .navigationBarTrailing) {
             Button {
             print("new session view closed")
             dismiss()
             } label: {
             Image(systemName: "xmark.circle.fill")
             .font(.system(size: 22, weight: .semibold))
             .symbolRenderingMode(.hierarchical)
             .padding(.top)
             .padding(.trailing)
             
             }
             }
             
             }
             */
            
            
            //Spacer()
        }
    }
}

@available(iOS 15.0, *)
struct SessionCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var currentSession: Sessions?
    
    
    @State private var isShowingDeleteDialog = false
    var item: Sessions
    
    var body: some View {
        Button {
            print("Setting current sesion to \(item)")
            NSLog("Its context is \(item.managedObjectContext)")
            NSLog("managedObjectContext is \(managedObjectContext)")
            currentSession = item
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name ?? "Unkown session name")
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .foregroundColor(Color.black)
                    Text("Square-1")
                        .font(.system(size: 15, weight: .medium, design: .default))
                        .foregroundColor(Color.black)
                    Spacer()
                    Text("\(item.solves?.count ?? -1) Solves")
                        .font(.system(size: 15, weight: .bold, design: .default))
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding(.bottom, 4)
                }
                
                Spacer()
                
                Image(systemName: "square.fill")
                    .font(.system(size: 90))
                    .foregroundColor(Color.black)
                //.padding(.trailing, -12)
                
            }
            .padding(.leading)
            .padding(.trailing, 6)
            .padding(.top, 12)
            .padding(.bottom, 12)
            
        }
        .frame(height: 110)
        .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
        
        
        
        
        
        
        .contextMenu {
            
            Button {
                print("Customise pressed")
            } label: {
                Label("Customise", systemImage: "pencil")
            }
            
            //                                       Divider()
            
            Button {
                print("Pin pressed")
            } label: {
                Label("Pin", systemImage: "pin") /// TODO: add custom icons because no good icons
            }
            
            Divider()
            
            Button (role: .destructive) {
                print("session delete pressed")
                isShowingDeleteDialog.toggle()
            } label: {
                Label {
                    Text("Delete Session")
                        .foregroundColor(Color.red)
                } icon: {
                    Image(systemName: "trash")
                        .foregroundColor(Color.green) /// FIX: colours not working
                }
            }
            
            
            
        }
        
        .confirmationDialog("Are you sure you want to delete this session? All solves will be deleted and this cannot be undone.", isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
            let _ = NSLog("Confimation Dialog for \(item.name), presented: \(isShowingDeleteDialog)")
            Button("Confirm", role: .destructive) {
                managedObjectContext.delete(item)
                NSLog("\(item.name)")
                do {
                    try managedObjectContext.save()
                } catch {
                    if let error = error as NSError? {
                        // Replace this implementation with code to handle the error appropriately.
                        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                        fatalError("Unresolved error \(error), \(error.userInfo)")
                    }
                }
            }
            Button("Cancel", role: .cancel) {
                
            }
        }
        
        
        .padding(.trailing)
        .padding(.leading)
    }
}


@available(iOS 15.0, *)
struct SessionsView: View {
    @Binding var currentSession: Sessions?
    @Environment(\.managedObjectContext) var managedObjectContext
    
    
    @State var showNewSessionPopUp = false
    
    var solveCount: Int = 1603
    
    
    
    
    @FetchRequest(
        entity: Sessions.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Sessions.name, ascending: true)
        ]
    ) var sessions: FetchedResults<Sessions>
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    VStack (spacing: 10) {
                        ForEach(sessions, id: \.self) { item in
                            SessionCard(currentSession: $currentSession, item: item)
                                .environment(\.managedObjectContext, managedObjectContext)
                        }
                    }
                    
                    /*
                     VStack {
                     HStack {
                     VStack(alignment: .leading) {
                     Text("3x3 main session")
                     .font(.system(size: 22, weight: .bold, design: .default))
                     Text("3x3")
                     .font(.system(size: 15, weight: .medium, design: .default))
                     }
                     
                     Spacer()
                     
                     Image(systemName: "square.fill")
                     .font(.system(size: 44))
                     .padding(.trailing, 6)
                     
                     }
                     .padding(.leading)
                     .padding(.trailing, 4)
                     .padding(.top, 8)
                     .padding(.bottom, 8)
                     
                     }
                     .frame(height: 65)
                     .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                     .padding(.trailing)
                     .padding(.leading)
                     */ /// only keeping for the sizing
                    
                    
                    
                }
                .navigationTitle("Your Sessions")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("button tapped")
                        } label: {
                            Text("Edit")
                            //.font(.system(size: 17, weight: .medium))
                            //.foregroundColor(Color.red)
                        }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .frame(height: 50)
                    
                }
                
                
                VStack {
                    Spacer()
                    
                    HStack {
                        
                        
                        ZStack {
                            //Color.teal
                            
//                            Button {
//
//                            } label: {
//                                Image(systemName: "plus.circle.fill")
//                                    .font(.system(size: 24, weight: .semibold))
//                                    .padding(.leading, -4)
//                                    .foregroundColor(Color.clear)
//                                Text("New Session")
//                                    .font(.system(size: 18, weight: .medium))
//                                    .foregroundColor(Color.clear)
//                            }
//                            .buttonStyle(.bordered)
//                            .controlSize(.small)
//                            .background(Color.blue.opacity(0.3), in: Capsule())
                            
                            Button {
                                showNewSessionPopUp.toggle()
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
                        }
                        
//                        .background(VisualEffectBlurView(blurStyle: .dark), in: Capsule())
                        
                        .sheet(isPresented: $showNewSessionPopUp) {
                            NewSessionPopUpView(showNewSessionPopUp: $showNewSessionPopUp)
                                .environment(\.managedObjectContext, managedObjectContext)
                            //NewSessionPopUpView()
                        }
                        
                        //                        .padding(.top, 64)
                        .padding(.leading)
                        //                        .padding(.trailing)
                        .padding(.bottom, 8)
                        
                        Spacer()
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .frame(height: 50 + (SetValues.hasBottomBar ? 0 : CGFloat(SetValues.marginBottom)))
                }
            }
        }
    }
}

