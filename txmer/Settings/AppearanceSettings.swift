//
//  AppearanceSettings.swift
//  txmer
//
//  Created by Tim Xie on 6/12/21.
//

import SwiftUI
import TextView
  

struct AppearanceSettingsView: View {
    @State private var accentColour: Color = .indigo
    let accentColours: [Color] = [.green, .cyan, .blue, .indigo, .purple, .red]
    
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color("AccentColor"))
                Text("Colours")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                
                Spacer()
            }
            .padding([.horizontal, .top], 10)
            .padding(.bottom, 20)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Accent Colour")
                        .font(.system(size: 17, weight: .medium))
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
                
                HStack {
                    HStack(spacing: 6) {
                        ForEach(accentColours, id: \.self) { colour in
                            ZStack {
                                Circle()
                                    .strokeBorder(colour.opacity(0.25), lineWidth: (colour == accentColour) ? 2 : 0)
                                    .frame(width: 31, height: 31)
                                
                                Image(systemName: "circle.fill")
                                    .foregroundColor(colour)
                                    .font(.system(size: 24))
                                    .shadow(color: (colour == accentColour) ? .black.opacity(0.16) : .clear, radius: 6, x: 0, y: 2)
                                    .onTapGesture {
                                        accentColour = colour
                                    }
//                                    .padding(.horizontal, 3)
                                
                                if colour == accentColour {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        Spacer()
                            
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .onTapGesture {
                                print("dfsdfdfsdf")
                            }
                        
                    }
                    .padding(.vertical, 4)
                }
                .padding(.horizontal)
                
                
                Divider()
                    .padding(.vertical, 10)
                
                VStack {
                    HStack(alignment: .center) {
                        Text("Theme")
                            .font(.system(size: 17, weight: .medium))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(uiColor: .systemGray3))
                    }
                    .padding(.horizontal)
                    
                    
                    Text("Customise the app theme and gradients. You can also add a custom background image if you wish.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(uiColor: .systemGray))
                        .padding(.top, 4)
                        .padding(.bottom, 12)
                        .padding(.horizontal, 13)

                }
                
                .onTapGesture {
                    print("go to theme page")
                }
                
                
                
                
                
                
                
            }
            
        }
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 12)))
        .padding(.horizontal)
        
    }
}
