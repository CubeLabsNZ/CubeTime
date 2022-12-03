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

struct SettingsView: View {
    @State var currentCard: SettingsCardInfo?
    
    @Environment(\.colorScheme) var colourScheme
    
    
    @Namespace var namespace
    
    
    let settingsColumns = [GridItem(spacing: 16), GridItem()]
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            SettingsCard(currentCard: $currentCard, info: settingsCards[0], namespace: namespace)
                            SettingsCard(currentCard: $currentCard, info: settingsCards[1], namespace: namespace)
                        }
                        /* bring this back (the 4 grid) once importexport added
                        HStack (spacing: 16) {
                            SettingsCard(currentCard: $currentCard, info: settingsCards[2], namespace: namespace)
//                            SettingsCard(currentCard: $currentCard, info: settingsCards[3], namespace: namespace)
                        }
                         */
                        
                        SettingsCard(currentCard: $currentCard, info: settingsCards[3], namespace: namespace)
                        
                        
                        Spacer()
                    }
                    .navigationBarTitle("Settings")
                    .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .zIndex(1)
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
    
    @Environment(\.colorScheme) var colourScheme
    
    
    var body: some View {
        // this if statement is temporary for when there are only 3 blocks
        // keep ONLY the top statement (for general and appearance) to apply to all
        // once import and export is added
        if info.name == "General" || info.name == "Appearance" {
            Button {
                withAnimation(.spring(response: 0.6)) {
                    currentCard = info
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(uiColor: colourScheme == .light ? .white : .systemGray6))
                        .matchedGeometryEffect(id: "bg " + info.name, in: namespace)
                        .frame(height: globalGeometrySize.height/3.5, alignment: .center)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 3, y: 3)
                    
                    VStack {
                        HStack {
                            Text(info.name)
                                .matchedGeometryEffect(id: info.name, in: namespace)
                                .minimumScaleFactor(0.75)
                                .lineLimit(info.name == "Appearance" ? 1 : 2)
                                .allowsTightening(true)
                                .font(.title2.weight(.bold))
                                .padding(.horizontal, info.name == "Appearance" ? 14 : nil)
                                .padding(.top, info.name == "Appearance" ? 15 : 12)
                            
                            
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
            .buttonStyle(CardButtonStyle())
        } else {
            Button {
                withAnimation(.spring(response: 0.6)) {
                    currentCard = info
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(uiColor: colourScheme == .light ? .white : .systemGray6))
                        .matchedGeometryEffect(id: "bg " + info.name, in: namespace)
                        .frame(height: globalGeometrySize.height/7, alignment: .center)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 3, y: 3)
                    
                    VStack {
                        HStack {
                            Text(info.name)
                                .matchedGeometryEffect(id: info.name, in: namespace)
                                .minimumScaleFactor(0.75)
                                .lineLimit(info.name == "Appearance" ? 1 : 2)
                                .allowsTightening(true)
                                .font(.title2.weight(.bold))
                                .padding(.horizontal, info.name == "Appearance" ? 14 : nil)
                                .padding(.top, info.name == "Appearance" ? 15 : 12)
                            
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
            .buttonStyle(CardButtonStyle())
        }
    }
}

struct SettingsDetail: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
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
                    #warning("TODO:  use an enum for better i18n support")
                    switch currentCard!.name {
                    case "General":
                        GeneralSettingsView()
                    case "Appearance":
                        AppearanceSettingsView()
                    case "Import &\nExport":
                        EmptyView()
//                        ImportExportSettingsView()
                    case "Help &\nAbout Us":
                        AboutSettingsView()
                    default:
                        EmptyView()
                    }
                }
                .safeAreaInset(edge: .top, spacing: 0) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.clear)
                        .frame(maxHeight: globalGeometrySize.height / 7)
                        .padding(.bottom)
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.clear).frame(height: 50).padding(.top).padding(.bottom, SetValues.hasBottomBar ? 0 : nil)}

                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(uiColor: colourScheme == .light ? .white : .systemGray6))
                            .matchedGeometryEffect(id: "bg " + currentCard!.name, in: namespace)
                            .ignoresSafeArea()
                            .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 3)
                        VStack {
                            Spacer()
                            
                            HStack(alignment: .center) {
                                Text(currentCard!.name)
                                    .matchedGeometryEffect(id: currentCard!.name, in: namespace)
                                    .minimumScaleFactor(0.75)
//                                    .lineLimit(1)
                                    .lineLimit(currentCard!.name == "Appearance" ? 1 : 2)
                                    .allowsTightening(true)
                                    .font(.title2.weight(.bold))
                                

                                Spacer()
                                
                                Image(systemName: currentCard!.icon)
                                    .matchedGeometryEffect(id: currentCard!.icon, in: namespace)
                                    .font(currentCard!.iconStyle)
                            }
                            .padding()
                        }
                    }
                    .ignoresSafeArea()
                    .frame(maxHeight: globalGeometrySize.height / 7)
                    
                    Spacer()
                }
                .zIndex(1)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            
                            CloseButton()
                                .padding([.horizontal, .bottom])
                                .padding(.top, 8)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.5)) {
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
