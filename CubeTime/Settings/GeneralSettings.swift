import SwiftUI


enum generalSettingsKey: String {
    case freeze,
         inspection, inspectionCountsDown, showCancelInspection, inspectionAlert, inspectionAlertType,
         inputMode,
         timeDpWhenRunning,
         showSessionName,
         hapBool, hapType,
         gestureDistance,
         showScramble, showStats,
         appZoom, forceAppZoom,
         showPrevTime,
         displayDP
}

enum InputMode: String, Codable, CaseIterable {
    case timer = "Timer"
    case typing = "Typing"
    /*, stackmat, smartcube, virtual*/
}

extension UIImpactFeedbackGenerator.FeedbackStyle: CaseIterable {
    public static var allCases: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .heavy, .soft, .rigid]
    var localizedName: String { "\(self)" }
}





struct GeneralSettingsView: View {
    // timer settings
    @AppStorage(generalSettingsKey.inspection.rawValue) private var inspectionTime: Bool = false
    @AppStorage(generalSettingsKey.inspectionCountsDown.rawValue) private var insCountDown: Bool = false
    @AppStorage(generalSettingsKey.showCancelInspection.rawValue) private var showCancelInspection: Bool = true
    @AppStorage(generalSettingsKey.inspectionAlert.rawValue) private var inspectionAlert: Bool = true
    @AppStorage(generalSettingsKey.inspectionAlertType.rawValue) private var inspectionAlertType: Int = 0
    
    @AppStorage(generalSettingsKey.inputMode.rawValue) private var inputMode: InputMode = InputMode.timer
    
    @AppStorage(generalSettingsKey.freeze.rawValue) private var holdDownTime: Double = 0.5
    @AppStorage(generalSettingsKey.timeDpWhenRunning.rawValue) private var timerDP: Int = 3
    @AppStorage(generalSettingsKey.showSessionName.rawValue) private var showSessionName: Bool = false
    
    // timer tools
    @AppStorage(generalSettingsKey.showScramble.rawValue) private var showScramble: Bool = true
    @AppStorage(generalSettingsKey.showStats.rawValue) private var showStats: Bool = true
    
    // accessibility
    @AppStorage(generalSettingsKey.hapBool.rawValue) private var hapticFeedback: Bool = true
    @AppStorage(generalSettingsKey.hapType.rawValue) private var feedbackType: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
    @AppStorage(generalSettingsKey.forceAppZoom.rawValue) private var forceAppZoom: Bool = false
    @AppStorage(generalSettingsKey.appZoom.rawValue) private var appZoom: AppZoomWrapper = AppZoomWrapper(rawValue: 3)
    @AppStorage(generalSettingsKey.gestureDistance.rawValue) private var gestureActivationDistance: Double = 50
    
    // show previous time after delete
    @AppStorage(generalSettingsKey.showPrevTime.rawValue) private var showPrevTime: Bool = false
    
    // statistics
    @AppStorage(generalSettingsKey.displayDP.rawValue) private var displayDP: Int = 3
    
    
        
    @Environment(\.colorScheme) var colourScheme
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    
    let hapticNames: [UIImpactFeedbackGenerator.FeedbackStyle: String] = [
        UIImpactFeedbackGenerator.FeedbackStyle.light: "Light",
        UIImpactFeedbackGenerator.FeedbackStyle.medium: "Medium",
        UIImpactFeedbackGenerator.FeedbackStyle.heavy: "Heavy",
        UIImpactFeedbackGenerator.FeedbackStyle.soft: "Soft",
        UIImpactFeedbackGenerator.FeedbackStyle.rigid: "Rigid",
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "timer")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.accentColor)
                    Text("Timer Settings")
                        .font(.body.weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                Group {
                    HStack {
                        Toggle(isOn: $inspectionTime) {
                            Text("Inspection Time")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        
                    }
                    .padding(.horizontal)
                    .onChange(of: inspectionTime) { newValue in
                        stopwatchManager.timerController.inspectionEnabled = newValue
                    }
                    
                    
                   
                    if inspectionTime {
                        Toggle(isOn: $insCountDown) {
                            Text("Inspection Counts Down")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .padding(.horizontal)
                        .onChange(of: insCountDown) { newValue in
                            stopwatchManager.timerController.insCountDown = newValue
                        }
                        
                        Toggle(isOn: $showCancelInspection) {
                            Text("Show Cancel Inspection")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .padding(.horizontal)
                        
                        Text("Display a cancel inspection button when inspecting.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        
                        Toggle(isOn: $inspectionAlert) {
                            Text("Inpsection Alert")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .padding(.horizontal)
                        .onChange(of: inspectionAlert) { newValue in
                            stopwatchManager.timerController.inspectionAlert = newValue
                        }
                        
                        Text("Play an audible alert when 8 or 12 seconds is reached.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        if inspectionAlert {
                            HStack {
                                Text("Inspection Alert Type")
                                    .font(.body.weight(.medium))
                                
                                Spacer()
                                
                                Picker("", selection: $inspectionAlertType) {
                                    Text("Voice").tag(0)
                                    Text("Boop").tag(1)
                                }
                                .frame(maxWidth: 120)
                                .pickerStyle(.segmented)
                                .onChange(of: inspectionAlertType) { newValue in
                                    stopwatchManager.timerController.inspectionAlertType = newValue
                                }
                            }
                            .padding(.horizontal)
                            
                            
                            Text("Note: to use the 'Boop' option, your phone must not be muted. 'Boop' plays a system sound, requiring your ringer to be unmuted.")
                                .font(.footnote.weight(.medium))
                                .lineSpacing(-4)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(Color("grey"))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        }
                    }
                }
                
                
                
                
                ThemedDivider()
                    .padding(.leading)
                
                
                
                HStack {
                    Text("Hold Down Time: ")
                        .font(.body.weight(.medium))
                    Text(String(format: "%.2fs", holdDownTime))
                    
                    Spacer()
                    
                    Stepper("", value: $holdDownTime, in: 0.05...1.0, step: 0.05)
                }
                .padding(.horizontal)
                
                
                ThemedDivider()
                    .padding(.leading)
                
                
                
                VStack (alignment: .leading) {
                    HStack {
                        Text("Timer Mode")
                            .font(.body.weight(.medium))
                        
                        Spacer()
                        
                        
                        
                        Menu {
                            Picker("", selection: $inputMode) {
                                ForEach(Array(InputMode.allCases), id: \.self) { mode in
                                    Text(mode.rawValue)
                                }
                            }
                        } label: {
                            Text(inputMode.rawValue)
                                .frame(width: 100, alignment: .trailing)
                                .font(.body)
                        }
                        .accentColor(Color.accentColor)
                    }
                    
                    if inputMode == .timer {
                        HStack(alignment: .center) {
                            Text("Timer Update")
                                .font(.body.weight(.medium))
                            
                            Spacer()
                            
                            Menu {
                                Picker("", selection: $timerDP) {
                                    Text("None")
                                        .tag(-1)
                                    ForEach(0...3, id: \.self) {
                                        Text("\($0) d.p")
                                    }
                                }
                            } label: {
                                Text(timerDP == -1 ? "None" : "\(timerDP) d.p")
                                    .font(.body)
                                    .frame(width: 100, alignment: .trailing)
                            }
                            .accentColor(Color.accentColor)
                        }
                        .onChange(of: timerDP) { newValue in
                            stopwatchManager.timerController.timeDP = newValue
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            
            
            
            
            
            
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "wrench")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.accentColor)
                    Text("Timer Tools")
                        .font(.body.weight(.bold))

                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                
                
                HStack {
                    Toggle(isOn: $showScramble) {
                        Text("Show draw scramble on timer")
                            .font(.body.weight(.medium))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    
                }
                .padding(.horizontal)
                
                
                HStack {
                    Toggle(isOn: $showStats) {
                        Text("Show stats on timer")
                            .font(.body.weight(.medium))
                    }
//                    .onChange(of: showStats) { newValue in
//                        stopwatchManager.updateStats()
//                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                    
                }
                .padding(.horizontal)
                
                Text("Show draw scramble or statistics on the timer screen.")
                    .font(.footnote.weight(.medium))
                    .lineSpacing(-4)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color("grey"))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.accentColor)
                    Text("Timer Interface")
                        .font(.body.weight(.bold))

                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                Group {
                    VStack (alignment: .leading) {
                        Toggle(isOn: $showPrevTime) {
                            Text("Show Previous Time")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: Color.accentColor))
                        .padding(.horizontal)
                        .onChange(of: showPrevTime) { newValue in
                            stopwatchManager.showPrevTime = newValue
                        }
                    }
                    
                    Text("Show the previous time after a solve is deleted by swipe gesture. With this option off, the default time of 0.00 or 0.000 will be shown instead.")
                        .font(.footnote.weight(.medium))
                        .lineSpacing(-4)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color("grey"))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                }
                
                
                /*
                HStack {
                    Toggle(isOn: $forceAppZoom) {
                        Text("Override System Zoom")
                            .font(.body.weight(.medium))
                    }
                }
                .padding(.horizontal)
                
                
                VStack (alignment: .leading) {
                    HStack {
                        Text("App Zoom")
                            .font(.body.weight(.medium))

                        Spacer()

                        Picker("", selection: $appZoom) {
                            ForEach(0..<AppZoomWrapper.allCases.count, id: \.self) { mode in
                                Text(AppZoomWrapper.appZoomNames[mode])
                            }
                        }
                        .pickerStyle(.menu)
                        .accentColor(accentColour)
                        .font(.body)
                    }
                    .padding(.horizontal)
                }
                 */
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            VStack {
                HStack {
                    Image(systemName: "eye")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.accentColor)
                    Text("Accessibility")
                        .font(.body.weight(.bold))

                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                
                HStack {
                    Toggle(isOn: $hapticFeedback) {
                        Text("Haptic Feedback")
                            .font(.body.weight(.medium))
                    }
                }
                .padding(.horizontal)
                .onChange(of: hapticFeedback) { newValue in
                    stopwatchManager.timerController.hapticEnabled = newValue
                }
                
                if hapticFeedback {
                    HStack {
                        Text("Haptic Intensity")
                            .font(.body.weight(.medium))
                        
                        Spacer()
                        
                        
                        
                        Menu {
                            Picker("", selection: $feedbackType) {
                                ForEach(Array(UIImpactFeedbackGenerator.FeedbackStyle.allCases), id: \.self) { mode in
                                    Text(hapticNames[mode]!)
                                }
                            }
                        } label: {
                            Text(hapticNames[feedbackType]!)
                                .frame(width: 100, alignment: .trailing)
                                .font(.body)
                        }
                        .accentColor(Color.accentColor)
                    }
                    .padding(.horizontal)
                    .onChange(of: feedbackType) { newValue in
                        stopwatchManager.timerController.hapticType = newValue.rawValue
                    }
                }
                
               
                ThemedDivider()
                    .padding(.leading)
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Gesture Activation Distance")
                        .font(.body.weight(.medium))
                        .padding(.bottom, 4)
                    
                    HStack {
                        Text("MIN")
                            .font(Font.system(.footnote, design: .rounded))
                            .foregroundColor(Color("indent0"))
                        
                        Slider(value: $gestureActivationDistance, in: 20...300)
                            .padding(.horizontal, 4)
                        
                        Text("MAX")
                            .font(Font.system(.footnote, design: .rounded))
                            .foregroundColor(Color("indent0"))
                        
                    }
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            VStack {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color.accentColor)
                    Text("Statistics")
                        .font(.body.weight(.bold))

                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                HStack {
                    Text("Times Displayed To: ")
                        .font(.body.weight(.medium))
                    
                    Spacer()
                    
                    Menu {
                        Picker("", selection: $displayDP) {
                            ForEach(2...3, id: \.self) {
                                Text("\($0) d.p")
                                    .tag($0)
                            }
                        }
                    } label: {
                        Text("\(displayDP) d.p")
                            .font(.body)
                            .frame(width: 100, alignment: .trailing)
                    }
                    .accentColor(Color.accentColor)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
        }
        .padding(.horizontal)
        
    }
}

