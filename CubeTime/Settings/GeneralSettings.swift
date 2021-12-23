import SwiftUI


enum gsKeys: String {
    case inspection, freeze, timeDpWhenRunning, hapBool, hapType, gestureDistance, displayDP
}

extension UIImpactFeedbackGenerator.FeedbackStyle: CaseIterable {
    public static var allCases: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy, .soft, .rigid]
    var localizedName: String { "\(self)" }
}

struct GeneralSettingsView: View {
    
    @AppStorage(gsKeys.inspection.rawValue) var inspectionTime: Bool = false
    @AppStorage(gsKeys.freeze.rawValue) var holdDownTime: Double = 0.5
    @AppStorage(gsKeys.timeDpWhenRunning.rawValue) var timerDP: Int = 3
    @AppStorage(gsKeys.hapBool.rawValue) var hapticFeedback: Bool = true
    @AppStorage(gsKeys.hapType.rawValue) var feedbackType: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
    @AppStorage(gsKeys.gestureDistance.rawValue) var gestureActivationDistance: Double = 50
    @AppStorage(gsKeys.displayDP.rawValue) var displayDP: Int = 3
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    let hapticNames: [UIImpactFeedbackGenerator.FeedbackStyle: String] = [
        UIImpactFeedbackGenerator.FeedbackStyle.light: "Light",
        UIImpactFeedbackGenerator.FeedbackStyle.medium: "Medium",
        UIImpactFeedbackGenerator.FeedbackStyle.heavy: "Heavy",
        UIImpactFeedbackGenerator.FeedbackStyle.soft: "Soft",
        UIImpactFeedbackGenerator.FeedbackStyle.rigid: "Rigid"
    ]
    
    @Environment(\.colorScheme) var colourScheme
    
    
    // im thinking of using these interval modes: seconds, 0.1s, 0.001, your refresh rate
    // and for haptics just .light, .medium, .heavy, .rigid, .soft
    // and we need to have a clear to defaults option or something
    
    var body: some View {
        VStack(spacing: 16) {
            VStack {
                HStack {
                    Image(systemName: "timer")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(accentColour)
                    Text("Timer Settings")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                HStack {
                    Toggle(isOn: $inspectionTime) {
                        Text("Inspection Time")
                            .font(.system(size: 17, weight: .medium))
                    }
                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                    
                }
                .padding(.horizontal)
                
                Divider()
                
                
                VStack (alignment: .leading) {
                    HStack {
                        Stepper(value: $holdDownTime, in: 0.2...1.0, step: 0.05) {
                            Text("Hold Down Time: ")
                                .font(.system(size: 17, weight: .medium))
                            Text(String(format: "%.2fs", holdDownTime))
                        }
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                VStack (alignment: .leading) {
                    HStack {
                        Text("Timer Update")
                            .font(.system(size: 17, weight: .medium))
                        Spacer()
                        Picker("", selection: $timerDP) {
                            Text("Nothing")
                                .tag(-1)
                            ForEach(0...3, id: \.self) {
                                Text("\($0) d.p")
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(accentColour)
                        .font(.system(size: 17, weight: .regular))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
            }
//            .modifier(settingsBlocks())
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            VStack {
                HStack {
                    Image(systemName: "eye")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(accentColour)
                    Text("Accessibility")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                
                
                
                Divider()
                
                HStack {
                    Toggle(isOn: $hapticFeedback) {
                        Text("Haptic Feedback")
                            .font(.system(size: 17, weight: .medium))
                    }
//                        .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    
                }
                .padding(.horizontal)
                
                if hapticFeedback {
                    HStack {
                        Text("Haptic Mode")
                            .font(.system(size: 17, weight: .medium))
                        
                        Spacer()
                        
                        Picker("", selection: $feedbackType) {
                            ForEach(Array(UIImpactFeedbackGenerator.FeedbackStyle.allCases), id: \.self) { mode in
                                Text(hapticNames[mode]!)
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(accentColour)
                        .font(.system(size: 17, weight: .regular))
                        
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Gesture Activation Distance")
                        .font(.system(size: 17, weight: .medium))
                        .padding(.bottom, 4)
                    
                    HStack {
                        Text("MIN")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color(uiColor: .systemGray2))
                        
                        Slider(value: $gestureActivationDistance, in: 20...300)
                            .padding(.horizontal, 4)
                        
                        Text("MAX")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color(uiColor: .systemGray2))
                        
                    }
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            VStack {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(accentColour)
                    Text("Statistics")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                HStack {
                    Text("Times Displayed To: ")
                        .font(.system(size: 17, weight: .medium))
                    
                    Spacer()
                    
                    Picker("", selection: $displayDP) {
                        ForEach(2...3, id: \.self) {
                            Text("\($0) d.p")
                                .tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 17, weight: .regular))
                    .accentColor(accentColour)
                    .foregroundColor(accentColour)
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
//            .modifier(settingsBlocks())
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            
            
            
            
        }
        .padding(.horizontal)
        
    }
}
