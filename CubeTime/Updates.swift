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
                            .font(.subheadline).fontWeight(.medium)
                            .padding(.bottom)
                            .offset(y: -4)
                        
                        
                        Text("A quick apology: sorry for the lack of updates - we're just two high school students and we've had a very busy school term! \n")
                            .font(.title3).fontWeight(.medium)
                        
                        
                        Text("Major Bug fixes: ")
                            .font(.body).fontWeight(.medium)
                        
                        Text("""
                                                -   fixed multiphase solve deletion crash
                                                -   added graph animation toggle
                                                -   made solve pop up and time detail more resilient
                                                -   fixed stats and settings page animation bug (#48)
                                                -   increased penalty button area
                                                -   sort averages by date and not speed
                                                -   fixed lag on TimerView
                                                -   fixed target input crash
                                                -   fixed print spamming
                                                -   fixed various comp sim bugs
                                                  -     fixed current average skipping after solve deletion
                                                  -     fixed comp sim calculation bugs
                                                  -     fixed assertionFailure from saving session > 5 solves
                                                  -     fixed current solve counter not updating
                                                -   greatly improved timer speed and responsiveness


                                            """)
                            .font(.subheadline)
                            .padding(.bottom)
                        
                        
                        
                        Text("New features: ")
                            .font(.body).fontWeight(.medium)
                        
                        Text("""
                                                -   added changable font size in scramble/image popup
                                            """)
                            .font(.subheadline)
                            .padding(.bottom)
                        
                        Text("Again - thanks for using this app! As this app is still in it's beta stage, you may experience some slight bugs and crashes. In the event that the app does crash - please please please message me on discord (teeem#7263) or open an issue on our github page (https://github.com/CubeStuffs/CubeTime/issues).")
                            .font(.body).fontWeight(.medium)
                    }
                    
                    Group {
                        Text("Past Updates:")
                            .font(.title).fontWeight(.bold)
                            .padding(.top)
                            .padding(.bottom, 6)
                        
                        Text("VERSION: 1.2")
                            .foregroundColor(Color(uiColor: .systemGray))
                            .font(.subheadline).fontWeight(.medium)
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
                            .font(.subheadline)
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
