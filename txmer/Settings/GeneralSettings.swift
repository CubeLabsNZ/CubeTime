//
//  GeneralSettings.swift
//  txmer
//
//  Created by Tim Xie on 6/12/21.
//

import SwiftUI
import SwiftUICharts

/*
enum FeedbackStyles: UIImpactFeedbackGenerator.FeedbackStyle, CaseIterable {
    init?(rawValue: UIImpactFeedbackGenerator.FeedbackStyle.RawValue) {
        <#code#>
    }
    
    var rawValue: UIImpactFeedbackGenerator.FeedbackStyle.RawValue
    
    typealias RawValue = UIImpactFeedbackGenerator.FeedbackStyle.RawValue
    
    case rigid = UIImpactFeedbackGenerator.FeedbackStyle.rigid
    case heavy = 1
    case medium = 2
    case light = 3
}
 */

struct GeneralSettingsView: View {
    
    @AppStorage("inspection") var inspectionTime: Bool = true
    @AppStorage("freeze") var holdDownTime: Double = 0.5
    @AppStorage("interval") var timerIntervalMode: String = "0.01s"
    @AppStorage("hapBool") var hapticFeedback: Bool = true
//    @AppStorage("hapType") var feedbackType: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
    @AppStorage("hapticType") var feedbackType: Int = 0
    @AppStorage("gestureD") var gestureActivationDistance: Double = 200
    @AppStorage("dT") var displayTruncation: String = "2 d.p"
    
    let intervalModes: [String] = ["0.01s", "0.1s", "seconds"]
//    let hapticIntensityModes: [String] = ["rigid", "heavy", "medium", "light", "soft"]
    
    let hapticModes2: [String: UIImpactFeedbackGenerator.FeedbackStyle] = ["rigid": .rigid, "heavy": .heavy, "medium": .medium, "light": .light]
    
    let hapticModes: [UIImpactFeedbackGenerator.FeedbackStyle] = [.rigid, .heavy, .medium, .light]
    
    let displayModes: [String] = ["2 d.p", "3 d.p"]
    
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
                        .foregroundColor(Color("AccentColor"))
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
                        .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    
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
                        Text("Timer Update Interval")
                            .font(.system(size: 17, weight: .medium))
                        Spacer()
                        Picker("", selection: $timerIntervalMode) {
                            ForEach(intervalModes, id: \.self) {
                                Text($0)
                                
                                //.foregroundColor(Color(uiColor: .systemGray4))
                            }
                        }
                        .pickerStyle(.menu)
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
                        .foregroundColor(Color("AccentColor"))
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
                        .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    
                }
                .padding(.horizontal)
                
                if hapticFeedback {
                    HStack {
                        Text("Haptic Mode")
                            .font(.system(size: 17, weight: .medium))
                        
                        Spacer()
                        
                        /*
                        Picker("", selection: $hapticIntensity) {
                            ForEach(0...5) { mode in
                                Text(mode.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.system(size: 17, weight: .regular))
                         */
                        
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
                        
                        Slider(value: $gestureActivationDistance, in: 100...500)
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
                        .foregroundColor(Color("AccentColor"))
                    Text("Statistics")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    
                    Spacer()
                }
                .padding([.horizontal, .top], 10)
                
                HStack {
                    Text("Times Displayed To: ")
                        .font(.system(size: 17, weight: .medium))
                    
                    Spacer()
                    
                    Picker("", selection: $displayTruncation) {
                        ForEach(displayModes, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.system(size: 17, weight: .regular))
                    
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
