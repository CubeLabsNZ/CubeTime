//
//  StatsDetail.swift
//  txmer
//
//  Created by Tim Xie on 14/12/21.
//

import SwiftUI

struct StatsDetail: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack {
                        HStack {
                            Text("1.")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color("AccentColor"))
                            Text("1.92")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            
                            Spacer()
                        }
                        .padding([.horizontal, .top], 10)
                        
                    }
                    .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
                    
                    VStack (spacing: 10) {
                        HStack (alignment: .center) {
//                            Text(currentSession.name!)
                            Text("Session Name")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            Spacer()
                            
//                            Text(puzzle_types[Int(currentSession.scramble_type)].name)
                            Text("EVENT")
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                        .padding(.horizontal)
                        
                    }
                    .offset(y: -6)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Statistic Type")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                print("go back")
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .padding(.leading, -4)
                                Text("Stats")
                                    .padding(.leading, -4)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                print("Share")
                            } label: {
                                Image("square.and.arrow.up")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                    }
                }
            }
        }
    }
}

struct statsdetailpreview: PreviewProvider {
    static var previews: some View {
        StatsDetail()
    }
}
