//
//  GeneralSettings.swift
//  txmer
//
//  Created by Tim Xie on 6/12/21.
//

import SwiftUI

struct GeneralSettingsView: View {
    
    @State var inspectionTime: Bool = true
    @State var holdDownTime: Float = 0.5
    @State var timerIntervalMode: Int = 0
    
    // im thinking of using these interval modes: seconds, 0.1s, 0.001, your refresh rate
    
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
                                ForEach(["seconds", "0.1s", "0.01s", "refresh rate"], id: \.self) { mode in
                                Text(mode)

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
            .modifier(settingsBlocks())
            
            
        }
        .padding(.horizontal)
    }
}
