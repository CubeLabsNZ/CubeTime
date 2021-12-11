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
    @State var currentCard: SettingsCardInfo = settingsCards[0]
    @State var showingCard = false // TODO try make the above one optional
//    @Binding var hideTabBar: Bool
    
    @Namespace var namespace
    @Namespace var namespace1
    @Namespace var namespace2
    
    
    let settingsColumns = [
        GridItem(spacing: 16),
        GridItem()
    ]
    
    
    var body: some View {
        
        ZStack {
            
            if !showingCard {
                NavigationView {
                    ZStack {
                        Color(uiColor: .systemGray6)
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
                                SettingsCard(currentCard: $currentCard, showingCard: $showingCard, info: settingsCards[0], namespace: namespace, namespace1: namespace1, namespace2: namespace2)
                                SettingsCard(currentCard: $currentCard, showingCard: $showingCard, info: settingsCards[1], namespace: namespace, namespace1: namespace1, namespace2: namespace2)
                            }
                            
                            HStack (spacing: 16) {
                                SettingsCard(currentCard: $currentCard, showingCard: $showingCard, info: settingsCards[2], namespace: namespace, namespace1: namespace1, namespace2: namespace2)
                                SettingsCard(currentCard: $currentCard, showingCard: $showingCard, info: settingsCards[3], namespace: namespace, namespace1: namespace1, namespace2: namespace2)
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
                    .animation(.spring(), value: showingCard)
                }
                .zIndex(showingCard ? 0 : 1)
            } else {
                SettingsDetail(showingCard: $showingCard, currentCard: $currentCard, namespace: namespace, namespace1: namespace1, namespace2: namespace2)
                    .zIndex(showingCard ? 1 : 0)
            }
            
            
        }
    }
}


struct SettingsCard: View {
    @Binding var currentCard: SettingsCardInfo
    @Binding var showingCard: Bool
//    @Binding var hideTabBar: Bool
    var info: SettingsCardInfo
    var namespace: Namespace.ID
    var namespace1: Namespace.ID
    var namespace2: Namespace.ID
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.6)) {
                currentCard = info
                showingCard = true
//                hideTabBar = true
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .matchedGeometryEffect(id: "bg " + info.name, in: namespace)
                    .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 3, y: 3)
                
                VStack {
                    HStack {
                        Text(info.name)
                            .matchedGeometryEffect(id: info.name, in: namespace1)
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 12)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                                                           
                        Image(systemName: info.icon)
                            .matchedGeometryEffect(id: info.icon, in: namespace2)
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
    @Binding var showingCard: Bool
    @Binding var currentCard: SettingsCardInfo
//    @Binding var hideTabBar: Bool
    
    var namespace: Namespace.ID
    var namespace1: Namespace.ID
    var namespace2: Namespace.ID
    
    
    
    var body: some View {
        if showingCard {
            ZStack {
                Color(uiColor: .systemGray6)
                    .ignoresSafeArea()
                    .zIndex(0)

                
                ScrollView {
                    switch currentCard.name {
                    case "General":
                        GeneralSettingsView()
                    case "Appearance":
                        AppearanceSettingsView()
                    case "About":
                        AboutSettingsView()
                    default:
                        Text("unable to load view: please report this issue to us on github!")
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
                            .fill(Color.white)
                            .matchedGeometryEffect(id: "bg " + currentCard.name, in: namespace)
                            .ignoresSafeArea()
                            .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 3)
                            
                            
                            
                        
                        VStack {
                            Spacer()
                            
                            HStack(alignment: .center) {
                                Text(currentCard.name)
                                    .matchedGeometryEffect(id: currentCard.name, in: namespace1)
                                    .font(.system(size: 22, weight: .bold))
                                

                                Spacer()
                                
                                Image(systemName: currentCard.icon)
                                    .matchedGeometryEffect(id: currentCard.icon, in: namespace2)
                                    .font(currentCard.iconStyle)
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
                                .foregroundStyle(.black)
                                .padding([.horizontal, .bottom])
                                .padding(.top, 8)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.5)) {
//                                        showingCard = false
                                        showingCard.toggle()
//                                        hideTabBar = false
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
