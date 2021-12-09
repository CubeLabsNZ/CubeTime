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
    
    var tabRouter: TabRouter
    
    let settingsColumns = [
        GridItem(spacing: 16),
        GridItem()
    ]
    
//    @State var heroAnimation = false
    
    var animation: Namespace.ID
    
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
                    LazyVGrid(columns: [GridItem(spacing: 16), GridItem(spacing: 16)], spacing: 16) {
                        ForEach(settingsCards) { settingsCard in
                            if settingsCard.name == "Appearance" || settingsCard.name == "Import &\nExport" {
                                Button {
                                    withAnimation(.spring()) {
                                        tabRouter.currentSettingsCard = settingsCard
                                        tabRouter.showDetail = false
//                                        @Published var currentSettingsCard: SettingsCard?
//                                        @Published var showDetail: Bool = false
                                    }
                                } label: {
                                    VStack {
                                        HStack {
                                            Text(settingsCard.name)
                                                .font(.system(size: 22, weight: .bold))
                                                .padding(.horizontal)
                                                .padding(.top, 12)
                                            Spacer()
                                        }
                                        Spacer()
                                        HStack {
                                            Image(systemName: settingsCard.icon)
                                                .font(settingsCard.iconStyle)
                                                .padding(12)
                                            Spacer()
                                        }
                                    }
                                    .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
                                    .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 16)))
                                }
                            } else {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Text(settingsCard.name)
                                            .font(.system(size: 22, weight: .bold))
                                            .padding(.horizontal)
                                            .padding(.top, 12)
                                    }
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Image(systemName: settingsCard.icon)
                                            .font(settingsCard.iconStyle)
                                            .padding(12)
                                    }
                                }
                                .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
                                .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 16)))
                            }
                        }
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
