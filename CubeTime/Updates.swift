//
//  Updates.swift
//  CubeTime
//
//  Created by Tim Xie on 31/01/22.
//

import SwiftUI

struct Updates: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @Binding var showUpdates: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        Text("VERSION: \((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))")
                            .foregroundColor(Color(uiColor: .systemGray))
                            .font(.system(size: 15, weight: .medium))
                            .padding(.bottom)
                            .offset(y: -4)
                        
                        
                        Text("A quick apology: sorry for the lack of updates - we've had a very busy school term! \n")
                            .font(.system(size: 21, weight: .medium))
                        
                        
                        Text("Major Bug fixes: ")
                            .font(.system(size: 17, weight: .medium))
                        
                        Text("""
                                -   fixed multiphase solve crashing when deleting solve in pop-up
                                -   animation bug fixed for stats view (?) (if this happens again, comment on the issue in Github please!)
                            """)
                            .font(.system(size: 15, weight: .medium))
                            .padding(.bottom)
                        
                        
                        
                        Text("New features: ")
                            .font(.system(size: 17, weight: .medium))
                        
                        Text("""
                                -   we've added an iPadOS mode!
                                    -   trackpad gesture support
                                    -   hardware keyboard support
                                    -   split screen support
                                    -   full manual entry mode
                                -   Import/Export from and to CubeTime
                                    -   Import from other timers, such as:
                                        -   csTimer
                                        -   TwistyTimer
                                        -   and more to come...
                            """)
                            .font(.system(size: 15, weight: .regular))
                            .padding(.bottom)
                        
                        Text("Again - thanks for using this app! As this app is still in it's beta stage, you may experience some slight problems, such as crashes for example. In the event that the app does crash - please please please message me on discord (teeem#7263) or open an issue on our github page (https://github.com/CubeStuffs/CubeTime/issues).")
                            .font(.system(size: 17, weight: .medium))
                    }
                    
                    Group {
                        Text("Update list:")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.top)
                            .padding(.bottom, 6)
                        
                        Text("VERSION: 1.2")
                            .foregroundColor(Color(uiColor: .systemGray))
                            .font(.system(size: 15, weight: .medium))
                            .offset(y: -4)
                        
                        Text("""
                                -   we're now using official TNoodle scrambles! This means:
                                    -   no more weird or incorrect scrambles
                                    -   all WCA compliant and random state
                                    -   we've added draw scramble functionality
                                -   we've prevented sleep on the timer screen
                                -   many accessibility oriented changes:
                                    -   added placeholder text in the comment field
                                    -   option to turn off graph glow
                                    -   ability to change scramble size (and tap scramble to view full screen)
                                -   added bpa/wpa, target needed for x calculations for comp sim
                                -   added stats and draw scramble to the timer view
                                -   scrambles are copied when you copy averages
                                -   ability to penalise/delete solves in current comp sim average
                                -   added backwards counting inspection
                                -   lowered minimum hold down time to 0.05s
                                -   added a launch screen!
                            """)
                            .font(.system(size: 15, weight: .regular))
                            .padding(.bottom)
                    }

                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("What's New!")
        }
        .overlay {
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                        showUpdates = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .foregroundStyle(colourScheme == .light ? .black : .white)
                            .padding([.top, .trailing])
                    }
                }
                
                Spacer()
            }
        }
    }
}
