//
//  SettingsView.swift
//  txmer
//
//  Created by Reagan Bohan on 11/25/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct SettingsView: View {
    
    
    let settingsPages = ["Appearance": "paintpalette.fill", "General": "gearshape.2.fill", "Import/Export": "square.and.arrow.up.on.square.fill", "About": "info.circle.fill"]
    
    let settingsColumns = [
        GridItem(spacing: 16),
        GridItem()
        ]
    
    var body: some View {
        
        
        /*
         AppearanceSettingsView()
         GeneralSettingsView()
         ImportExportSettingsView()
         AboutSettingsView()
         */
        
        NavigationView {
            ScrollView {
                LazyVGrid (columns: settingsColumns, spacing: 16) {
                    ForEach(settingsPages.sorted(by: >), id: \.key) { key, icon in
                        
                        RoundedRectangle(cornerRadius: 16)
                            .frame(minHeight: 300, alignment: .center)
                        
//                        HStack {
//                            Text(key)
//                                .background(Color(uiColor: UIColor.systemGray6).clipShape(RoundedRectangle(cornerRadius:16)))
//
//                            Spacer()
//                        }
                        
                        
                        
//                        VStack {
//                            HStack {
//
//
//                                Spacer()
//                            }
//                            Spacer()
//                        }
                          
                    }
                }
            }
            
            .navigationTitle("Settings")
            .safeAreaInset(edge: .bottom, spacing: 0) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                    .frame(height: 50)
                    .padding(.top)
            }
            .padding(.leading)
            .padding(.trailing)
        }
        
        
        
    }
}

