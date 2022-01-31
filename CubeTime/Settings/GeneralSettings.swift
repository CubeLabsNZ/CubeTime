import SwiftUI


enum gsKeys: String {
    case inspection, freeze, timeDpWhenRunning, hapBool, hapType, gestureDistance, displayDP, showScramble, showStats, scrambleSize, inspectionCountsDown
}

extension UIImpactFeedbackGenerator.FeedbackStyle: CaseIterable {
    public static var allCases: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy, .soft, .rigid]
    var localizedName: String { "\(self)" }
}

struct GeneralSettingsView: View {
    // timer settings
    @AppStorage(gsKeys.inspection.rawValue) private var inspectionTime: Bool = false
    @AppStorage(gsKeys.inspectionCountsDown.rawValue) private var insCountDown: Bool = false
    @AppStorage(gsKeys.freeze.rawValue) private var holdDownTime: Double = 0.5
    @AppStorage(gsKeys.timeDpWhenRunning.rawValue) private var timerDP: Int = 3
    
    // timer tools
    @AppStorage(gsKeys.showScramble.rawValue) private var showScramble: Bool = true
    @AppStorage(gsKeys.showStats.rawValue) private var showStats: Bool = true
    
    // accessibility
    @AppStorage(gsKeys.hapBool.rawValue) private var hapticFeedback: Bool = true
    @AppStorage(gsKeys.hapType.rawValue) private var feedbackType: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
    @AppStorage(gsKeys.scrambleSize.rawValue) private var scrambleSize: Int = 18
    @AppStorage(gsKeys.gestureDistance.rawValue) private var gestureActivationDistance: Double = 50
    
    // statistics
    @AppStorage(gsKeys.displayDP.rawValue) private var displayDP: Int = 3
    
        
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    let hapticNames: [UIImpactFeedbackGenerator.FeedbackStyle: String] = [
        UIImpactFeedbackGenerator.FeedbackStyle.light: "Light",
        UIImpactFeedbackGenerator.FeedbackStyle.medium: "Medium",
        UIImpactFeedbackGenerator.FeedbackStyle.heavy: "Heavy",
        UIImpactFeedbackGenerator.FeedbackStyle.soft: "Soft",
        UIImpactFeedbackGenerator.FeedbackStyle.rigid: "Rigid"
    ]
    
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
                    Toggle(isOn: $inspectionTime.animation(.spring())) {
                        Text("Inspection Time")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: accentColour))
                    
                }
                .padding(.horizontal)
                .onChange(of: inspectionTime) { newValue in
                    stopWatchManager.inspectionEnabled = newValue
                }
                
                Divider()
                
                if inspectionTime {
                    HStack {
                        Toggle(isOn: $insCountDown) {
                            Text("Inspection Counts Down")
                                .font(.system(size: 17, weight: .medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        
                    }
                    .padding(.horizontal)
                    .onChange(of: insCountDown) { newValue in
                        stopWatchManager.insCountDown = newValue
                    }
                    
                    Divider()
                }
                
                VStack (alignment: .leading) {
                    HStack {
                        Stepper(value: $holdDownTime, in: 0.05...1.0, step: 0.05) {
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
                    .onChange(of: timerDP) { newValue in
                        stopWatchManager.timeDP = newValue
                    }
                }
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "wrench")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(accentColour)
                    Text("Timer Tools")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                
                
                HStack {
                    Toggle(isOn: $showScramble) {
                        Text("Show draw scramble on timer")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: accentColour))
                    
                }
                .padding(.horizontal)
                .onChange(of: inspectionTime) { newValue in
                    stopWatchManager.inspectionEnabled = newValue
                }
                
                Divider()
                
                
                HStack {
                    Toggle(isOn: $showStats) {
                        Text("Show stats on timer")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: accentColour))
                    
                }
                .padding(.horizontal)
                .onChange(of: inspectionTime) { newValue in
                    stopWatchManager.inspectionEnabled = newValue
                }
                
                Text("Show scramble/statistics on the timer screen.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(uiColor: .systemGray))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
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
                
                
                HStack {
                    Toggle(isOn: $hapticFeedback) {
                        Text("Haptic Feedback")
                            .font(.system(size: 17, weight: .medium))
                    }
                }
                .padding(.horizontal)
                .onChange(of: hapticFeedback) { newValue in
                    stopWatchManager.hapticEnabled = newValue
                    stopWatchManager.calculateFeedbackStyle()
                }
                
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
                    .onChange(of: feedbackType) { newValue in
                        stopWatchManager.hapticType = newValue.rawValue
                        stopWatchManager.calculateFeedbackStyle()
                    }
                }
                
                Divider()
                
                
                VStack (alignment: .leading) {
                    HStack {
                        Stepper(value: $scrambleSize, in: 15...36, step: 1) {
                            Text("Scramble Size: ")
                                .font(.system(size: 17, weight: .medium))
                            Text("\(scrambleSize)")
                        }
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
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
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
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            
            
            
            
        }
        .padding(.horizontal)
        
    }
}
