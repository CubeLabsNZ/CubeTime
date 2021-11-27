//
//  StatsView.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import SwiftUI

@available(iOS 15.0, *)
class UserSessions {
    @State static var session = [1, 2]
}

@available(iOS 15.0, *)
struct NewStandardSessionView: View {
    var body: some View {
        Text("yuou do no t have choice just use this session for now :)")
        
        Button {
            UserSessions.$session.append("session")
            
        } label: {
            Text("create")
            //.font(.system(size: 17, weight: .medium))
            //.foregroundColor(Color.red)
        }
    }
}

@available(iOS 15.0, *)
struct NewSessionPopUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showNewSessionView = true
    
    var body: some View {
        VStack {
            Button("go back") {
                dismiss()
            }
            Text("Add New Session")
            Text("You can choose from four different types of sessions, out of the following: ")
            
            NavigationView {
                List {
                    Section(header: Text("Normal Sessions")) {
                        NavigationLink(
                            "next",
                            destination: NewStandardSessionView(),
                            isActive: $showNewSessionView)
                        
                        
                        
                        
                        Text("thing1")
                        Text("thing1")
                    }
                }
                .listStyle(.insetGrouped)
            }
            
            
            List {
                Section(header: Text("Normal Sessions")) {
                    Text("thing1")
                    Text("thing1")
                    Text("thing1")
                }
            }
            .listStyle(.insetGrouped)
            
            
            
            Spacer()
            
        }
    }
}



@available(iOS 15.0, *)
struct SessionsView: View {
    
    @State var showNewSessionPopUp: Bool
    
    
    
    
    var solveCount: Int = 1603
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    VStack (spacing: 10) {
                        ForEach(UserSessions.session, id: \.self) { item in
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item)
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
                        }
                    }
                    
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("squan after nic")
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
                        NewSessionPopUpView()
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

