//
//  TimeListView.swift
//  txmer
//
//  Created by Tim Xie on 24/11/21.
//

import Foundation
import SwiftUI

/*
enum buttonMode {
    case isAscending
    case isDescending
}
 */

struct TimeListView: View {
    @State private var sortMode = 0
    @State private var sortAscending: Bool = true // sorting ascending or descending method (true = ascending, false = descending)as
    
    /*
    let ascendingButtonIcon: String = "􁂚"
    let descendingButtonIcon: String = "descending!!"
     */
    
    let iconFontSize: CGFloat = 20.0
    
    let ascendingButtonIcon: Image = Image(systemName: "chevron.up.circle")
    let descendingButtonIcon: Image = Image(systemName: "chevron.down.circle")
    
    var userLastState = "user's last state"
    
    //var buttonIcon: String = userLastState
    
    var body: some View {
        
        
        
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                
               
                VStack (spacing: 10) {
                    HStack {
                        
                        Spacer()
                        
                        Picker("Favorite Color", selection: $sortMode, content: {
                            Text("Sort by Date").tag(0)
                            Text("Sort by Time").tag(1)
                        })
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: 200, alignment: .center)
                       
                        Spacer()
                    }
                         
                                        
                    Text(String(sortMode))
                    
                    Spacer()
                }
                .navigationTitle("Session Times")
                
                .toolbar {
                    Button("HELP") {
                        print("TAPPED")
                    }
                }
                
                
                VStack /* (alignment: .center)*/ {
                    HStack {
                        
                        Spacer()
                        
                        Button {
                            sortAscending.toggle()
                        } label: {
                            sortAscending ? ascendingButtonIcon : descendingButtonIcon
                        }
                        .padding(.trailing, 16)
                        .offset(y: (32 / 2) - (iconFontSize / 2))
                       
                    }
                    
                    Spacer()

                }
               
                
                
                
                
                
            }
        }
    }
}
