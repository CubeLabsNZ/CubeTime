//
//  PenButton.swift
//  CubeTime
//
//  Created by macos sucks balls on 1/17/22.
//

import SwiftUI

struct PenaltyButton: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.colorScheme) private var colourScheme
    
    let penType: PenTypes
    let penSymbol: String
    let imageSymbol: Bool
    let canType: Bool
    let colour: Color
    
    var body: some View {
        Button(action: {
            let oldPen = stopwatchManager.solveItem.penalty
            stopwatchManager.solveItem.penalty = penType.rawValue
            stopwatchManager.changedPen(PenTypes(rawValue: oldPen)!)
            try! managedObjectContext.save()
            
        }, label: {
            if imageSymbol {
                Image(penSymbol)
                    .frame(width: 21, height: 21)
                    .contentShape(Rectangle())
            } else {
                Image(systemName: penSymbol)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(colour)
            }
        })
        .padding(2)
        .disabled(canType)
    }
}


struct PenaltyBar<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    let buttons: Content
    
    init(@ViewBuilder buttons: () -> Content) {
        self.buttons = buttons()
    }
    
    var body: some View {
        buttons
            .frame(height: 35)
            .background(Color("overlay1"))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .fixedSize()
    }
}
