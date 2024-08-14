import SwiftUI

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


struct SettingsViewInner: View {
    @Binding var currentCard: SettingsCardInfo?
    let namespace: Namespace.ID
    @Environment(\.horizontalSizeClass) var hSizeClass
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            BackgroundColour()
            
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    SettingsCard(currentCard: $currentCard, info: settingsCards[0], namespace: namespace)
                    SettingsCard(currentCard: $currentCard, info: settingsCards[1], namespace: namespace)
                }
                
                SettingsCard(currentCard: $currentCard, info: settingsCards[2], namespace: namespace)
                
                
                Spacer()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode((UIDevice.deviceIsPad && hSizeClass == .regular) ? .inline : .large)
            .safeAreaInset(safeArea: .tabBar)
            .padding(.vertical, 6)
            .padding(.horizontal)
            .if((UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
                view
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            CTDoneButton(onTapRun: {
                                dismiss()
                            })
                        }
                    }
            }
        }
        .zIndex(1)
    }
}

struct SettingsView: View {
    @State var currentCard: SettingsCardInfo?
    
    @Namespace var namespace
    
    var body: some View {
        ZStack {
            NavigationView {
                SettingsViewInner(currentCard: $currentCard, namespace: namespace)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .overlay(
                SettingsDetail(currentCard: $currentCard, namespace: namespace)
            )
        }
    }
}

struct SettingsCard: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    @Binding var currentCard: SettingsCardInfo?
    var info: SettingsCardInfo
    var namespace: Namespace.ID
    
    
    var body: some View {
        // this if statement is temporary for when there are only 3 blocks
        // keep ONLY the top statement (for general and appearance) to apply to all
        // once import and export is added
        if info.id == .general || info.id == .appearance {
            Button {
                withAnimation(Animation.customSlowSpring) {
                    currentCard = info
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("overlay0"))
                        .matchedGeometryEffect(id: "bg \(info.id)", in: namespace)
                        .frame(height: globalGeometrySize.height/3.5, alignment: .center)
                        .shadowLight(x: 0, y: 3)
                    
                    VStack {
                        HStack {
                            Text(info.name)
                                .matchedGeometryEffect(id: info.id, in: namespace)
                                .minimumScaleFactor(0.75)
                                .lineLimit(info.id == .appearance ? 1 : 2)
                                .allowsTightening(true)
                                .font(.title2.weight(.bold))
                                .padding(.horizontal, info.id == .appearance ? 14 : nil)
                                .padding(.top, info.id == .appearance ? 15 : 12)
                            
                            
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
                    .frame(height: globalGeometrySize.height/3.5, alignment: .center)
                }
            }
            .buttonStyle(CTButtonStyle())
        } else {
            Button {
                withAnimation(Animation.customSlowSpring) {
                    currentCard = info
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color("overlay0"))
                        .matchedGeometryEffect(id: "bg \(info.id)", in: namespace)
                        .frame(height: globalGeometrySize.height/7, alignment: .center)
                        .shadowLight(x: 0, y: 3)
                    
                    VStack {
                        HStack {
                            Text(info.name)
                                .matchedGeometryEffect(id: info.id, in: namespace)
                                .minimumScaleFactor(0.75)
                                .lineLimit(info.id == .appearance ? 1 : 2)
                                .allowsTightening(true)
                                .font(.title2.weight(.bold))
                                .padding(.horizontal, info.id == .appearance ? 14 : nil)
                                .padding(.top, info.id == .appearance ? 15 : 12)
                            
                            Spacer()
                            
                            Image(systemName: info.icon)
                                .matchedGeometryEffect(id: info.icon, in: namespace)
                                .font(info.iconStyle)
                                .padding(.trailing, 12)
                                .padding(.top, 14)
                        }
                        
                        Spacer()
                    }
                    .frame(height: globalGeometrySize.height/7, alignment: .center)
                }
            }
            .buttonStyle(CTButtonStyle())
        }
    }
}

struct SettingsDetail: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @Binding var currentCard: SettingsCardInfo?
    var namespace: Namespace.ID
    
    var body: some View {
        if let currentCard {
            GeometryReader { geo in
                ZStack {
                    BackgroundColour()
                        .zIndex(0)
                    
                    ScrollView {
                        switch currentCard.id {
                        case .general:
                            GeneralSettingsView()
                        case .appearance:
                            AppearanceSettingsView()
                        case .help:
                            AboutSettingsView(parentGeo: geo)
                        default:
                            EmptyView()
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.clear)
                            .frame(maxHeight: 125)
                            .padding(.bottom)
                    }
                    .safeAreaInset(safeArea: .tabBar)

                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color("overlay0"))
                                .matchedGeometryEffect(id: "bg \(currentCard.id)", in: namespace)
                                .ignoresSafeArea()
                                .shadowLight(x: 0, y: 3)
                            
                            VStack {
                                Spacer()
                                
                                HStack(alignment: .center) {
                                    Text(currentCard.name)
                                        .matchedGeometryEffect(id: currentCard.id, in: namespace)
                                        .minimumScaleFactor(0.75)
    //                                    .lineLimit(1)
                                        .lineLimit(currentCard.id == .appearance ? 1 : 2)
                                        .allowsTightening(true)
                                        .font(.title2.weight(.bold))
                                    

                                    Spacer()
                                    
                                    Image(systemName: currentCard.icon)
                                        .matchedGeometryEffect(id: currentCard.icon, in: namespace)
                                        .font(currentCard.iconStyle)
                                }
                                .padding()
                            }
                        }
                        .ignoresSafeArea()
                        .frame(maxHeight: 125)
                        
                        Spacer()
                    }
                    .zIndex(1)
                    .overlay(
                        VStack {
                            HStack {
                                Spacer()
                                
                                CTCloseButton {
                                    withAnimation(Animation.customSlowSpring) {
                                        self.currentCard = nil
                                    }
                                }
                                .padding([.horizontal, .bottom])
                                .padding(.top, 8)
                            }
                            Spacer()
                        }
                    )
                }
            }
        }
    }
}
