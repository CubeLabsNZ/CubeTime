import SwiftUI

enum InputMode: LocalizedStringKey, Codable, CaseIterable, Identifiable {
    case timer = "Timer"
    case typing = "Typing"
    
    var id: InputMode { self }
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
    
    // timer interface & solves
    @Preference(\.showPrevTime) private var showPrevTime
    @Preference(\.promptDelete) private var promptDelete

    // statistics
    @Preference(\.displayDP) private var displayDP
    @Preference(\.timeTrendSolves) private var timeTrendSolves
    
    @State private var showResetDialog = false

    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    var body: some View {
        VStack(spacing: 16) {
            SettingsGroup(Label("Timer Settings", systemImage: "timer")) {
                
                SettingsToggle(String(localized: "Use Inspection"), $inspectionTime)
                
                ConditionalSetting(showIf: inspectionTime) {
                    SettingsToggle(String(localized: "Inspection Counts Down"), $insCountDown)
                    
                    DescribedSetting(description: "Display a cancel inspection button when inspecting.") {
                        SettingsToggle(String(localized: "Show Cancel Inspection"), $showCancelInspection)
                    }
                    
                    DescribedSetting(description: "Play an audible alert when 8 or 12 seconds is reached.") {
                        SettingsToggle(String(localized: "Inspection Alert"), $inspectionAlert)
                    }
                    
                    if inspectionAlert {
                        DescribedSetting(description: "To use the 'Boop' option, your phone must not be muted. 'Boop' plays a system sound, requiring your ringer to be unmuted.") {
                            
                            SettingsPicker(text: String(localized: "Inspection Alert Type"), selection: $inspectionAlertType, maxWidth: 120) {
                                Text("Voice").tag(0)
                                Text("Boop").tag(1)
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        DescribedSetting(description: "With this setting on, the **Voice** alert type will play through system audio, respecting your phone's ringer mute state.") {
                            SettingsToggle(String(localized: "Inspection Alert Follows System Silent Mode"), $inspectionAlertFollowsSilent)
                        }
                        .onChange(of: inspectionAlertFollowsSilent, perform: { _ in
                            setupAudioSession(with: inspectionAlertFollowsSilent ? .ambient : .playback)
                        })
                    }
                }
                
                CTDivider()
                
                SettingsStepper(text: String(localized: "Hold Down Time: "), format: "%.2fs", value: $holdDownTime, in: 0.00...1.0, step: 0.05)
                
                CTDivider()
                
                VStack(spacing: 4) {
                    SettingsPicker(text: String(localized: "Timer Mode"), selection: $inputMode) {
                        ForEach(Array(InputMode.allCases), id: \.self) { mode in
                            Text(mode.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                
                    
                    if inputMode == .timer {
                        SettingsPicker(text: String(localized: "Timer Update"), selection: $timerDP) {
                            Text("None")
                                .tag(-1)
                            ForEach(0...3, id: \.self) {
                                Text("\($0) d.p")
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            }
            
            SettingsGroup(Label("Timer Tools", systemImage: "wrench")) {
                DescribedSetting(description: "Show tools on the timer screen.") {
                    SettingsToggle(String(localized: "Show draw scramble on timer"), $showScramble)
                    if !UIDevice.deviceIsPad {
                        SettingsToggle(String(localized: "Show stats on timer"), $showStats)
                    }
                }
                var desc = String(localized: "Show a button in the top right corner to enter zen mode.")
                if UIDevice.deviceIsPad {
                    let _ = {desc += String(localized: " Note that this is only applicable in compact UI mode (i.e. when the floating panel is not shown).")}()
                }
                DescribedSetting(description: LocalizedStringKey.init(desc)) {
                    SettingsToggle(String(localized: "Show zen mode button"), $showZenMode)
                }
            }
            
            SettingsGroup(Label("Timer Interface & Solves", systemImage: "rectangle.and.pencil.and.ellipsis")) {
                DescribedSetting(description: "Show the previous time after a solve is deleted by swipe gesture. With this option off, the default time of 0.00 or 0.000 will be shown instead.") {
                    SettingsToggle(String(localized: "Show Previous Time"), $showPrevTime)
                }
                
                DescribedSetting(description: "Display a prompt before deleting solves.", {
                    SettingsToggle(String(localized: "Show Solve Deletion Prompt"), $promptDelete)
                })
            }
            
            SettingsGroup(Label("Accessibility", systemImage: "eye")) {
                SettingsToggle(String(localized: "Haptic Feedback"), $hapticFeedback)
                ConditionalSetting(showIf: hapticFeedback) {
                    SettingsPicker(text: String(localized: "Haptic Intensity"), selection: $feedbackType) {
                        ForEach(Array(UIImpactFeedbackGenerator.FeedbackStyle.allCases), id: \.self) { mode in
                            Text(hapticNames[mode]!)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                CTDivider()
                
                SettingsDragger(text: UIDevice.deviceIsPad ? String(localized: "Touch Gesture Activation Distance") : String(localized: "Gesture Activation Distance"), value: $gestureActivationDistance, in: 20...300)
                
                if UIDevice.deviceIsPad {
                    SettingsDragger(text: "Trackpad Gesture Activation Distance", value: $gestureDistanceTrackpad, in: 100...1000)
                }
                
            }
            
            SettingsGroup(Label("Statistics", systemImage: "chart.bar.xaxis")) {
                SettingsPicker(text: String(localized: "Times Displayed To: "), selection: $displayDP) {
                    ForEach(2...3, id: \.self) {
                        Text("\($0) d.p")
                            .tag($0)
                    }
                }
                .pickerStyle(.menu)
                
                SettingsPicker(text: String(localized: "Time Trend Show: "), selection: $timeTrendSolves) {
                    ForEach([25, 50, 80, 100, 200], id: \.self) {
                        Text("\($0) Solves")
                            .tag($0)
                    }
                }
            }
            
            SettingsGroup(Label("Language & Localisation", systemImage: "globe")) {
                HStack {
                    Text("Language")
                        .font(.body.weight(.medium))

                    Spacer()
                    
                    CTButton(type: .halfcoloured(nil), size: .medium, onTapRun: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }) {
                        Text("Open settings")
                    }
                }
            }

            CTButton(type: .halfcoloured(Color("red")), size: .large, expandWidth: true, onTapRun: {
                showResetDialog = true
            }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    
                    Text("Reset General Settings")
                }
            }
            .padding(.top, 12)
        }
        .padding(.horizontal)
        .animation(Animation.customSlowSpring, value: inspectionTime)
        .animation(Animation.customSlowSpring, value: inspectionAlert)
        .animation(Animation.customSlowSpring, value: hapticFeedback)
        .confirmationDialog("Are you sure you want to reset all general settings? Your solves and sessions will be kept.",
                            isPresented: $showResetDialog,
                            titleVisibility: .visible) {
                                    Button("Reset", role: .destructive) {
                                        SettingsManager.standard.resetGeneralSettings()
                                    }
                                }
    }
}

