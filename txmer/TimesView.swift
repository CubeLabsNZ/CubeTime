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



@available(iOS 15.0, *)
struct SolvePopupView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.defaultMinListRowHeight) var minRowHeight
    @Environment(\.dismiss) var dismiss
    
    @State private var userComment: String = ""
    @State private var solveStarred = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    VStack (spacing: 12) {
                        HStack {
                            Text("date of solve")
                                .padding(.leading, 16)
                                .font(.system(size: 22, weight: .semibold, design: .default))
                                .foregroundColor(Color(UIColor.systemGray))
                                
                            Spacer()
                        }
                        
                        VStack {
                            HStack {
                                //Image("sq-1")
                                  //  .padding(.trailing, 8)
                                Image(systemName: "square.fill")
                                    .font(.system(size: 30, weight: .semibold))
                                    //.padding(.leading)
                                
                                Text("Square-1")
                                    .font(.system(size: 17, weight: .semibold, design: .default))
                                
                                Spacer()
                                
                                Text("RANDOM STATE")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                            }
                            .padding(.leading, 12)
                            .padding(.trailing, 16)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            
                            Text("(0,2)/ (0,-3)/ (3,0)/ (-5,-5)/ (6,-3)/ (-1,-4)/ (1,0)/ (-3,0)/ (-1,0)/ (0,-2)/ (2,-3)/ (-4,0)/ (1,0)")
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
                                    print("copy solve tapped")
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
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        /*
                         
                
                        VStack (spacing: 16) {
                            
                            
                            
                            /*
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
                            */
                            
                            
                        }
                         */
                        
                        
                        
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
                                    presentationMode.wrappedValue.dismiss()
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
//                        .frame(height: 53)
                        
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


    
    

//struct TimesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SolvePopupView()
//    }
//}

