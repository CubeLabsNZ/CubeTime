import SwiftUI

enum appearanceSettingsKey: String {
    case overrideDM, dmBool, staticGradient, gradientSelected, graphGlow, graphAnimation, scrambleSize, fontWeight, fontCasual, fontCursive
}


struct AppearanceSettingsView: View {
    @Environment(\.colorScheme) var colourScheme
    
    @State private var showThemeOptions: Bool = false
    @State private var showFontSizeOptions: Bool = false
    @State private var showPreview: Bool = false
    
    private let columns = [GridItem(spacing: 16), GridItem(spacing: 16)]
    
    // colours
    @AppStorage(appearanceSettingsKey.staticGradient.rawValue) private var staticGradient: Bool = true
    @AppStorage(appearanceSettingsKey.gradientSelected.rawValue) private var gradientSelected: Int = 6
    @AppStorage(appearanceSettingsKey.graphGlow.rawValue) private var graphGlow: Bool = true
    @AppStorage(appearanceSettingsKey.graphAnimation.rawValue) private var graphAnimation: Bool = true
    
    // system settings (appearance)
    @AppStorage(appearanceSettingsKey.overrideDM.rawValue) private var overrideSystemAppearance: Bool = false
    @AppStorage(appearanceSettingsKey.dmBool.rawValue) private var darkMode: Bool = false
    
    
    @AppStorage(appearanceSettingsKey.scrambleSize.rawValue) private var scrambleSize: Int = 18
    @AppStorage(appearanceSettingsKey.fontWeight.rawValue) private var fontWeight: Double = 516.0
    @AppStorage(appearanceSettingsKey.fontCasual.rawValue) private var fontCasual: Double = 0.0
    @AppStorage(appearanceSettingsKey.fontCursive.rawValue) private var fontCursive: Bool = false
    
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                HStack {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(.subheadline.weight(.bold))

                        .foregroundColor(Color.accentColor)
                    Text("Colours")
                        .font(.body.weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                .padding(.bottom)
                
                VStack(spacing: 0) {
                    
                    #if false
                    HStack {
                        Text("Accent Colour")
                            .font(.body.weight(.medium))
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(accentColours, id: \.self) { colour in
                                
                                // See extension in Helper.swift
                                let isSameColor = UIColor(colour).colorsEqual(UIColor(accentColour))
                                
                                ZStack {
                                    
                                    Circle()
                                        .strokeBorder(colour.opacity(0.25), lineWidth: isSameColor ? 2 : 0)
//                                            .strokeBorder(colour.opacity(0.25), lineWidth: 2)
                                        .frame(width: 31, height: 31)
                                     
                                    
                                    
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(colour)
                                        .font(.system(size: 24))
                                        .shadow(color: isSameColor ? .black.opacity(0.16) : .clear, radius: 6, x: 0, y: 2)
                                        .drawingGroup()
                                        .onTapGesture {
                                            accentColour = colour
                                        }
    //                                    .padding(.horizontal, 3)
                                    
                                    if isSameColor {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            ColorPicker("", selection: $accentColour, supportsOpacity: false)
                            
                        }
                        .padding(.bottom, 4)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 10)
                    #endif
                    
                    
                    
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
                            withAnimation(Animation.customSlowSpring) {
                                showThemeOptions.toggle()
                            }
                        }
                        .padding(.horizontal)
                        
                        
                        Text("Customise the gradients used in stats.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                            .padding(.top, 10)
                        
                        if showThemeOptions {
                            VStack(alignment: .leading, spacing: 0) {
                                /* add this switch back when dynamic gradient added
                                HStack {
                                    Toggle(isOn: $staticGradient) {
                                        Text("Use Static Gradient")
                                            .font(.body.weight(.medium))
                                    }
                                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                                    
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                                 */
                                
                                /*
                                Text("By default, the gradient is static. Dynamic gradient coming soon!")
                                    .font(.footnote.weight(.medium))
                                    .lineSpacing(-4)
//                                Text("By default, the gradient is dynamic and changes throughout the day. If turned off, the gradient will only be of static colours.")
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(Color("grey"))
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 12)
                                 */
                                
                                if staticGradient {
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        ForEach(CustomGradientColours.gradientColours, id: \.self) { gradient in
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                                Rectangle()
                                                    .fill(LinearGradient(gradient: Gradient(colors: gradient), startPoint: .topLeading, endPoint: .bottomTrailing))
                                                    .frame(height: 50)
                                                    .onTapGesture {
                                                        gradientSelected = CustomGradientColours.gradientColours.firstIndex(of: gradient)!
                                                    }
                                                if CustomGradientColours.gradientColours[gradientSelected] == gradient {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 15, weight: .black))
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Toggle(isOn: $graphGlow) {
                                Text("Graph Glow")
                                    .font(.body.weight(.medium))
                            }
                                .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
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
                                .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
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
                        .foregroundColor(Color.accentColor)
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
                            .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, overrideSystemAppearance ? 10 : 12)
                    
                    if overrideSystemAppearance {
                        HStack {
                            Toggle(isOn: $darkMode) {
                                Text("Dark Mode")
                                    .font(.body.weight(.medium))
                            }
                                .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
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
                        .foregroundColor(Color.accentColor)
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
                                .foregroundColor(Color("indent0"))
                            
                            Slider(value: $fontWeight, in: 300...800, step: 1.0)
                                .padding(.horizontal, 4)
                            
                            Text("MAX")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("indent0"))
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .onChange(of: fontWeight) { newValue in
                        fontManager.fontWeight = newValue
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Font Casualness")
                            .font(.body.weight(.medium))
                            .padding(.bottom, 4)
                        
                        HStack {
                            Text("MIN")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("indent0"))
                            
                            Slider(value: $fontCasual, in: 0...1, step: 0.01)
                                .padding(.horizontal, 4)
                            
                            Text("MAX")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("indent0"))
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .onChange(of: fontCasual) { newValue in
                        fontManager.fontCasual = newValue
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Toggle(isOn: $fontCursive) {
                                Text("Cursive Font")
                                    .font(.body.weight(.medium))
                            }
                                .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    .onChange(of: fontCursive) { newValue in
                        fontManager.fontCursive = newValue
                    }
                }
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            
        }
        .padding(.horizontal)
        .preferredColorScheme(overrideSystemAppearance ? darkMode ? .dark : .light : nil)
            .onChange(of: scrambleSize) { newValue in
                fontManager.scrambleSize = newValue
            }
    }
}


struct TimerPreview: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    @AppStorage(appearanceSettingsKey.scrambleSize.rawValue) private var scrambleSize: Int = 18
    
    
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
            .offset(y: 35 + (SetValues.hasBottomBar ? 0 : 8))
        }
    }
}
