//
//  StatsView.swift
//  txmer
//
//  Created by macos sucks balls on 11/25/21.
//

import SwiftUI

struct SessionsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6) /// todo make so user can change colour/changes dynamically with system theme - but when dark mode, change systemgray6 -> black (or not full black >:C)
                    .ignoresSafeArea()
                
                ScrollView() {
                    VStack (spacing: 16) {
                        
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
                .navigationTitle("Your Sessions")
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SessionsView_Previews: PreviewProvider {
    static var previews: some View {
        SessionsView()
    }
}
