//
//  StatsView.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import SwiftUI

struct SessionsView: View {
    
    let session = (1...50).map { "Session \($0)" }
    
    var solveCount: Int = 1603
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    VStack (spacing: 10) {
                        ForEach(session, id: \.self) { item in
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
    


struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView()
    }
}
