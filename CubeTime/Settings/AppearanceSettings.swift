import SwiftUI

struct AppearanceSettingsView: View {
    @State private var showThemeOptions: Bool = false
    @State private var showFontSizeOptions: Bool = false
    @State private var showPreview: Bool = false
    
    // gradients
    @Preference(\.isStaticGradient) private var isStaticGradient
    @Preference(\.graphGlow) private var graphGlow
    @Preference(\.graphAnimation) private var graphAnimation
    @Preference(\.showConfetti) private var showConfetti

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
    
    @State private var showResetDialog = false
    
    var body: some View {
        VStack(spacing: 16) {
            SettingsGroup(Label("General Appearance", systemImage: "paintbrush.pointed.fill")) {
                DescribedSetting(description: "Customise the gradients used in stats. By default, the gradient is set to \"Static\". You can choose to set it to \"Dynamic\", where the gradient will change throughout the day.") {
                    HStack() {
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
                }
                .padding(.top)
                
                ConditionalSetting(showIf: showThemeOptions) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text("STATIC GRADIENT")
                                    .foregroundColor(Color("dark"))
                                    .font(.footnote.weight(.semibold))
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(GradientManager.getGradient(gradientSelected: gradientManager.appGradient, isStaticGradient: true))
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
                                    .foregroundColor(Color("dark"))
                                    .font(.footnote.weight(.semibold))
                                
                                ZStack {
                                    HStack(spacing: 0) {
                                        ForEach(0..<10, id: \.self) { index in
                                            Rectangle()
                                                .fill(GradientManager.getGradient(gradientSelected: index, isStaticGradient: false))
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
                    .padding(.bottom, 4)
                    .padding(.top, 8)
                }
                
                CTDivider()
                
                DescribedSetting(description: "Turn on/off the glow effect on graphs.", {
                    SettingsToggle(String(localized: "Graph Glow"), $graphGlow)
                })
                
                DescribedSetting(description: "Turn on/off the line animation for the time trend graph.", {
                    SettingsToggle(String(localized: "Graph Animation"), $graphAnimation)
                })
                
                DescribedSetting(description: "Show a confetti animation when a new best time is recorded.", {
                    SettingsToggle(String(localized: "Show Confetti"), $showConfetti)
                })
            }
            .clipped()
            
            SettingsGroup(Label("System Settings", systemImage: "command")) {
                SettingsToggle(String(localized: "Override System Appearance"), $overrideSystemAppearance)
                if overrideSystemAppearance {
                    SettingsToggle(String(localized: "Dark Mode"), $darkMode)
                }
            }
            
            
            SettingsGroup(Label("Font Settings", systemImage: "textformat")) {
                SettingsStepper(text: String(localized: "Scramble Size: "), format: "%d", value: $scrambleSize, in: 15...36, step: 1)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Preview")
                        .modifier(SettingsFootnote())
                    
                    VStack {
                        Text("L' D R2 B2 D2 F2 R2 B2 D R2 D R2 U B' R F2 R U' F L2 D'")
                            .fixedSize(horizontal: false, vertical: true)
                            .font(fontManager.ctFontScramble)
                            .padding()
                        
                        
                        Text("Tap for Fullscreen Preview")
                            .modifier(SettingsFootnote())
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding([.trailing, .bottom], 8)
                        
                    }
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
                }
                
                SettingsDragger(text: String(localized: "Font Weight"), value: $fontWeight, in: 300...800)
                SettingsDragger(text: String(localized: "Font Casualness"), value: $fontCasual, in: 0...1)
                SettingsToggle(String(localized: "Cursive Font"), $fontCursive)
            }
            
            CTButton(type: .halfcoloured(Color("red")), size: .large, expandWidth: true, onTapRun: {
                showResetDialog = true
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    
                    Text("Reset Appearance Settings")
                }
            }
            .padding(.top, 12)
        }
        .padding(.horizontal)
        .confirmationDialog("Are you sure you want to reset all appearance settings? Your solves and sessions will be kept.",
                            isPresented: $showResetDialog,
                            titleVisibility: .visible) {
                                    Button("Reset", role: .destructive) {
                                        SettingsManager.standard.resetAppearanceSettings()
                                    }
                                }
    }
}


struct TimerPreview: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
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
                                                          (UIDevice.deviceModelName == "iPhoneSE") ? 54 : 56
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
                
                CTCloseButton {
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
