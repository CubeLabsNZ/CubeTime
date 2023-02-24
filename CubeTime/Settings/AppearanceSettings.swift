import SwiftUI


struct settingsBlocks: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3))
    }
}

enum asKeys: String {
    case accentColour, overrideDM, dmBool, staticGradient, gradientSelected, graphGlow, graphAnimation, scrambleSize, fontWeight, fontCasual, fontCursive
}


struct AppearanceSettingsView: View {
    @Environment(\.colorScheme) var colourScheme
    
    @State private var showThemeOptions: Bool = false
    @State private var showFontSizeOptions: Bool = false
    @State private var showPreview: Bool = false
    
    let accentColours: [Color] = [.cyan, .blue, .indigo, .purple, .red]
    
    private let columns = [GridItem(spacing: 16), GridItem(spacing: 16)]
    
    // colours
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    @AppStorage(asKeys.staticGradient.rawValue) private var staticGradient: Bool = true
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    @AppStorage(asKeys.graphGlow.rawValue) private var graphGlow: Bool = true
    @AppStorage(asKeys.graphAnimation.rawValue) private var graphAnimation: Bool = true
    
    // system settings (appearance)
    @AppStorage(asKeys.overrideDM.rawValue) private var overrideSystemAppearance: Bool = false
    @AppStorage(asKeys.dmBool.rawValue) private var darkMode: Bool = false
    
    
    @AppStorage(asKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    @AppStorage(asKeys.fontWeight.rawValue) private var fontWeight: Double = 516.0
    @AppStorage(asKeys.fontCasual.rawValue) private var fontCasual: Double = 0.0
    @AppStorage(asKeys.fontCursive.rawValue) private var fontCursive: Bool = false
    
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                HStack {
                    Image(systemName: "paintbrush.pointed.fill")
                        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentColour)
                    Text("Colours")
                        .font(Font.system(.body, design: .rounded).weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                .padding(.bottom)
                
                VStack(spacing: 0) {
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
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center) {
                            Text("Theme")
                                .font(.body.weight(.medium))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.bold))
                                .foregroundColor(Color(uiColor: .systemGray3))
                                .rotationEffect(.degrees(showThemeOptions ? 90 : 0))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showThemeOptions.toggle()
                            }
                        }
                        .padding(.horizontal)
                        
                        
                        Text("Customise the app theme and gradients.\nNote: separate from the accent colour.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(uiColor: .systemGray))
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
                                    .foregroundColor(Color(uiColor: .systemGray))
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
                                .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                       
                        Text("Turn on/off the glow effect on graphs.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(uiColor: .systemGray))
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
                                .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                       
                        Text("Turn on/off the line animation for the time trend graph.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                    }
                }
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            VStack {
                HStack {
                    Image(systemName: "command")
                        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentColour)
                    Text("System Settings")
                        .font(Font.system(.body, design: .rounded).weight(.bold))
                    
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
                            .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, overrideSystemAppearance ? 10 : 12)
                    
                    if overrideSystemAppearance {
                        HStack {
                            Toggle(isOn: $darkMode) {
                                Text("Dark Mode")
                                    .font(.body.weight(.medium))
                            }
                                .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            
            VStack {
                HStack {
                    Image(systemName: "textformat")
                        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentColour)
                    Text("Font Settings")
                        .font(Font.system(.body, design: .rounded).weight(.bold))
                    
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
                        .foregroundColor(Color(uiColor: .systemGray))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    
                    
                    VStack {
                        Text("L' D R2 B2 D2 F2 R2 B2 D R2 D R2 U B' R F2 R U' F L2 D'")
                            .font(stopWatchManager.ctFontScramble)
                            .padding()
                        
                        
                        Text("Tap for Fullscreen Preview")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding([.trailing, .bottom], 8)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.bg(colourScheme))
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
                                .foregroundColor(Color(uiColor: .systemGray2))
                            
                            Slider(value: $fontWeight, in: 300...800, step: 1.0)
                                .padding(.horizontal, 4)
                            
                            Text("MAX")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color(uiColor: .systemGray2))
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .onChange(of: fontWeight) { newValue in
                        stopWatchManager.fontWeight = newValue
                        stopWatchManager.updateFont()
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Font Casualness")
                            .font(.body.weight(.medium))
                            .padding(.bottom, 4)
                        
                        HStack {
                            Text("MIN")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color(uiColor: .systemGray2))
                            
                            Slider(value: $fontCasual, in: 0...1, step: 0.01)
                                .padding(.horizontal, 4)
                            
                            Text("MAX")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color(uiColor: .systemGray2))
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .onChange(of: fontCasual) { newValue in
                        stopWatchManager.fontCasual = newValue
                        stopWatchManager.updateFont()
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Toggle(isOn: $fontCursive) {
                                Text("Cursive Font")
                                    .font(.body.weight(.medium))
                            }
                                .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                    .onChange(of: fontCursive) { newValue in
                        stopWatchManager.fontCursive = newValue
                        stopWatchManager.updateFont()
                    }
                }
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            
        }
        .padding(.horizontal)
        .preferredColorScheme(overrideSystemAppearance ? darkMode ? .dark : .light : nil)
            .onChange(of: scrambleSize) { newValue in
                stopWatchManager.scrambleSize = newValue
                stopWatchManager.updateFont()
            }
    }
}


struct TimerPreview: View {
    @EnvironmentObject var stopwatchManager: StopWatchManager
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    @AppStorage(asKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    
    
    var body: some View {
        ZStack {
            // BACKGROUND COLOUR
            Color.bg(colourScheme)
                .ignoresSafeArea()
            
            Text("0.000")
                .foregroundColor(Color(uiColor: .systemGray))
                .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDescBold,
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
                
                CloseButton()
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(0)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal)
            
            VStack {
                Text("L' D R2 B2 D2 F2 R2 B2 D R2 D R2 U B' R F2 R U' F L2 D'")
                    .font(stopwatchManager.ctFontScramble)
                    .frame(maxHeight: globalGeometrySize.height/3)
                    .multilineTextAlignment(.center)
                    
                
                Spacer()
            }
            .padding(.horizontal)
            .offset(y: 35 + (SetValues.hasBottomBar ? 0 : 8))
        }
    }
}
