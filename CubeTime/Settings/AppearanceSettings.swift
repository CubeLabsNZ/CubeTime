import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(\.colorScheme) var colourScheme
    
    @State private var showThemeOptions: Bool = false
    @State private var showFontSizeOptions: Bool = false
    @State private var showPreview: Bool = false
    
    // gradients
    @Preference(\.isStaticGradient) private var isStaticGradient
    @Preference(\.graphGlow) private var graphGlow
    @Preference(\.graphAnimation) private var graphAnimation
    
    // system settings (appearance)
    @Preference(\.overrideDM) private var overrideSystemAppearance
    @Preference(\.dmBool) private var darkMode
    
    
    @Preference(\.scrambleSize) private var scrambleSize
    @Preference(\.fontWeight) private var fontWeight
    @Preference(\.fontCasual) private var fontCasual
    @Preference(\.fontCursive) private var fontCursive
    
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    @EnvironmentObject var gradientManager: GradientManager
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                HStack {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.subheadline.weight(.bold))

                        .foregroundColor(Color("accent"))
                    Text("Colours")
                        .font(.body.weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                .padding(.bottom)
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center) {
                            Text("Gradient")
                                .font(.body.weight(.medium))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.bold))
                                .foregroundColor(Color("grey"))
                                .rotationEffect(.degrees(showThemeOptions ? 90 : 0))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            print("HERE")
                            withAnimation(Animation.customSlowSpring) {
                                showThemeOptions.toggle()
                            }
                        }
                        .padding(.horizontal)
                        
                        
                        Text("Customise the gradients used in stats. By default, the gradient is set to \"Static\". You can choose to set it to \"Dynamic\", where the gradient will change throughout the day.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .padding(.bottom, 4)
                            .padding(.top, 10)
                        
                        if showThemeOptions {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(spacing: 16) {
                                    VStack(spacing: 4) {
                                        Text("STATIC GRADIENT")
                                            .foregroundColor(Color("grey"))
                                            .font(.footnote.weight(.semibold))
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(getGradient(gradientSelected: gradientManager.appGradient, isStaticGradient: true))
                                                .frame(height: 50)
                                                .onTapGesture {
                                                    isStaticGradient = true
                                                }
                                            
                                            if (isStaticGradient) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 15, weight: .black))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }

                                    VStack(spacing: 2) {
                                        Text("DYNAMIC GRADIENT")
                                            .foregroundColor(Color("grey"))
                                            .font(.footnote.weight(.semibold))
                                        
                                        ZStack {
                                            HStack(spacing: 0) {
                                                ForEach(0..<10, id: \.self) { index in
                                                    Rectangle()
                                                        .fill(getGradient(gradientSelected: index, isStaticGradient: false))
                                                        .frame(height: 175)
                                                }
                                            }
                                            .frame(height: 50)
                                            .rotationEffect(Angle(degrees: 25))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .onTapGesture {
                                                isStaticGradient = false
                                            }
                                            
                                            if (!isStaticGradient) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 15, weight: .black))
                                                    .foregroundColor(.white)
                                                    .frame(width: 40)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 12)
                        }
                    }
                    .clipped()
                    
                    ThemedDivider()
                        .padding(.vertical, 10)
                        .padding(.leading)
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Toggle(isOn: $graphGlow) {
                                Text("Graph Glow")
                                    .font(.body.weight(.medium))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                       
                        Text("Turn on/off the glow effect on graphs.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Toggle(isOn: $graphAnimation) {
                                Text("Graph Animation")
                                    .font(.body.weight(.medium))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                       
                        Text("Turn on/off the line animation for the time trend graph.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                    }
                }
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            
            
            
            
            
            
            
            
            VStack {
                HStack {
                    Image(systemName: "command")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color("accent"))
                    Text("System Settings")
                        .font(.body.weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                .padding(.bottom)
                
                VStack(spacing: 0) {
                    HStack {
                        Toggle(isOn: $overrideSystemAppearance) {
                            Text("Override System Appearance")
                                .font(.body.weight(.medium))
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, overrideSystemAppearance ? 10 : 12)
                    
                    if overrideSystemAppearance {
                        HStack {
                            Toggle(isOn: $darkMode) {
                                Text("Dark Mode")
                                    .font(.body.weight(.medium))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            
            
            
            
            
            
            
            
            
            VStack {
                HStack {
                    Image(systemName: "textformat")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color("accent"))
                    Text("Font Settings")
                        .font(.body.weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                .padding(.bottom)
                
                
                VStack (alignment: .leading, spacing: 0) {
                    HStack {
                        Stepper(value: $scrambleSize, in: 15...36, step: 1) {
                            Text("Scramble Size: ")
                                .font(.body.weight(.medium))
                            Text("\(scrambleSize)")
                        }
                    }
                    .padding(.horizontal)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Preview")
                        .font(.footnote.weight(.medium))
                        .lineSpacing(-4)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color("grey"))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    
                    
                    VStack {
                        Text("L' D R2 B2 D2 F2 R2 B2 D R2 D R2 U B' R F2 R U' F L2 D'")
                            .font(fontManager.ctFontScramble)
                            .padding()
                        
                        
                        Text("Tap for Fullscreen Preview")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding([.trailing, .bottom], 8)
                        
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color("base"))
                    )
                    .onTapGesture {
                        showPreview = true
                    }
                    .fullScreenCover(isPresented: $showPreview) {
                        TimerPreview()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                  
                
                
                
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Font Weight")
                            .font(.body.weight(.medium))
                            .padding(.bottom, 4)
                        
                        HStack {
                            Text("MIN")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("grey"))
                            
                            Slider(value: $fontWeight, in: 300...800, step: 1.0)
                                .padding(.horizontal, 4)
                            
                            Text("MAX")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("grey"))
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Font Casualness")
                            .font(.body.weight(.medium))
                            .padding(.bottom, 4)
                        
                        HStack {
                            Text("MIN")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("grey"))
                            
                            Slider(value: $fontCasual, in: 0...1, step: 0.01)
                                .padding(.horizontal, 4)
                            
                            Text("MAX")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("grey"))
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Toggle(isOn: $fontCursive) {
                                Text("Cursive Font")
                                    .font(.body.weight(.medium))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            
        }
        .padding(.horizontal)
        .preferredColorScheme(overrideSystemAppearance ? darkMode ? .dark : .light : nil)
    }
}


struct TimerPreview: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    @Preference(\.scrambleSize) private var scrambleSize
    
    
    var body: some View {
        ZStack {
            // BACKGROUND COLOUR
            Color("base")
                .ignoresSafeArea()
            
            Text("0.000")
                .foregroundColor(Color("grey"))
                .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold,
                                                          smallDeviceNames.contains(getModelName()) ? 54 : 56
                                                          , nil)))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .ignoresSafeArea(edges: .all)
            
            
            HStack {
                TimerHeader(previewMode: true)
                    .padding(.trailing, 24)
                
                Spacer()
                
                Stepper("", value: $scrambleSize, in: 15...36, step: 1)
                    .frame(width: 85, height: 30)
                    .padding(.trailing, 8)
                
                CloseButton {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
            
            VStack {
                Text("L' D R2 B2 D2 F2 R2 B2 D R2 D R2 U B' R F2 R U' F L2 D'")
                    .font(fontManager.ctFontScramble)
                    .frame(maxHeight: globalGeometrySize.height/3)
                    .multilineTextAlignment(.center)
                    
                
                Spacer()
            }
            .padding(.horizontal)
            .offset(y: 35 + (UIDevice.hasBottomBar ? 0 : 8))
        }
    }
}
