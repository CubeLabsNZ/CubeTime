//
//  StatsView.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import SwiftUI
import CoreData

@available(iOS 15.0, *)
struct NewStandardSessionView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Binding var showNewSessionPopUp: Bool
    @State private var name: String = ""
    
    var body: some View {
        Text("just pick name tim cant make textfield")
        
        TextField("name", text: $name)
        
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
            Text("create")
            //.font(.system(size: 17, weight: .medium))
            //.foregroundColor(Color.red)
        }
    }
}

@available(iOS 15.0, *)
struct NewSessionPopUpView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @State private var showNewSessionView = false
    
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
                    
                    
                    
                    
                    List {
                        
                        NavigationLink("Standard Session", destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewSessionView)
                        NavigationLink("Algorithm Trainer DO NOT CLICK RN", destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewSessionView)
                        NavigationLink("Playground DO NOT CLICK RN", destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewSessionView)
                        
                        NavigationLink("Comp Sim Mode DO NOT CLICK", destination: NewStandardSessionView(showNewSessionPopUp: $showNewSessionPopUp), isActive: $showNewSessionView)
                        
                        Text("hi")
                        Text("hi")
                        Text("hi")
                        Text("hi")
                        Text("hi")
                        
                    }
                    
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
struct SessionsView: View {
    @Binding var currentSession: Sessions
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
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name ?? "Unkown session name")
                                            .font(.system(size: 22, weight: .bold, design: .default))
                                        Text("Square-1")
                                            .font(.system(size: 15, weight: .medium, design: .default))
                                        Spacer()
                                        Text("\(solveCount) Solves")
                                            .font(.system(size: 15, weight: .bold, design: .default))
                                            .foregroundColor(Color(UIColor.systemGray))
                                            .padding(.bottom, 4)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "square.fill")
                                        .font(.system(size: 90))
                                    //.padding(.trailing, -12)
                                    
                                }
                                .padding(.leading)
                                .padding(.trailing, 4)
                                .padding(.top, 8)
                                .padding(.bottom, 8)
                                
                            }
                            .frame(height: 110)
                            .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                            .padding(.trailing)
                            .padding(.leading)
                            .onTapGesture {
                                print("Setting current sesion to \(item)")
                                NSLog("Its context is \(item.managedObjectContext)")
                                NSLog("managedObjectContext is \(managedObjectContext)")
                                currentSession = item
                            }
                        }
                    }
                    
                    // only keeping because i think this is unpineneds size
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
                    
                    
                    Button("+ New Session") {
                        showNewSessionPopUp.toggle()
                    }
                    .sheet(isPresented: $showNewSessionPopUp) {
                        NewSessionPopUpView(showNewSessionPopUp: $showNewSessionPopUp)
                            .environment(\.managedObjectContext, managedObjectContext)
                        //NewSessionPopUpView()
                    }
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
            }
        }
    }
}

