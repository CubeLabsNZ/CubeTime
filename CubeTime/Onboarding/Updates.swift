//
//  Updates.swift
//  CubeTime
//
//  Created by Tim Xie on 31/01/22.
//

import SwiftUI


struct ListPoint: Equatable, Hashable {
    let depth: Int
    let text: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(depth)
        hasher.combine(text)
    }
    
    init(_ depth: Int, _ text: String) {
        self.depth = depth
        self.text = text
    }
    
    static func == (lhs: ListPoint, rhs: ListPoint) -> Bool {
        return lhs.depth == rhs.depth && lhs.text == rhs.text
    }
}

struct ListLine: View {
    let depth: Int
    let text: LocalizedStringKey
    
    init(_ depth: Int = 1, _ text: LocalizedStringKey) {
        self.depth = depth
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("–")
                .recursiveMono(size: 17, weight: .regular)
            
            Text(text)
        }
        .padding(.leading, CGFloat(20 * (depth-1)))
    }
}

let updatesList: [String: (majorAdditions: [ListPoint]?,
                           minorAdditions: [ListPoint]?,
                           bugFixes: [ListPoint]?)] = [
"3.0.0": (
    majorAdditions: [
        ListPoint(1, "export functionality added"),
            ListPoint(2, "Export options to CSV, JSON (csTimer), ODT / Excel"),
        ListPoint(1, "interactive time trend graph added"),
            ListPoint(2, "View time trend in more detail, and hover on points to view solve"),
        ListPoint(1, "new icon!"),
    ],
    minorAdditions: [
        ListPoint(1, "many UI improvements throughout"),
        ListPoint(1, "new rounded WCA icons"),
        ListPoint(1, "added preference for last x solves in summarised time trend view"),
        ListPoint(1, "added ability to select specific phase to view in time list"),
        ListPoint(1, "added ability to search comments in time list"),
        ListPoint(1, "added button to reset settings"),
        ListPoint(1, "added 0s freeze time option"),
    ],
    bugFixes: [
        ListPoint(1, "many crashes fixed"),
        ListPoint(1, "fixed rounding vs truncating of times"),
        ListPoint(1, "fixed incorrect timer display when using 0 d.p"),
        ListPoint(1, "fixed bug where regular solve could be moved to multiphase session")
    ]
),


"2.1.2": (
    majorAdditions: nil,
    minorAdditions: nil,
    bugFixes: [
        ListPoint(1, "fixed timelist column count on iPhone 11 Pro Max"),
    ]
),


"2.1.1": (
    majorAdditions: nil,
    minorAdditions: nil,
    bugFixes: [
        ListPoint(1, "fixed time trend graph bug"),
    ]
),


"2.1": (
    majorAdditions: [
        ListPoint(1, "added settings sync between devices"),
        ListPoint(1, "added ability to two-finger swipe on iPad trackpad to resize floating panel")
    ],
    minorAdditions: [
        ListPoint(1, "made 3-solve display show current average in compsim"),
        ListPoint(1, "added toggle to play voice alert through ringer, following mute toggle"),
        ListPoint(1, "allow audio alerts to play alongside background audio, eg: music"),
        ListPoint(1, "added zen mode on iPhone"),
        
    ],
    bugFixes: [
        ListPoint(1, "fixed various dynamic type bugs"),
        ListPoint(1, "fixed calculator tool bugs"),
        ListPoint(1, "fixed compsim crashing"),
        ListPoint(1, "fixed time distribution crashing"),
        ListPoint(1, "fixed inverted iPad trackpad gesture to show penalty bar"),
        ListPoint(1, "fixed select all only selected shown solves"),
        ListPoint(1, "fixed button text wrapping"),
        ListPoint(1, "fixed stats not updating"),
        ListPoint(1, "fixed text cutting off on smaller devices"),
        ListPoint(1, "fixed long times wrapping in time detail"),
    ]
),
                            
"2.0": (
    majorAdditions: [
    ListPoint(1, "fresh new UI design"),
        ListPoint(2, "TONS of UI fixes throughout the app"),
        ListPoint(2, "improved design consistency"),
    ListPoint(1 , "dynamic type support!"),
        ListPoint(2, "all major UI elements now conform to Apple's DynamicType accessbility font sizes"),
        ListPoint(2, "this is the first version, if you do notice anything out of place, please open an issue and tag it with 'DynamicType' on our Github page."),
    ListPoint(1, "changed tnoodle compatibility layer"),
        ListPoint(2, "**30x faster scramble generation**"),
        ListPoint(2, "**20x less memory usage**"),
            ListPoint(3, "fixes OOM crashes on older phones"),
            ListPoint(3, "fixes launch crash on iPod 7th Gen"),
    ListPoint(1, "improved stats engine"),
        ListPoint(2, "**over 100x faster**"),
    ListPoint(1, "iPad Mode is here!"),
        ListPoint(2, "iPad mode supports many keyboard shortcuts, along with **trackpad gestures**"),
            ListPoint(3, "you can two-finger swipe on your trackpad, just like using a finger"),
        ListPoint(2, "new design with a floating panel"),
        ListPoint(2, "to see your times, drag down on the panel handle"),
    ListPoint(1, "added tools!"),
        ListPoint(2, "scramble generator: batch generate multiple scrambles to use or share"),
        ListPoint(2, "timer and scramble only mode: for use at comps"),
        ListPoint(2, "average calculator: to quickly calculate averages!"),
    ListPoint(1, "added voice alerts for inspection"),
    ListPoint(1, "added manual entry mode"),
        ListPoint(2, "you can switch to entering times by typing instead of a timer in General Settings > Timer Settings > Timer Mode > Typing"),
    ListPoint(1, "quick actions!"),
        ListPoint(2, "long press on icon to quickly go to your recently used sessions"),
    ListPoint(1, "cleaned up to make the app run smoother!"),
        ListPoint(2, "we've written over 20,000 lines of code for this update!")],
    
    minorAdditions: [
    ListPoint(1, "added rotations added for blind scrambles"),
    ListPoint(1, "using WCA-complient random state 4x4 scrambles"),
    ListPoint(1, "new dynamic gradient option that changes the gradient throughout the day"),
    ListPoint(1, "added share sheets to share your times or averages"),
    ListPoint(1, "added copy scramble on timer screen"),
    ListPoint(1, "added lock scramble feature"),
        ListPoint(2, "long press on the scramble text to bring up a menu, where you can lock or unlock the current scramble"),
    ListPoint(1, "move solves between session"),
    ListPoint(1, "using more modern SVG renderer, faster draw scrambles"),
    ListPoint(1, "more solve selection functions:"),
        ListPoint(2, "copy multiple solves"),
        ListPoint(2, "add penalty to multiple solves"),
    ListPoint(1, "show +2 and DNF time in brackets"),
    ListPoint(1, "swapped around delete and copy button in individual solve cards"),
    ListPoint(1, "added ability to delete currently selected session"),
    ListPoint(1, "added multiphase details to solve copy"),
    ListPoint(1, "improved various timing-related functions"),
    ListPoint(1, "added ability to stop inspection"),
    ListPoint(1, "improved user accessibility"),
    ListPoint(1, "added inspection alerts"),
    ListPoint(1, "added voice inspection"),
    ListPoint(1, "added ability to cancel inspection"),
    ListPoint(1, "added ability to switch between voice based or beep based alerts"),
    ListPoint(1, "added ability to toggle session name in timer view"),
    ListPoint(1, "batch select solves to penalty"),
    ListPoint(1, "batch select solves to change sessions"),
    ListPoint(1, "added ability to clear all solves in a session"),
    ListPoint(1, "added many more filter options, such as filtering solves with comments, with penalties, and more"),
    ListPoint(1, "time trend now only displays last 80 solves"),
        ListPoint(2, "an interactive time trend is coming in the next update"),
    ListPoint(1, "added multiphase graph to individual time details"),
    ListPoint(1, "added fully customisable fonts for timer and scramble")],
    bugFixes: [
    ListPoint(1, "fixed stretched scramble image on smaller devices"),
    ListPoint(1, "fixed time distribution graph labels"),
    ListPoint(1, "fixed multiphase stats UI"),
    ListPoint(1, "fixed many UI bugs with context menus and more"),
    ListPoint(1, "fixed stats crashing"),
    ListPoint(1, "fixed stats tools not updating when deleting solve")]
)]



struct Updates: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var showUpdates: Bool
    
    let currentVersion: String = "\((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("CubeTime v3.0.0 is here!")
                        .foregroundStyle(GradientManager.getGradient(gradientSelected: 0, isStaticGradient: true))
                        .recursiveMono(size: 21, weight: .semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                    
                    Group {
                        Update("3.0.0")
                        
                        Text("Thanks for using this app! If you have any feedback (good or bad!), please open an issue on [our github page](https://github.com/CubeStuffs/CubeTime/issues) or [contact me personally](https://tim-xie.com/contact).")
                            .font(.body).fontWeight(.medium)
                            .accentColor(Color("accent"))
                        
                        Text("Older changes")
                            .padding(.top, 64)
                            .font(.title3.weight(.semibold))
                        
                        Update("2.1.2")
                        
                        Update("2.1.1")
                        
                        Update("2.0")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("What's New!")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    CTCloseButton {
                        dismiss()
                        showUpdates = false
                    }
                }
            }
        }
    }
}


struct Update: View {
    var majorAdditions: [ListPoint]?
    var minorAdditions: [ListPoint]?
    var bugFixes: [ListPoint]?
    
    let version: String
    
    init(_ version: String) {
        self.version = version
        
        if let update = updatesList[version] {
            self.majorAdditions = update.majorAdditions
            self.minorAdditions = update.minorAdditions
            self.bugFixes = update.bugFixes
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                Text("v\(version) changes:")
                    .recursiveMono(size: 15, weight: .semibold)
                    .padding(.top)
                
                CTDivider()
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                
                if let majorAdditions = majorAdditions {
                    Text("Major Additions: ")
                        .font(.title3).fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(majorAdditions, id: \.self) { point in
                            ListLine(point.depth, .init(stringLiteral: point.text))
                                .if(point.depth == 1) { body in
                                    body.font(.body.weight(.semibold))
                                }
                        }
                    }
                    .padding(.bottom)
                }
            
                if let minorAdditions = minorAdditions {
                    Text("Minor Additions: ")
                        .font(.title3).fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(minorAdditions, id: \.self) { point in
                            ListLine(point.depth, .init(stringLiteral: point.text))
                        }
                    }
                    .padding(.bottom)
                }
                
                if let bugFixes = bugFixes {
                    Text("Bug Fixes: ")
                        .font(.title3).fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        ForEach(bugFixes, id: \.self) { point in
                            ListLine(point.depth, .init(stringLiteral: point.text))
                        }
                    }
                    .padding(.bottom)
                    .font(.callout)
                }
            }
        }
        .padding(.bottom)
    }
}

#Preview {
    Updates(showUpdates: .constant(true))
}
