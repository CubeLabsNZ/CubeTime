//
//  PenButton.swift
//  CubeTime
//
//  Created by macos sucks balls on 1/17/22.
//

import SwiftUI

struct PenaltyButton: View {
    @EnvironmentObject var stopWatchManager: StopWatchManager
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    
    let penType: PenTypes
    let penSymbol: String
    let imageSymbol: Bool
    let canType: Bool
    let colour: Color
    
    init(penType: PenTypes, penSymbol: String, imageSymbol: Bool, canType: Bool, colour: Color) {
        self.penType = penType
        self.penSymbol = penSymbol
        self.imageSymbol = imageSymbol
        self.canType = canType
        self.colour = colour
    }
    
    var body: some View {
        Button(action: {
            stopWatchManager.solveItem.penalty = penType.rawValue
            stopWatchManager.changedPen()
            try! managedObjectContext.save()
        }, label: {
            if imageSymbol {
                Image(penSymbol)
                    .frame(width: 24, height: 71/3)
            } else {
                Image(systemName: penSymbol)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(colour)
            }
        })
        .disabled(canType)
    }
}


struct PenaltyBar<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    let buttons: Content
    let width: CGFloat
    
    init(_ width: CGFloat, @ViewBuilder buttons: () -> Content) {
        self.buttons = buttons()
        self.width = width
    }
    
    var body: some View {
        buttons
            .padding(2)
            .frame(width: width, height: 35)
            .background(Color(uiColor: colourScheme == .light ? .systemGray5 : .systemGray4))
            .clipShape(Capsule())
    }
}
