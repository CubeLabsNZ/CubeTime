//
//  SettingsView.swift
//  txmer
//
//  Created by Reagan Bohan on 11/25/21.
//

import SwiftUI
import SwiftUICharts

let settingsPages = ["Appearance", "General", "Import &\nExport", "About"]
let settingsPagesIcons = ["paintpalette", "gearshape.2", "square.and.arrow.up.on.square", "info"]

@available(iOS 15.0, *)
struct SettingsView: View {
    
    
    @State private var showGeneralSettingsView = false
    
    
    
    let settingsColumns = [
        GridItem(spacing: 16),
        GridItem()
    ]
    
    @State var heroAnimation = false
    
    var body: some View {
        
        
        /*
         AppearanceSettingsView()
         GeneralSettingsView()
         ImportExportSettingsView()
         AboutSettingsView()
         */
        
        
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()
                
                NavigationLink("", destination: GeneralSettingsView(), isActive: $showGeneralSettingsView)
                
                VStack (spacing: 16) {
                    /*
                     LazyVGrid (columns: settingsColumns, spacing: 16) {
                     ForEach(settingsPages.sorted(by: >), id: \.key) { key, icon in
                     
                     }
                     }
                     */
                    
                    
                    
                    HStack (spacing: 16) {
                        
                        
                        GeneralView()
                            .onTapGesture {
                                showGeneralSettingsView.toggle()
                            }

                        AppearanceView()
                    }

                    HStack (spacing: 16) {
                        ImportExportView()

                        AboutView()
                    }
                        
                   
                    
                    Spacer()
                    
                }
                .navigationTitle("Settings")
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .frame(height: 50)
                        .padding(.top)
                }
                .padding([.top, .bottom], 6)
                .padding(.leading)
                .padding(.trailing)
                
                
                
                
            }
            
        }
        
        
    }
}


struct GeneralView: View {
    var body: some View {
        
        
        VStack {
            HStack {
                Text(settingsPages[1])
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                                                   
                Image(systemName: settingsPagesIcons[1])
                    .font(.system(size: 44, weight: .light))
                    .padding(12)
                
                Spacer()
            }
        }
        .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 16)))
        
        
    }
}


struct AppearanceView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(settingsPages[0])
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Image(systemName: settingsPagesIcons[0])
                    .font(.system(size: 44, weight: .light))
                    .padding(12)
                
                
            }
        }
        .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 16)))
    }
}

struct ImportExportView: View {
    var body: some View {
        VStack {
            HStack {
                Text(settingsPages[2])
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                Spacer()
            }
            
            Spacer()
            
            HStack {
                                                   
                Image(systemName: settingsPagesIcons[2])
                    .font(.system(size: 32, weight: .regular))
                    .padding()
                
                Spacer()
            }
        }
        .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 16)))
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(settingsPages[3])
                    .font(.system(size: 22, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 12)
                
                
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: settingsPagesIcons[3])
                    .font(.system(size: 44, weight: .light))
                    .padding(12)
                
                
            }
        }
        .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 16)))
    }
}




