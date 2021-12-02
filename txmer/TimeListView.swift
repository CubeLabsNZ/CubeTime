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
    @Binding var currentSession: Sessions?
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var sortMode = 0
    @State private var sortAscending: Bool = true // sorting ascending or descending method (true = ascending, false = descending)as
    
     
    //let descendingButtonIcon: Image = Image(systemName: "chevron.down.circle")
   
    
    //var buttonIcon: String = userLastState
    
    
    @FetchRequest(
        entity: Solves.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Solves.date, ascending: true)
        ]
    ) var solves: FetchedResults<Solves>
    
    //private var fetchRequest = FetchRequest<Solves>(entity: Solves.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Solves.date, ascending: true)])
    //private var solves: FetchedResults<Solves>
    
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                /// YES FULL BLACK FOR AMOLED DO YOU HATE YOUR BATTERY LIFE
                    .ignoresSafeArea()
                
                
                ScrollView() {
                    ZStack {
                        VStack {
                            
                            HStack (alignment: .center) {
                                Text(currentSession!.name ?? "Unnamed Session")
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                    .foregroundColor(Color(UIColor.systemGray))
                                Spacer()
                                
                                Text("SQUARE-1")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(Color(UIColor.systemGray))
                            }
                            .padding(.leading)
                            .padding(.trailing)
                            
                            
                            HStack {
                                
                                
                                Spacer()
                                
                                Picker("Sort Method", selection: $sortMode, content: {
                                    Text("Sort by Date").tag(0)
                                    Text("Sort by Time").tag(1)
                                })
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(maxWidth: 200, alignment: .center)
                                .padding(.top, -6)
                                .padding(.bottom, 4)
                               
                                Spacer()
                            }
                                 
                            TimesView(solves: solves)
                            
                            Spacer()
                        }
                        .padding(.top, -6)
                        .padding(.bottom, -6)
                        
                        
                        VStack /* (alignment: .center)*/ {
                            HStack {
                                
                                Spacer()
                                
                                Button {
                                    sortAscending.toggle()
                                    // let sortDesc: NSSortDescriptor = NSSortDescriptor(key: "date", ascending: sortAscending)
                                    //solves.sortDescriptors = [sortDesc]
                                } label: {
                                    Image(systemName: sortAscending ? "chevron.up.circle" : "chevron.down.circle")
                                        .font(.system(size: 20, weight: .medium))
                                }
                                .padding(.trailing, 16.5) /// TODO don't hardcode padding
                                .offset(y: (32 / 2) - (SetValues.iconFontSize / 2) + 6 + 18)
                                
                                
                                 
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
/* TODO make previews that take ags work
@available(iOS 15.0, *)
struct TimeListView_Previews: PreviewProvider {
    static var previews: some View {
        TimeListView()
    }
}
*/
