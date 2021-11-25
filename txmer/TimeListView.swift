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

@available(iOS 15.0, *)
struct TimeListView: View {
    @State private var sortMode = 0
    @State private var sortAscending: Bool = true // sorting ascending or descending method (true = ascending, false = descending)as
    
    
    private func ascendingButtonIcon() -> some View {
        
        let icon = Image(systemName: "chevron.up.circle")
            .font(.system(size: 20, weight: .medium))
        
        return icon
    }
    
    private func descendingButtonIcon() -> some View {
        
        let icon = Image(systemName: "chevron.down.circle")
            .font(.system(size: 20, weight: .medium))
        
        return icon
    }
     
    //let descendingButtonIcon: Image = Image(systemName: "chevron.down.circle")
   
    
    //var buttonIcon: String = userLastState
    
    
    var times: [GridItem] {
      Array(repeating: .init(.adaptive(minimum: 6)), count: 2)
    }
    
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                /// YES FULL BLACK FOR AMOLED DO YOU HATE YOUR BATTERY LIFE
                    .ignoresSafeArea()
                
                
                ScrollView() {
                    ZStack {
                        VStack (spacing: 16) {
                            HStack {
                                Spacer()
                                
                                Picker("Sort Method", selection: $sortMode, content: {
                                    Text("Sort by Date").tag(0)
                                    Text("Sort by Time").tag(1)
                                })
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(maxWidth: 200, alignment: .center)
                                .padding(.top, 8)
                                .padding(.bottom, 2)
                               
                                Spacer()
                            }
                                 
                            TimesView()
                            
                            Spacer()
                        }
                        
                        
                        VStack /* (alignment: .center)*/ {
                            HStack {
                                
                                Spacer()
                                
                                
                                
                                
                                Button {
                                    sortAscending.toggle()
                                } label: {
                                    sortAscending ? AnyView(ascendingButtonIcon()) : AnyView(descendingButtonIcon())
                                }
                                .padding(.trailing, 16)
                                .offset(y: (32 / 2) - (SetValues.iconFontSize / 2) + 6)
                                
                                
                                 
                            }
                            
                            Spacer()

                        }
                    }
                }
                .navigationTitle("Session Times")
                .toolbar {
                    
                    
                    Button {
                        print("button tapped")
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 17, weight: .medium))
                    }
                    
                }
                
                
                //.frame(maxHeight: UIScreen.screenHeight)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

@available(iOS 15.0, *)
struct TimeListView_Previews: PreviewProvider {
    static var previews: some View {
        TimeListView()
    }
}
