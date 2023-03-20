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
                .recursiveMono(fontSize: 17, weight: .regular)
            
            Text(text)
        }
        .padding(.leading, CGFloat(20 * (depth-1)))
    }
}

let updatesList: [String: (majorAdditions: [ListPoint]?,
                           minorAdditions: [ListPoint]?,
                           bugFixes: [ListPoint]?)] = [
                            "2.1": (
                                majorAdditions: [
                                    ListPoint(1, "added settings sync between devices")
                                ],
                                minorAdditions: [
                                    ListPoint(1, "added ability to two-finger swipe on iPad trackpad to resize floating panel"),
                                    ListPoint(1, "made 3-solve display display current average in compsim"),
                                    ListPoint(1, "added toggle to play voice alert through ringer, following mute toggle"),
                                    ListPoint(1, "allow audio alerts to play alongside background audio, eg: music"),
                                    
                                ],
                                bugFixes: [
                                    ListPoint(1, "fix various dynamic type bugs"),
                                    ListPoint(1, "fixed calculator tool bugs"),
                                    ListPoint(1, "fixed comp sim crashing"),
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
        ListPoint(1, "**Fresh new UI design**"),
            ListPoint(2, "TONS of UI fixes throughout the app"),
            ListPoint(2, "improved design consistency"),
        ListPoint(1 , "**Dynamic type support!**"),
            ListPoint(2, "all major UI elements now conform to Apple's DynamicType accessbility font sizes"),
            ListPoint(2, "this is the first version, if you do notice anything out of place, please open an issue and tag it with 'DynamicType' on our Github page."),
        ListPoint(1, "**Changed tnoodle compatibility layer**"),
            ListPoint(2, "**30x faster scramble generation**"),
            ListPoint(2, "**20x less memory usage**"),
                ListPoint(3, "fixes OOM crashes on older phones"),
                ListPoint(3, "fixes launch crash on iPod 7th Gen"),
        ListPoint(1, "**Improved stats engine**"),
            ListPoint(2, "over 100x faster speeds"),
        ListPoint(1, "**iPad Mode is here!**"),
            ListPoint(2, "iPad mode supports many keyboard shortcuts, along with **trackpad gestures**"),
                ListPoint(3, "you can two-finger swipe on your trackpad, just like using a finger"),
            ListPoint(2, "new design with a floating panel"),
            ListPoint(2, "to see your times, drag down on the panel handle"),
        ListPoint(1, "**Added tools!**"),
            ListPoint(2, "scramble generator: batch generate multiple scrambles to use or share"),
            ListPoint(2, "timer and scramble only mode: for use at comps"),
            ListPoint(2, "average calculator: to quickly calculate averages!"),
        ListPoint(1, "**Added voice alerts for inspection**"),
        ListPoint(1, "Added manual entry mode"),
            ListPoint(2, "you can switch to entering times by typing instead of a timer in General Settings > Timer Settings > Timer Mode > Typing"),
        ListPoint(1, "Quick actions!"),
            ListPoint(2, "long press on icon to quickly go to your recently used sessions"),
        ListPoint(1, "Cleaned up to make the app run smoother!"),
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
    )
]



struct Updates: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var showUpdates: Bool
    
    let currentVersion: String = "\((Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String))"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        Update(update: updatesList["2.0"]!)
                        
                        Text("Thanks for using this app! If anything goes wrong, please message me on discord (tim#0911) or open an issue on our github page (https://github.com/CubeStuffs/CubeTime/issues).")
                            .font(.body).fontWeight(.medium)
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
    
    init(update: (majorAdditions: [ListPoint]?,
          minorAdditions: [ListPoint]?,
          bugFixes: [ListPoint]?)) {
        self.majorAdditions = update.majorAdditions
        self.minorAdditions = update.minorAdditions
        self.bugFixes = update.bugFixes
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("v2.0 is here!")
                .foregroundStyle(getGradient(gradientSelected: 0, isStaticGradient: true))
                .recursiveMono(fontSize: 21, weight: .semibold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
            
            
            Group {
                Text("v2.1 changes:")
                    .foregroundStyle(getGradient(gradientSelected: 0, isStaticGradient: true))
                    .recursiveMono(fontSize: 15, weight: .semibold)

                
                Text("Major Additions: ")
                    .font(.title3).fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(updatesList["2.1"]!.majorAdditions!, id: \.self) { point in
                        ListLine(point.depth, .init(stringLiteral: point.text))
                    }
                }
                .padding(.bottom)
            
                Text("Minor Additions: ")
                    .font(.title3).fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(updatesList["2.1"]!.minorAdditions!, id: \.self) { point in
                        ListLine(point.depth, .init(stringLiteral: point.text))
                    }
                }
                .padding(.bottom)
                
                Text("Bug Fixes: ")
                    .font(.title3).fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(updatesList["2.1"]!.bugFixes!, id: \.self) { point in
                        ListLine(point.depth, .init(stringLiteral: point.text))
                    }
                }
                .padding(.bottom)
                .font(.callout)
            }
            
            
            
            Text("v2.0 changes:")
                .foregroundStyle(getGradient(gradientSelected: 0, isStaticGradient: true))
                .recursiveMono(fontSize: 15, weight: .semibold)
            
            if let majorAdditions = majorAdditions {
                Text("Major Additions: ")
                    .font(.title3).fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(majorAdditions, id: \.self) { point in
                        ListLine(point.depth, .init(stringLiteral: point.text))
                    }
                }
                .padding(.bottom)
            }
                
            if let minorAdditions = minorAdditions {
                Text("Minor Additions: ")
                    .font(.title3).fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(minorAdditions, id: \.self) { point in
                        ListLine(point.depth, .init(stringLiteral: point.text))
                    }
                }
                .padding(.bottom)
            }
                
            if let bugFixes = bugFixes {
                Text("Bug Fixes: ")
                    .font(.title3).fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(bugFixes, id: \.self) { point in
                        ListLine(point.depth, .init(stringLiteral: point.text))
                    }
                }
                .padding(.bottom)
                .font(.callout)
            }
        }
        .padding(.bottom)
    }
}
