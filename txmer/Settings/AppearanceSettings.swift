//
//  AppearanceSettings.swift
//  txmer
//
//  Created by Tim Xie on 6/12/21.
//

import SwiftUI


struct settingsBlocks: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 12)))
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}


struct AppearanceSettingsView: View {
    @State private var accentColour: Color = .indigo
    let accentColours: [Color] = [.green, .cyan, .blue, .indigo, .purple, .red]
    
    @State private var overrideSystemAppearance: Bool = true
    @State private var darkMode: Bool = true
    @State private var reduceAnimations: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
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
                .padding(.bottom)
                
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
                                    /*
                                    if colour == accentColour {
                                        Circle()
//                                            .strokeBorder(colour.opacity(0.25), lineWidth: (colour == accentColour) ? 2 : 0)
                                            .strokeBorder(colour.opacity(0.25), lineWidth: 2)
                                            .frame(width: 31, height: 31)
                                    }
                                     */
                                    
                                    
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(colour)
                                        .font(.system(size: 24))
//                                        .shadow(color: (colour == accentColour) ? .black.opacity(0.16) : .clear, radius: 6, x: 0, y: 2)
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
                                    
                                }
                            
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center) {
                            Text("Theme")
                                .font(.system(size: 17, weight: .medium))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color(uiColor: .systemGray3))
                        }
                        .padding(.horizontal)
                        
                        
                        Text("Customise the app theme and gradients.\nYou can also add a custom background image if you wish.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(uiColor: .systemGray))
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .padding(.bottom, 12)
//                            .padding(.trailing, 4)
                            .padding(.top, 10)
                    }
                    .onTapGesture {
                        print("go to theme page")
                    }
                    
                }
                
            }
            .modifier(settingsBlocks())
            
            VStack {
                HStack {
                    Image(systemName: "command")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color("AccentColor"))
                    Text("System Settings")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                .padding(.bottom)
                
                VStack(spacing: 0) {
                    HStack {
                        Toggle(isOn: $overrideSystemAppearance) {
                            Text("Override System Appearance")
                                .font(.system(size: 17, weight: .medium))
                        }
                            .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                    if overrideSystemAppearance {
                        HStack {
                            Toggle(isOn: $darkMode) {
                                Text("Dark Mode")
                                    .font(.system(size: 17, weight: .medium))
                            }
                                .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                        }
                        .padding(.horizontal)
                    }
                        
                        
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    
                    HStack(alignment: .center) {
                        Text("App Icon")
                            .font(.system(size: 17, weight: .medium))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color(uiColor: .systemGray3))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .onTapGesture {
                        print("go to app icon selection page")
                    }
                    
                    
                    
                }
                
            }
            .modifier(settingsBlocks())
            
            
//            VStack {
//                HStack {
//                    Image(systemName: "eye")
//                        .font(.system(size: 15, weight: .bold, design: .rounded))
//                        .foregroundColor(Color("AccentColor"))
//                    Text("Accessibility")
//                        .font(.system(size: 17, weight: .bold, design: .rounded))
//
//                    Spacer()
//                }
//                .padding([.horizontal, .top], 10)
//                .padding(.bottom)
//
//
//                VStack (alignment: .leading, spacing: 0) {
//                    HStack(alignment: .center) {
//                        Toggle(isOn: $reduceAnimations) {
//                            Text("Reduce Animations")
//                                .font(.system(size: 17, weight: .medium))
//                        }
//                            .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
//                    }
//                    .padding(.horizontal)
//
//
//                    Text("Turn off motion animations and other effects.")
//                        .font(.system(size: 13, weight: .medium))
//                        .foregroundColor(Color(uiColor: .systemGray))
//                        .multilineTextAlignment(.leading)
//                        .padding(.leading)
//                        .padding(.bottom, 12)
//                        .padding(.trailing, 4)
//                        .padding(.top, 10)
//                }
//
//
//            }
//            .modifier(settingsBlocks())
            
        }
        .padding(.horizontal)
    }
}
