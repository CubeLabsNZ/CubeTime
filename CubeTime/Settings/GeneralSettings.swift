import SwiftUI

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
    @Preference(\.inspection) private var inspectionTime
    @Preference(\.inspectionCountsDown) private var insCountDown
    @Preference(\.showCancelInspection) private var showCancelInspection
    @Preference(\.inspectionAlert) private var inspectionAlert
    @Preference(\.inspectionAlertType) private var inspectionAlertType
    
    @Preference(\.inputMode) private var inputMode
    
    @Preference(\.holdDownTime) private var holdDownTime
    @Preference(\.timeDpWhenRunning) private var timerDP
    
    // timer tools
    @Preference(\.showScramble) private var showScramble
    @Preference(\.showStats) private var showStats
    
    // accessibility
    @Preference(\.hapticEnabled) private var hapticFeedback
    @Preference(\.hapticType) private var feedbackType
    @Preference(\.forceAppZoom) private var forceAppZoom
    @Preference(\.appZoom) private var appZoom
    @Preference(\.gestureDistance) private var gestureActivationDistance
    @Preference(\.gestureDistanceTrackpad) private var gestureDistanceTrackpad
    
    // show previous time after delete
    @Preference(\.showPrevTime) private var showPrevTime
    
    // statistics
    @Preference(\.displayDP) private var displayDP
    
    
        
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
                        .foregroundColor(Color("accent"))
                    Text("Timer Settings")
                        .font(.body.weight(.bold))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                VStack(alignment: .leading) {
                    HStack {
                        Toggle(isOn: $inspectionTime) {
                            Text("Use Inspection")
                                .font(.body.weight(.medium))
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    if inspectionTime {
                        Toggle(isOn: $insCountDown) {
                            Text("Inspection Counts Down")
                                .font(.body.weight(.medium))
                        }
                        .padding(.horizontal)
                        
                        Toggle(isOn: $showCancelInspection) {
                            Text("Show Cancel Inspection")
                                .font(.body.weight(.medium))
                        }
                        .padding(.horizontal)
                        
                        Text("Display a cancel inspection button when inspecting.")
                            .font(.footnote.weight(.medium))
                            .lineSpacing(-4)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(Color("grey"))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        
                        Toggle(isOn: $inspectionAlert.animation()) {
                            Text("Inpsection Alert")
                                .font(.body.weight(.medium))
                        }
                        .padding(.horizontal)
                        
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
                            }
                            .padding(.horizontal)
                            
                            
                            Text("To use the 'Boop' option, your phone must not be muted. 'Boop' plays a system sound, requiring your ringer to be unmuted.")
                                .font(.footnote.weight(.medium))
                                .lineSpacing(-4)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(Color("grey"))
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        }
                    }

                }
                .clipped()
                
                
                
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
                        .foregroundColor(Color("accent"))
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
                        .foregroundColor(Color("accent"))
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
                        .padding(.horizontal)
                    }
                    
                    Text("Show the previous time after a solve is deleted by swipe gesture. With this option off, the default time of 0.00 or 0.000 will be shown instead.")
                        .font(.footnote.weight(.medium))
                        .lineSpacing(-4)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(Color("grey"))
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
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
                            ForEach(0..<AppZoom.allCases.count, id: \.self) { mode in
                                Text(AppZoom.appZoomNames[mode])
                            }
                        }
                        .pickerStyle(.menu)
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
                        .foregroundColor(Color("accent"))
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
                    }
                    .padding(.horizontal)
                }
                
               
                ThemedDivider()
                    .padding(.leading)
                
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(UIDevice.deviceIsPad ? "Touch Gesture Activation Distance" : "Gesture Activation Distance")
                        .font(.body.weight(.medium))
                        .padding(.bottom, 4)
                    
                    HStack {
                        Text("MIN")
                            .font(Font.system(.footnote, design: .rounded))
                            .foregroundColor(Color("grey"))
                        
                        Slider(value: $gestureActivationDistance, in: 20...300)
                            .padding(.horizontal, 4)
                        
                        Text("MAX")
                            .font(Font.system(.footnote, design: .rounded))
                            .foregroundColor(Color("grey"))
                        
                    }
                    
                    
                }
                .padding(.horizontal)
                .padding(.bottom, UIDevice.deviceIsPad ? 0 : 12)
                
                
                if UIDevice.deviceIsPad {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Trackpad Gesture Activation Distance")
                            .font(.body.weight(.medium))
                            .padding(.bottom, 4)
                        
                        HStack {
                            Text("MIN")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("grey"))
                            
                            Slider(value: $gestureActivationDistance, in: 100...1000)
                                .padding(.horizontal, 4)
                            
                            Text("MAX")
                                .font(Font.system(.footnote, design: .rounded))
                                .foregroundColor(Color("grey"))
                            
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
            
            VStack {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Color("accent"))
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
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .background(Color("overlay0").clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)))
        }
        .padding(.horizontal)
        .animation(Animation.customSlowSpring, value: inspectionTime)
    }
}

