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


let hapticNames: [UIImpactFeedbackGenerator.FeedbackStyle: String] = [
    UIImpactFeedbackGenerator.FeedbackStyle.light: "Light",
    UIImpactFeedbackGenerator.FeedbackStyle.medium: "Medium",
    UIImpactFeedbackGenerator.FeedbackStyle.heavy: "Heavy",
    UIImpactFeedbackGenerator.FeedbackStyle.soft: "Soft",
    UIImpactFeedbackGenerator.FeedbackStyle.rigid: "Rigid",
]

struct GeneralSettingsView: View {
    // timer settings
    @Preference(\.inspection) private var inspectionTime
    @Preference(\.inspectionCountsDown) private var insCountDown
    @Preference(\.showCancelInspection) private var showCancelInspection
    @Preference(\.inspectionAlert) private var inspectionAlert
    @Preference(\.inspectionAlertType) private var inspectionAlertType
    @Preference(\.inspectionAlertFollowsSilent) private var inspectionAlertFollowsSilent
    
    @Preference(\.inputMode) private var inputMode
    
    @Preference(\.holdDownTime) private var holdDownTime
    @Preference(\.timeDpWhenRunning) private var timerDP
    
    // timer tools
    @Preference(\.showScramble) private var showScramble
    @Preference(\.showStats) private var showStats
    @Preference(\.showZenMode) private var showZenMode
    
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
    
    var body: some View {
        VStack(spacing: 16) {
            SettingsGroup(Label("Timer Settings", systemImage: "timer")) {
                
                SettingsToggle("Use Inspection", $inspectionTime)
                
                if inspectionTime {
                    SettingsToggle("Inspection Counts Down", $insCountDown)
                    
                    DescribedSetting(description: "Display a cancel inspection button when inspecting.") {
                        SettingsToggle("Show Cancel Inspection", $showCancelInspection)
                    }
                    
                    DescribedSetting(description: "Play an audible alert when 8 or 12 seconds is reached.") {
                        SettingsToggle("Inpsection Alert", $inspectionAlert)
                    }
                    
                    if inspectionAlert {
                        DescribedSetting(description: "To use the 'Boop' option, your phone must not be muted. 'Boop' plays a system sound, requiring your ringer to be unmuted.") {
                            
                            SettingsPicker(text: "Inspection Alert Type", selection: $inspectionAlertType, maxWidth: 120) {
                                Text("Voice").tag(0)
                                Text("Boop").tag(1)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        DescribedSetting(description: "With this setting on, the **Voice** alert type will play through system audio, respecting your phone's ringer mute state.") {
                            SettingsToggle("Inspection Alert Follows System Silent Mode", $inspectionAlertFollowsSilent)
                        }
                        .onChange(of: inspectionAlertFollowsSilent, perform: { _ in
                            setupAudioSession(with: inspectionAlertFollowsSilent ? .ambient : .playback)
                        })
                    }
                }
                
                ThemedDivider()
                
                SettingsStepper(text: "Hold Down Time: ", format: "%.2fs", value: $holdDownTime, in: 0.05...1.0, step: 0.05)
                
                ThemedDivider()
                
                SettingsPicker(text: "Timer Mode", selection: $inputMode) {
                    ForEach(Array(InputMode.allCases), id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                }
                .pickerStyle(.menu)
            
                
                if inputMode == .timer {
                    SettingsPicker(text: "Timer Update", selection: $timerDP) {
                        Text("None")
                            .tag(-1)
                        ForEach(0...3, id: \.self) {
                            Text("\($0) d.p")
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            SettingsGroup(Label("Timer Tools", systemImage: "wrench")) {
                DescribedSetting(description: "Show tools on the timer screen.") {
                    SettingsToggle("Show draw scramble on timer", $showScramble)
                    if !UIDevice.deviceIsPad {
                        SettingsToggle("Show stats on timer", $showStats)
                    }
                }
                var desc = "Show a button in the top right corner to enter zen mode."
                if UIDevice.deviceIsPad {
                    let _ = {desc += " Note that this is only applicable in compact UI mode (i.e. when the floating panel is not shown)."}()
                }
                DescribedSetting(description: LocalizedStringKey.init(desc)) {
                    SettingsToggle("Show zen mode button", $showZenMode)
                }
            }
            
            SettingsGroup(Label("Timer Interface", systemImage: "rectangle.and.pencil.and.ellipsis")) {
                DescribedSetting(description: "Show the previous time after a solve is deleted by swipe gesture. With this option off, the default time of 0.00 or 0.000 will be shown instead.") {
                    SettingsToggle("Show Previous Time", $showPrevTime)
                }
            }
            
            SettingsGroup(Label("Accessibility", systemImage: "eye")) {
                SettingsToggle("Haptic Feedback", $hapticFeedback)
                if hapticFeedback {
                    SettingsPicker(text: "Haptic Intensity", selection: $feedbackType) {
                        ForEach(Array(UIImpactFeedbackGenerator.FeedbackStyle.allCases), id: \.self) { mode in
                            Text(hapticNames[mode]!)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                ThemedDivider()
                
                SettingsDragger(text: UIDevice.deviceIsPad ? "Touch Gesture Activation Distance" : "Gesture Activation Distance", value: $gestureActivationDistance, in: 20...300)
                
                if UIDevice.deviceIsPad {
                    SettingsDragger(text: "Trackpad Gesture Activation Distance", value: $gestureDistanceTrackpad, in: 100...1000)
                }
                
            }
            
            SettingsGroup(Label("Statistics", systemImage: "chart.bar.xaxis")) {
                SettingsPicker(text: "Times Displayed To: ", selection: $displayDP) {
                    ForEach(2...3, id: \.self) {
                        Text("\($0) d.p")
                            .tag($0)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .padding(.horizontal)
        .animation(Animation.customSlowSpring, value: inspectionTime)
        .animation(Animation.customSlowSpring, value: hapticFeedback)
    }
}

