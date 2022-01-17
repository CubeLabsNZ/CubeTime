//
//  PenButton.swift
//  CubeTime
//
//  Created by macos sucks balls on 1/17/22.
//

import SwiftUI

struct PenButton: View {
    @EnvironmentObject var stopWatchManager: StopWatchManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    let penType: PenTypes
    let penText: String
    let darkModeTint: Color
    let width: CGFloat
    
    
    var body: some View {
        TimerButton(
            handler: {
                stopWatchManager.solveItem.penalty = penType.rawValue
                stopWatchManager.changedPen()
                try! managedObjectContext.save()
            },
            width: width,
            text: penText,
            tintColor: colourScheme == .light ? nil : darkModeTint
        )
    }
}

struct TimerButton: View {
    @Environment(\.colorScheme) var colourScheme
    
    let handler: () -> Void
    let width: CGFloat
    let text: String
    let tintColor: Color?
    
    var body: some View {
        Button(action: handler, label: {
            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .fixedSize()
        })
        .frame(width: width, height: 35)
        .foregroundColor(colourScheme == .light ? .black : nil)
        .background(colourScheme == .light ? Color(uiColor: .systemGray4) : nil)
        .buttonStyle(.bordered)
        .tint(tintColor)
        .controlSize(.regular)
        // I know this is bad please spare me
        .if(width > 35, transform: { view in
            view.clipShape(Capsule())
        })
        .if(width == 35, transform: {view in
            view.clipShape(Circle())
        })
    }
}
