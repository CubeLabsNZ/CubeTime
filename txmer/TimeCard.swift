//
//  TimeCard.swift
//  txmer
//
//  Created by macos sucks balls on 11/27/21.
//

import SwiftUI



@available(iOS 15.0, *)
struct SolvePopupView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    var timeListManager: TimeListManager
    
    
    let solve: Solves
    
    @State private var userComment: String
    @State private var solveStarred: Bool
    
    @Binding var showingPopupSlideover: Bool
    
    init(solve: Solves, timeListManager: TimeListManager, showingPopupSlideover: Binding<Bool>){
        self.solve = solve
        self.timeListManager = timeListManager
        _userComment = State(initialValue: solve.comment ?? "")
        _solveStarred = State(initialValue: solve.starred)
        _showingPopupSlideover = showingPopupSlideover
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    VStack (spacing: 12) {
                        HStack {
                            Text(solve.date ?? Date(timeIntervalSince1970: 0), format: .dateTime.day().month().year())
                                .padding(.leading, 16)
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(Color(UIColor.systemGray))
                            
                            Spacer()
                        }
                        
                        VStack {
                            HStack {
                                //Image("sq-1")
                                //  .padding(.trailing, 8)
                                Image(puzzle_types[Int(solve.scramble_type)].name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
//                                    .padding(.leading, 2)
//                                    .padding(.top, 2)
//                                    .padding(.bottom, 2)
//                                    .padding([.bottom, .leading], 1)
                                    .padding(.leading, 2)
                                    .padding(.trailing, 4)
                                //.padding(.leading)
                                
                                Text(puzzle_types[Int(solve.scramble_type)].name)
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                
                                Spacer()
                                
                                Text(puzzle_types[Int(solve.scramble_type)].subtypes[Int(solve.scramble_subtype)]!.uppercased())
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .offset(y: 2)
                                
                            }
                            .padding(.leading, 12)
                            .padding(.trailing, 16)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            
                            Text(solve.scramble ?? "Retrieving scramble failed.")
                                .font(.system(size: 17, weight: .regular, design: .monospaced))
                                .padding(.leading)
                                .padding(.trailing)
                            
                            
                            Divider()
                                .padding(.leading)
                            
                            Image("scramble-placeholder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(.leading, 32)
                                .padding(.trailing, 32)
                                .padding(.bottom, 12)
                            
                        }
                        //.frame(minHeight: minRowHeight * 10)
                        //.frame(height: 300)
                        .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:10)))
                        //.listStyle(.insetGrouped)
                        .padding(.trailing)
                        .padding(.leading)
                        
                        VStack {
                            HStack {
                                Image(systemName: "square.text.square.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 30, weight: .semibold))
                                //.padding(.trailing, 8)
                                Text("Comment")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                
                                Spacer()
                                
                            }
                            //.padding(.leading)
                            //                            .padding(.trailing)
                            //                            .padding(.top)
                            .padding(.leading, 12)
                            .padding(.trailing, 16)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            //                                .padding(.bottom)
                            
                            TextField("Notes", text: $userComment)
                            
                            //.font(.system(size: 17, weight: .regular, design: .monospaced))
                                .padding(.leading)
                                .padding(.trailing)
                                .padding(.bottom, 12)
                            
                        }
                        //.frame(minHeight: minRowHeight * 10)
                        //.frame(height: 300)
                        .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:10)))
                        //.listStyle(.insetGrouped)
                        .padding(.trailing)
                        .padding(.leading)
                        
                        
                        VStack {
                            HStack {
                                Image(systemName: "star.square.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .font(.system(size: 30, weight: .semibold))
                                
                                Spacer()
                                
                                Toggle(isOn: $solveStarred) {
                                    Text("Star")
                                }
                                
                                Spacer()
                                
                            }
                            .padding(.leading, 12)
                            .padding(.trailing, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 12)
                        }
                        .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.trailing)
                        .padding(.leading)
                        
                        
                        VStack {
                            HStack {
                                Button {
                                    print("Button tapped")
                                    //UIPasteboard.general.string = solve.scramble
                                } label: {
                                    Text("Copy Solve")
                                }
                                
                                Spacer()
                            }
                            .padding()
                            //                            .padding(.leading, 12)
                            //                            .padding(.trailing, 16)
                            //                            .padding(.top, 12)
                            //                            .padding(.bottom, 12)
                        }
                        .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.trailing)
                        .padding(.leading)
                        
                        
                        
                    }
                    .offset(y: -6)
                    .navigationTitle(formatSolveTime(secs: solve.time))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showingPopupSlideover = false
                                managedObjectContext.delete(solve) // Todo read context from environment
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
                                timeListManager.resort()
                            } label: {
                                Text("Delete Solve")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color.red)
                            }
                        }
                        
                        
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                print("button tapped")
                                showingPopupSlideover = false
                            } label: {
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .padding(.leading, -4)
                                Text("Time List")
                                    .padding(.leading, -4)
                            }
                        }
                    }
                }
            }
        }
    }
}


@available(iOS 15.0, *)
struct TimeCard: View {
    let solve: Solves
    @State var showingPopupSlideover = false
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var timeListManager: TimeListManager
    
    var body: some View {
        Button(action: {
            print(solve.time)
            showingPopupSlideover = true
        }) {
            Text(formatSolveTime(secs: solve.time))
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(Color.black)
                //.frame(width: 112, height: 53)
                //.frame(height: 55)
                .frame(maxWidth: 120, minHeight: 55, maxHeight: 55)
            
                .background(Color.white)
                .cornerRadius(10)
            
        }
        .onLongPressGesture {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        .sheet(isPresented: $showingPopupSlideover) {
            SolvePopupView(solve: solve, timeListManager: timeListManager, showingPopupSlideover: $showingPopupSlideover)
                .environment(\.managedObjectContext, managedObjectContext)
        }
        .contextMenu {
            
            Button {
                print("MOVE TO PRESSED")
            } label: {
                Label("Move To", systemImage: "arrow.up.forward.circle")
            }
            
            Divider()
            
            Button {
                print("OK PRESSED")
            } label: {
                Label("No Penalty", systemImage: "checkmark.circle") /// TODO: add custom icons because no good icons
            }
            
            Button {
                print("+2 pressed")
            } label: {
                Label("+2", systemImage: "plus.circle") /// TODO: add custom icons because no good icons
            }
            
            Button {
                print("DNF pressed")
            } label: {
                Label("DNF", systemImage: "slash.circle") /// TODO: add custom icons because no good icons
            }
            
            Divider()
            
            Button (role: .destructive) {
                managedObjectContext.delete(solve)
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
                timeListManager.resort()
            } label: {
                Label {
                    Text("Delete Solve")
                        .foregroundColor(Color.red)
                } icon: {
                    Image(systemName: "trash")
                        .foregroundColor(Color.green) /// FIX: colours not working
                }
            }
        }
    }
}

 
