import SwiftUI


enum gsKeys: String {
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
    @AppStorage(gsKeys.inspection.rawValue) private var inspectionTime: Bool = false
    @AppStorage(gsKeys.inspectionCountsDown.rawValue) private var insCountDown: Bool = false
    @AppStorage(gsKeys.showCancelInspection.rawValue) private var showCancelInspection: Bool = true
    @AppStorage(gsKeys.inspectionAlert.rawValue) private var inspectionAlert: Bool = true
    @AppStorage(gsKeys.inspectionAlertType.rawValue) private var inspectionAlertType: Int = 0
    
    @AppStorage(gsKeys.inputMode.rawValue) private var inputMode: InputMode = InputMode.timer
    
    @AppStorage(gsKeys.freeze.rawValue) private var holdDownTime: Double = 0.5
    @AppStorage(gsKeys.timeDpWhenRunning.rawValue) private var timerDP: Int = 3
    @AppStorage(gsKeys.showSessionName.rawValue) private var showSessionName: Bool = false
    
    // timer tools
    @AppStorage(gsKeys.showScramble.rawValue) private var showScramble: Bool = true
    @AppStorage(gsKeys.showStats.rawValue) private var showStats: Bool = true
    
    // accessibility
    @AppStorage(gsKeys.hapBool.rawValue) private var hapticFeedback: Bool = true
    @AppStorage(gsKeys.hapType.rawValue) private var feedbackType: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
    @AppStorage(gsKeys.forceAppZoom.rawValue) private var forceAppZoom: Bool = false
    @AppStorage(gsKeys.appZoom.rawValue) private var appZoom: AppZoomWrapper = AppZoomWrapper(rawValue: 3)
    @AppStorage(gsKeys.gestureDistance.rawValue) private var gestureActivationDistance: Double = 50
    
    // show previous time after delete
    @AppStorage(gsKeys.showPrevTime.rawValue) private var showPrevTime: Bool = false
    
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
        UIImpactFeedbackGenerator.FeedbackStyle.rigid: "Rigid",
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "timer")
                        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentColour)
                    Text("Timer Settings")
                        .font(Font.system(.body, design: .rounded).weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                Group {
                    HStack {
                        Toggle(isOn: $inspectionTime) {
                            Text("Inspection Time")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        
                    }
                    .padding(.horizontal)
                    .onChange(of: inspectionTime) { newValue in
                        stopWatchManager.inspectionEnabled = newValue
                    }
                    
                    
                   
                    if inspectionTime {
                        Toggle(isOn: $insCountDown) {
                            Text("Inspection Counts Down")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        .padding(.horizontal)
                        .onChange(of: insCountDown) { newValue in
                            stopWatchManager.insCountDown = newValue
                        }
                        
                        Toggle(isOn: $showCancelInspection) {
                            Text("Show Cancel Inspection")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        .padding(.horizontal)
                        
                        Text("Display a cancel inspection button when inspecting.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        
                        Toggle(isOn: $inspectionAlert) {
                            Text("Inpsection Alert")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        .padding(.horizontal)
                        .onChange(of: inspectionAlert) { newValue in
                            stopWatchManager.inspectionAlert = newValue
                        }
                        
                        Text("Play an audible alert when 8 or 12 seconds is reached.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color(uiColor: .systemGray))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
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
                                stopWatchManager.inspectionAlertType = newValue
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                
                
                
                Divider()
                
                VStack (alignment: .leading) {
                    Stepper(value: $holdDownTime, in: 0.05...1.0, step: 0.05) {
                        Text("Hold Down Time: ")
                            .font(.body.weight(.medium))
                        Text(String(format: "%.2fs", holdDownTime))
                    }
                    .padding(.horizontal)
                }
                
                
                
                
                
                Divider()
                
                
                
                
                
                
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
                        .accentColor(accentColour)
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
                            .accentColor(accentColour)
                        }
                        .onChange(of: timerDP) { newValue in
                            stopWatchManager.timeDP = newValue
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                
                
                
               
                
                
                
                
                
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "wrench")
                        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentColour)
                    Text("Timer Tools")
                        .font(Font.system(.body, design: .rounded).weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                
                
                HStack {
                    Toggle(isOn: $showScramble) {
                        Text("Show draw scramble on timer")
                            .font(.body.weight(.medium))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: accentColour))
                    
                }
                .padding(.horizontal)
                
                
                HStack {
                    Toggle(isOn: $showStats) {
                        Text("Show stats on timer")
                            .font(.body.weight(.medium))
                    }
//                    .onChange(of: showStats) { newValue in
//                        stopWatchManager.updateStats()
//                    }
                    .toggleStyle(SwitchToggleStyle(tint: accentColour))
                    
                }
                .padding(.horizontal)
                
                Text("Show draw scramble or statistics on the timer screen.")
                    .font(.footnote.weight(.medium))
                    .lineSpacing(-4)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color(uiColor: .systemGray))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentColour)
                    Text("Timer Interface")
                        .font(Font.system(.body, design: .rounded).weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                Group {
                    VStack (alignment: .leading) {
                        Toggle(isOn: $showSessionName) {
                            Text("Show Session Name")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        .padding(.horizontal)
                    }
                    
                    Text("Permanently show session name instead of session type in timer view. Pressing the session type icon will temporarily toggle in the timer view.")
                        .font(.footnote.weight(.medium))
                        .lineSpacing(-4)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(uiColor: .systemGray))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                }
                
                    
                
                Divider()
                
                
                Group {
                    VStack (alignment: .leading) {
                        Toggle(isOn: $showPrevTime) {
                            Text("Show Previous Time")
                                .font(.body.weight(.medium))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: accentColour))
                        .padding(.horizontal)
                        .onChange(of: showPrevTime) { newValue in
                            stopWatchManager.showPrevTime = newValue
                        }
                    }
                    
                    Text("Show the previous time after a solve is deleted by swipe gesture. With this option off, the default time of 0.00 or 0.000 will be shown instead.")
                        .font(.footnote.weight(.medium))
                        .lineSpacing(-4)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color(uiColor: .systemGray))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                }
                
                
                
                
                Divider()
                
                
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
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            VStack {
                HStack {
                    Image(systemName: "eye")
                        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentColour)
                    Text("Accessibility")
                        .font(Font.system(.body, design: .rounded).weight(.bold))
                    
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
                    stopWatchManager.hapticEnabled = newValue
                    stopWatchManager.calculateFeedbackStyle()
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
                        .accentColor(accentColour)
                    }
                    .padding(.horizontal)
                    .onChange(of: feedbackType) { newValue in
                        stopWatchManager.hapticType = newValue.rawValue
                        stopWatchManager.calculateFeedbackStyle()
                    }
                }
                
               
                Divider()
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Gesture Activation Distance")
                        .font(.body.weight(.medium))
                        .padding(.bottom, 4)
                    
                    HStack {
                        Text("MIN")
                            .font(Font.system(.footnote, design: .rounded))
                            .foregroundColor(Color(uiColor: .systemGray2))
                        
                        Slider(value: $gestureActivationDistance, in: 20...300)
                            .padding(.horizontal, 4)
                        
                        Text("MAX")
                            .font(Font.system(.footnote, design: .rounded))
                            .foregroundColor(Color(uiColor: .systemGray2))
                        
                    }
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            VStack {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .font(Font.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(accentColour)
                    Text("Statistics")
                        .font(Font.system(.body, design: .rounded).weight(.bold))
                    
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
                    .accentColor(accentColour)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).shadow(color: Color.black.opacity(colourScheme == .light ? 0.06 : 0), radius: 6, x: 0, y: 3))
            
            
            
            
            
        }
        .padding(.horizontal)
        
    }
}

