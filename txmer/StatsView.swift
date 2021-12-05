//
//  SessionsView.swift
//  txmer
//
//  Created by Reagan Bohan on 11/25/21.
//

import SwiftUI

extension View {
    public func gradientForeground(colors: [Color]) -> some View {
        self.overlay(LinearGradient(gradient: .init(colors: colors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
            .mask(self)
    }
}


@available(iOS 15.0, *)
struct StatsView: View {
    
    let gradientColour: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [Color(red: 236/255, green: 74/255, blue: 134/255), Color(red: 136/255, green: 94/255, blue: 191/255)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing)
    
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
                                Button {
                                    print("best single pressed")
                                } label: {
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("BEST SINGLE")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(UIColor.systemGray6))
                                                .padding(.bottom, 4)
                                            
                                            Text("3.741")
                                                .font(.system(size: 34, weight: .bold, design: .default))
                                                .foregroundColor(.white)
                                        }
                                        .padding(.top)
                                        .padding(.bottom, 12)
                                        .padding(.leading, 12)
                                        
                                        Spacer()
                                    }
                                    .frame(height: 75)
                                    .background(gradientColour                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                }
                                
                                
                                HStack {
                                    VStack (alignment: .leading, spacing: 0) {
                                        
                                        Button {
                                            print("best ao12 pressed")
                                        } label: {
                                            
                                            VStack {
                                                Text("BEST AO12")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(UIColor.systemGray))
                                                    .padding(.leading, 12)
                                                
                                                Text("7.41")
                                                    .font(.system(size: 34, weight: .bold, design: .default))
                                                    .foregroundColor(.black)
                                                    .padding(.leading, 12)
                                            }
                                        }
                                        
                                        
                                        Divider()
                                            .padding(.leading, 12)
                                            .padding(.bottom, 4)
                                        
                                        Button {
                                            print("best ao100 pressed")
                                        } label: {
                                            
                                            VStack {
                                                Text("BEST AO100")
                                                    .font(.system(size: 13, weight: .medium, design: .default))
                                                    .foregroundColor(Color(UIColor.systemGray))
                                                    .padding(.leading, 12)
                                                
                                                Text("8.02")
                                                    .font(.system(size: 34, weight: .bold, design: .default))
                                                    .foregroundColor(.black)
                                                    .padding(.leading, 12)
                                            }
                                        }
                                        
                                        
                                    }
                                    
                                    
                                    Spacer()
                                    
                                }
                                .frame(height: 130)
                                .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                                
                                
                                
                                
                                
                                
                                
                                
                                HStack {
                                    VStack (alignment: .leading, spacing: 0) {
                                        Text("SESSION MEAN")
                                            .font(.system(size: 13, weight: .medium, design: .default))
                                            .foregroundColor(Color(UIColor.systemGray))
                                            .padding(.bottom, 4)
                                        
                                        
                                        Text("9.80")
                                            .font(.system(size: 34, weight: .bold, design: .default))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.top)
                                    .padding(.bottom, 12)
                                    .padding(.leading, 12)
                                    
                                    Spacer()
                                }
                                .frame(height: 75)
                                .background(Color.white                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            
                            VStack (spacing: 10) {
                                
                                Button {
                                    print("best ao5 pressed")
                                } label: {
                                    
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text("BEST AO5")
                                                .font(.system(size: 13, weight: .medium, design: .default))
                                                .foregroundColor(Color(UIColor.systemGray))
                                                .padding(.bottom, 4)
                                            
                                            Text("6.142")
                                                .font(.system(size: 34, weight: .bold, design: .default))
                                                .gradientForeground(colors: [Color(red: 236/255, green: 74/255, blue: 134/255), Color(red: 136/255, green: 94/255, blue: 191/255)])
                                            
                                            //                                        gradientColour.mask(Text("6.142").font(.system(size: 34, weight: .bold, design: .default)))
                                            
                                            Spacer()
                                            
                                            
                                            Text("(5.58)\n6.24\n(8.87)\n6.18\n5.99") /// TODO: make text gray when they are () and AUTO BRACKET
                                                .font(.system(size: 17, weight: .regular, design: .default))
                                                .foregroundColor(.black)
                                                .multilineTextAlignment(.leading)
                                            
                                        }
                                        //                                    .padding(.top)
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                                        .padding(.leading, 12)
                                        
                                        
                                        
                                        Spacer()
                                    }
                                    .frame(height: 215)
                                    .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                                }
                                
                                
                                
                                
                                
                                
                                HStack {
                                    VStack (alignment: .leading, spacing: 0) {
                                        Text("NUMBER OF SOLVES")
                                            .font(.system(size: 13, weight: .medium, design: .default))
                                            .foregroundColor(Color(UIColor.systemGray))
                                            .padding(.bottom, 4)
                                        
                                        Text("1034")
                                            .font(.system(size: 34, weight: .bold, design: .default))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.top)
                                    .padding(.bottom, 12)
                                    .padding(.leading, 12)
                                    
                                    Spacer()
                                }
                                .frame(height: 75)
                                .background(Color.white                                        .clipShape(RoundedRectangle(cornerRadius:16)))
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            
                            
                        }
                                                
                        //                        LazyVGrid(columns: columns, spacing: 10) {
                        //                            Text("yes")
                        //                        }
                        
                        
                        
                        
                        
                        
                        
                        Button {
                            print("time trend pressed")
                        } label: {
                            VStack {
                                HStack {
                                    Text("TIME TREND")
                                        .font(.system(size: 13, weight: .medium, design: .default))
                                        .foregroundColor(Color(UIColor.systemGray))
                                        .padding(.bottom, 4)
                                    
                                    Spacer()
                                }
                                
                                
                                Spacer()
                                
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 12)
                            .padding(.leading, 12)
                            
                        }
                        .frame(height: 200)
                        .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                        
                        
                        
                        Button {
                            print("time distribution pressed")
                        } label: {
                            VStack {
                                HStack {
                                    Text("TIME DISTRIBUTION")
                                        .font(.system(size: 13, weight: .medium, design: .default))
                                        .foregroundColor(Color(UIColor.systemGray))
                                        .padding(.bottom, 4)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 12)
                            .padding(.leading, 12)
                            
                        }
                        .frame(height: 200)
                        .background(Color(UIColor.white).clipShape(RoundedRectangle(cornerRadius:16)))
                        .padding(.bottom, 16)
                        
                        
                    }
                    .navigationTitle("Your Solves")
                    .padding(.leading)
                    .padding(.trailing)
                    
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .frame(height: 50)
                        
                }
            }
        }
    }
}

