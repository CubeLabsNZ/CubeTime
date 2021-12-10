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
    @Binding var hideTabBar: Bool
    
    @Namespace private var namespace
    
    let settingsColumns = [
        GridItem(spacing: 16),
        GridItem()
    ]
    
    
    var body: some View {
        
    
        NavigationView {
            ZStack {
                Color(uiColor: .systemGray6)
                    .ignoresSafeArea()
                
                //NavigationLink("", destination: GeneralSettingsView(), isActive: $showingCard)
                
                VStack (spacing: 16) {
                    HStack {
                        Text("Settings")
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.leading)
                            .padding(.top, UIScreen.screenHeight/20)
                        Spacer()
                    }
                    
                    
                    HStack (spacing: 16) {
                        SettingsCard(currentCard: $currentCard, showingCard: $showingCard, hideTabBar: $hideTabBar, info: settingsCards[0], namespace: namespace)
                        SettingsCard(currentCard: $currentCard, showingCard: $showingCard, hideTabBar: $hideTabBar, info: settingsCards[1], namespace: namespace)
                    }
                    
                    HStack (spacing: 16) {
                        SettingsCard(currentCard: $currentCard, showingCard: $showingCard, hideTabBar: $hideTabBar, info: settingsCards[2], namespace: namespace)
                        SettingsCard(currentCard: $currentCard, showingCard: $showingCard, hideTabBar: $hideTabBar, info: settingsCards[3], namespace: namespace)
                    }
                    
                    
                    Spacer()
                    
                    
                    
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.clear)
                        .frame(height: 50)
                        .padding(.top)
                }
                .padding(.vertical, 6)
                .padding(.horizontal)
            }
        }
        .overlay(
            SettingsDetail(showingCard: $showingCard, currentCard: $currentCard, hideTabBar: $hideTabBar, namespace: namespace)
        )
        
    }
}


struct SettingsCard: View {
    @Binding var currentCard: SettingsCardInfo
    @Binding var showingCard: Bool
    @Binding var hideTabBar: Bool
    var info: SettingsCardInfo
    var namespace: Namespace.ID
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.6)) {
                currentCard = info
                showingCard = true
                hideTabBar = true
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(height: UIScreen.screenHeight/3.5, alignment: .center)
                    .matchedGeometryEffect(id: "bg " + info.name, in: namespace)
                
                VStack {
                    HStack {
                        Text(info.name)
                            .font(.system(size: 22, weight: .bold))
                            .matchedGeometryEffect(id: info.name, in: namespace)
                            .padding(.horizontal)
                            .padding(.top, 12)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                                                           
                        Image(systemName: info.icon)
                            .font(info.iconStyle)
                            .matchedGeometryEffect(id: info.icon, in: namespace)
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
    @Binding var hideTabBar: Bool
    var namespace: Namespace.ID
    
    var body: some View {
        if showingCard {
            ZStack {
                Color(uiColor: .systemGray6)
                    .ignoresSafeArea()
                    .zIndex(0)

                VStack {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .ignoresSafeArea()
                            .matchedGeometryEffect(id: "bg " + currentCard.name, in: namespace)
                            
                            
                            
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Text(currentCard.name)
//                                    .font(.title.bold())
                                    .font(.system(size: 22, weight: .bold))
                                    .matchedGeometryEffect(id: currentCard.name, in: namespace)
                                
                                
                                    
                                    
                                
                                Spacer()
                                
                                Image(systemName: currentCard.icon)
                                    .font(currentCard.iconStyle)
                                    .matchedGeometryEffect(id: currentCard.icon, in: namespace)
                            }
                            .padding()
                        }
                        
                    }
                    .ignoresSafeArea()
                    .frame(maxHeight: UIScreen.screenHeight / 6)
                    
                    Spacer()
                    
                    switch currentCard.name {
                    case "About":
                        AboutSettingsView()
                            .safeAreaInset(edge: .bottom, spacing: 0) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.clear)
                                    .frame(height: 50 + (SetValues.hasBottomBar ? 0 : CGFloat(SetValues.marginBottom)))
                                    .padding(.top)
                            }
                    default:
                        Text("unable to load view")
                    }
                    
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
                                .padding()
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.6)) {
                                        showingCard = false
                                        hideTabBar = false
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

