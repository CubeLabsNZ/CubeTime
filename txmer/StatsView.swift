//
//  SessionsView.swift
//  txmer
//
//  Created by Reagan Bohan on 11/25/21.
//

import SwiftUI

struct StatsView: View {
    
    
    let columns = [
        // GridItem(.adaptive(minimum: 112), spacing: 11)
        GridItem(spacing: 10),
        GridItem(spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    /// this whole section make lazyvgrid because performance currently :trend_dwoin::"
                    VStack (spacing: 10) {
                        HStack (spacing: 10) {
                            VStack (spacing: 10) {
                                HStack {
                                    VStack (spacing: 2) {
                                        Text("BEST SINGLE")
                                            .font(.system(size: 13, weight: .medium, design: .default))
                                            .foregroundColor(Color(UIColor.systemGray6))
                                            
//                                            .padding(.bottom, -5)
                                        // Spacer()
                                        
                                        Text("3.741")
                                            .font(.system(size: 34, weight: .bold, design: .default))
                                            .foregroundColor(.white)
                                            
                                            
                                    }
                                    .padding(.top)
                                    .padding(.bottom)
                                    .padding(.leading, 12)
                                    
                                    
                                    Spacer()
                                }
                                .frame(height: 75)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(red: 236/255, green: 74/255, blue: 134/255), Color(red: 136/255, green: 94/255, blue: 191/255)]),
//                                        gradient: Gradient(colors: [.blue, .green]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                
                                
                                

                                VStack {
                                    Text("best ao12")
                                    
                                    Text("7.41")
                                    
                                    Divider()
                                    
                                    
                                    Text("best ao100")
                                    
                                    Text("8.02")
                                    
                                }
                                .frame(height: 125)
                                .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                                
                                
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)

                             
                             VStack {
                                 Text("Best ao5")
                                 
                                 Text("6.142")
                                 
                                 Text("solve")
                                 Text("solve")
                                 Text("solve")
                                 Text("solve")
                                 Text("solve")
                             }
                             .frame(minWidth: 0, maxWidth: .infinity, minHeight: 210)
                             .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                             
                        }

                        HStack {
                            Text("Session mean")
                            Text("Number of solves")
                        }
                        
//                        LazyVGrid(columns: columns, spacing: 10) {
//                            Text("yes")
//                        }
                        
                        
                        
                        Text("Time trend")
                        
                        Text("Time distribution")
                        
                    }
                    .navigationTitle("Your Solves")
                    .padding(.leading)
                    .padding(.trailing)
                    
                }
            }
        }
    }
}

struct StatsViewPreview: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
