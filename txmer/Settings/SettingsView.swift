//
//  SettingsView.swift
//  txmer
//
//  Created by Reagan Bohan on 11/25/21.
//

import SwiftUI
import SwiftUICharts

struct AnimatingFontSizeV2: AnimatableModifier {
    var fontSize: CGFloat

    var animatableData: CGFloat {
        get { fontSize }
        set { fontSize = newValue }
    }

    func body(content: Self.Content) -> some View {
        content
            .font(.system(size: self.fontSize, weight: .bold))
    }
}

@available(iOS 15.0, *)
struct SettingsView: View {
    @State var currentCard: SettingsCardInfo?
//    @Binding var hideTabBar: Bool
    @Environment(\.colorScheme) var colourScheme
    
    @Namespace var namespace
    
    
    let settingsColumns = [
        GridItem(spacing: 16),
        GridItem()
    ]
    
    
    var body: some View {
        ZStack {
            
            if currentCard == nil {
                NavigationView {
                    ZStack {
                        Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                            .ignoresSafeArea()
                        
                        //NavigationLink("", destination: GeneralSettingsView(), isActive: $showingCard)
                        
                        VStack (spacing: 16) {
//                            HStack {
//                                Text("Settings")
//                                    .font(.largeTitle.bold())
//                                    .multilineTextAlignment(.leading)
//                                    .padding(.top, UIScreen.screenHeight/20)
//                                Spacer()
//                            }
                            
                            
                            HStack (spacing: 16) {
                                SettingsCard(currentCard: $currentCard, info: settingsCards[0], namespace: namespace)
                                SettingsCard(currentCard: $currentCard, info: settingsCards[1], namespace: namespace)
                            }
                            
                            HStack (spacing: 16) {
                                SettingsCard(currentCard: $currentCard, info: settingsCards[2], namespace: namespace)
                                SettingsCard(currentCard: $currentCard, info: settingsCards[3], namespace: namespace)
                            }
                            
                            
                            Spacer()
                            
                            
                            
                        }
                        .navigationBarTitle("Settings")
//                        .navigationBarHidden(true)
//                        .navigationBarBackButtonHidden(true)
                        
                        .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                    }
//                    .animation(.spring(), value: showingCard)
                }
//                .zIndex(showingCard ? 0 : 1)
                .zIndex(1)
            } else {
                SettingsDetail(currentCard: $currentCard, namespace: namespace)
                    .zIndex(2)
//                    .zIndex(showingCard ? 1 : 0)
            }
        }
    }
}


struct SettingsCard: View {
    @Binding var currentCard: SettingsCardInfo?
    var info: SettingsCardInfo
    var namespace: Namespace.ID
    
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.6)) {
                currentCard = info
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: colourScheme == .light ? .white : .systemGray6))
                    .matchedGeometryEffect(id: "bg " + info.name, in: namespace)
                    .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 3, y: 3)
                
                VStack {
                    HStack {
                        Text(info.name)
                            .matchedGeometryEffect(id: info.name, in: namespace)
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 12)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                                                           
                        Image(systemName: info.icon)
                            .matchedGeometryEffect(id: info.icon, in: namespace)
                            .font(info.iconStyle)
                            .padding(12)
                        
                        Spacer()
                    }
                }
                .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
            }
        }
        .buttonStyle(CardButtonStyle())
    }
}

@available(iOS 15.0, *)
struct SettingsDetail: View {
    @Binding var currentCard: SettingsCardInfo?
    @Environment(\.colorScheme) var colourScheme
    
    var namespace: Namespace.ID
    
    var body: some View {
        if currentCard != nil {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                    .zIndex(0)
                
                ScrollView {
                    switch currentCard!.name { // TODO use an enum for better i18n support
                    case "General":
                        GeneralSettingsView()
//                        StatsDetail()
                    case "Appearance":
                        AppearanceSettingsView()
                    case "About":
                        AboutSettingsView()
                    default:
                        EmptyView()
                    }
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.clear)
                        .frame(maxHeight: UIScreen.screenHeight / 7)
                        .padding(.bottom)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}

                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(uiColor: colourScheme == .light ? .white : .systemGray6))
                            .matchedGeometryEffect(id: "bg " + currentCard!.name, in: namespace)
                            .ignoresSafeArea()
                            .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 3)
                            
                            
                            
                        
                        VStack {
                            Spacer()
                            
                            HStack(alignment: .center) {
                                Text(currentCard!.name)
                                    .matchedGeometryEffect(id: currentCard!.name, in: namespace)
                                    .font(.system(size: 22, weight: .bold))
                                

                                Spacer()
                                
                                Image(systemName: currentCard!.icon)
                                    .matchedGeometryEffect(id: currentCard!.icon, in: namespace)
                                    .font(currentCard!.iconStyle)
                            }
                            .padding()
                        }
                    }
                    .ignoresSafeArea()
                    .frame(maxHeight: UIScreen.screenHeight / 7)
                    
                    Spacer()
                }
                .zIndex(1)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.secondary)
                                .foregroundStyle(colourScheme == .light ? .black : .white)
                                .padding([.horizontal, .bottom])
                                .padding(.top, 8)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.5)) {
    //                                        showingCard = false
    //                                        hideTabBar = false
                                        currentCard = nil
                                    }
                                    
                                }
                        }
                        Spacer()
                    }
                )
            }
        }
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeIn, value: configuration.isPressed)
    }
}
