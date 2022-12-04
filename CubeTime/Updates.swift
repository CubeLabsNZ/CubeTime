//
//  Updates.swift
//  CubeTime
//
//  Created by Tim Xie on 31/01/22.
//

import SwiftUI

// [bugFixes, majorAdditions, minorAdditions]
let updatesList: [String: [String?]] = [
    "2.0": [
        nil,
        """
        -   dynamic type support!
            -   all major UI elements now conform to Apple's DyanmicType accessbility font sizes
            -   this is the first version, if you do notice anything out of place, please open an issue and tag it with 'DynamicType' on our Github page. Thanks!
        –   changed java compatibility layer
            –   30x faster scramble generation
            –   20x less memory usage
                –   fixed OOM crashes on older phones
                –   fixed launch crash on iPod 7th Gen
        –   added manual entry mode
            –   you can switch to entering times by typing instead of a timer in General Settings > Timer Settings > Timer Mode > Typing
        -   added rotations added for blind scrambles
        –   using WCA-complient random state 4x4 scrambles
        """,
        """
        –   using more modern SVG renderer, faster draw scrambles
        –   more solve selection functions:
            –   copy multiple solves
        –   show +2 and DNF time in brackets
        –   swapped around delete and copy button in individual solve cards
        –   added ability to delete currently selected session
        -   added multiphase details to solve copy
        -   improved various timing-related functions
        -   added ability to stop inspection
        -   fixed stretched scramble image on smaller devices
        -   fixed time distribution graph labels
        -   fixed multiphase stats UI
        -   improved user accessibility
        –   added inspection alerts
        –   added ability to switch between voice based or beep based alerts
        –   added ability to toggle session name in timer view
        -   various interface changes throughout
        """
    ],
    "1.2.1": [
        """
        -   fixed multiphase solve deletion crash
        -   added graph animation toggle
        -   made solve pop up and time detail more resilient
        -   fixed stats and settings page animation bug
        -   increased penalty button area
        -   sort averages by date and not speed
        -   fixed lag on TimerView
        -   fixed target input crash
        -   fixed print spamming
        -   fixed various comp sim bugs
            -   fixed current average skipping after solve deletion
            -   fixed comp sim calculation bugs
            -   fixed assertionFailure from saving session > 5 solves
            -   fixed current solve counter not updating
        -   greatly improved timer speed and responsiveness
        """,
        nil,
        """
        -   added changable font size in scramble/image popup
        """
    ],
    "1.2": [
        nil,
        """
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
        """,
        nil,
    ],

]



struct Updates: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @Binding var showUpdates: Bool
    
    let currentVersion: String = "\((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        
//                        Text("A quick apology: sorry for the lack of updates - we're just two high school students and we've had a very busy school term! \n")
//                            .font(.title3).fontWeight(.medium)
                        
                        Update(currentVersion)
                        
                        Text("Again, thanks for using this app! As this app is still in it's beta stage, you may experience some slight bugs and crashes. In the event that the app does crash – please please please message me on discord (tim#0911) or open an issue on our github page (https://github.com/CubeStuffs/CubeTime/issues).")
                            .font(.body).fontWeight(.medium)
                    }
                    
                    Group {
                        Text("Past Updates:")
                            .font(.title).fontWeight(.bold)
                            .padding(.top)
                            .padding(.bottom, 6)
                        
                        Update("1.2.1")
                        
                        Update("1.2")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("What's New!")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                        showUpdates = false
                    } label: {
                        CloseButton()
                    }
                }
            }
        }
    }
}


struct Update: View {
    var version: String
    var bugFixes: String?
    var majorAdditions: String?
    var minorAdditions: String?
    
    init(_ version: String) {
        self.version = version
        if let updateText = updatesList[version] {
            self.bugFixes = updateText[0]
            self.majorAdditions = updateText[1]
            self.minorAdditions = updateText[2]
        } else {
            self.bugFixes = nil
            self.majorAdditions = nil
            self.minorAdditions = nil
        }
    }
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("v\(version)")
                .foregroundColor(Color(uiColor: .systemGray))
                .font(.subheadline).fontWeight(.medium)
            
            if let bugFixes = bugFixes {
                Text("Bug Fixes: ")
                    .font(.body).fontWeight(.medium)
                
                Text(bugFixes)
                    .font(.subheadline)
                    .padding(.bottom)
            }
            
        
            
            if let majorAdditions = majorAdditions {
                Text("Major Additions: ")
                    .font(.body).fontWeight(.medium)
                
                Text(majorAdditions)
                    .font(.subheadline)
                    .padding(.bottom)
            }
        
            if let minorAdditions = minorAdditions {
                Text("Minor Additions: ")
                    .font(.body).fontWeight(.medium)
                
                Text(minorAdditions)
                    .font(.subheadline)
                    .padding(.bottom)
            }
        }
        .padding(.bottom)
    }
}
