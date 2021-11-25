//
//  TimesView.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import SwiftUI

func getDismiss() {
    if #available(iOS 15.0, *) {
        
    } else {
        
    }
}



//@available(iOS 15.0, *)
struct SolvePopupView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    VStack (spacing: 10) {
                        HStack {
                            Text("date of solve")
                                .padding(.leading, 16)
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(Color(UIColor.systemGray))
                                
                            Spacer()
                        }
                        
                        VStack (spacing: 16) {
                            List {
                                Text("Event (Puzzle TYPE)")
                                Text("Scramble TYPE")
                                Text("Scramble")
                            }
                            .frame(minHeight: minRowHeight * 7)
                            .listStyle(.insetGrouped)
                            
                            Button(action: {
                                print("hi")
                            }) {
                                Text("hi")
                                    .font(.system(size: 17, weight: .bold, design: .default))
                                    .foregroundColor(Color.black)
                                    .frame(width: UIScreen.screenWidth - 32, height: 100)
                                    
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                print("hi")
                            }) {
                                Text("hi")
                                    .font(.system(size: 17, weight: .bold, design: .default))
                                    .foregroundColor(Color.black)
                                    .frame(width: UIScreen.screenWidth - 32, height: 100)
                                    
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                            
                            
                        }
                        
                        
                        
                    }
                        .offset(y: -6)
                        .navigationTitle("the time")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    print("button tapped")
                                } label: {
                                    Text("Delete Solve")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(Color.red)
                                }
                            }
                            
                            
                            
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    print("button tapped")
                                } label: {
                                    
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 17, weight: .medium))
                                    Text("Time List")
                                }
                            }

                        }
                }
                
                
                //.frame(maxHeight: UIScreen.screenHeight)
            }
        }
        
       
    }
}

/*
@available(iOS 14.0, *)
struct SolvePopupView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button("dismiss") {
            presentationMode.wrappedValue.dismiss()
        }
        .font(.title)
    }
}
*/

@available(iOS 15.0, *)
struct TimesView: View {
    @State private var showingPopupSlideover = false
    
    let time = (1...5).map { "Time \($0)" }
    
    /*
    let columns: [GridItem] = [
        GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11),
        GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11),
        GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11)
    ]
     */
    
    let columns = [
        GridItem(.adaptive(minimum: 112), spacing: 11)
    ]
    
    let values = SetValues()
    
    var body: some View {
        
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(time, id: \.self) { item in
                Button(action: {
                    print(item)
                    showingPopupSlideover.toggle()
                }) {
                    Text(item)
                        .font(.system(size: 17, weight: .bold, design: .default))
                        .foregroundColor(Color.black)
                        .frame(width: 112, height: 53)
                        
                        .background(Color.white)
                        .cornerRadius(10)

                }
                .onLongPressGesture {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                .sheet(isPresented: $showingPopupSlideover) {
                    SolvePopupView()
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
                        print("delete time pressed")
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
    .padding(.leading)
    .padding(.trailing)
    }
    
}


    
    

struct TimesView_Previews: PreviewProvider {
    static var previews: some View {
        SolvePopupView()
    }
}

