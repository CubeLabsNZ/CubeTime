//
//  MagnifierRect.swift
//  
//
//  Created by Samu András on 2020. 03. 04..
//

import SwiftUI

public struct MagnifierRect: View {
    @Binding var currentNumber: Double
    var valueSpecifier:String
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    public var body: some View {
        ZStack{
            if #available(iOS 15.0, *) {
                Text("\(self.currentNumber, specifier: valueSpecifier)")
                    .font(.system(size: 18, weight: .bold))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    
                    .offset(x: 0, y:-130)
                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
            } else {
                Text("\(self.currentNumber, specifier: valueSpecifier)")
                    .font(.system(size: 18, weight: .bold))
                    .padding(6)
                    .background(Color.white.cornerRadius(16))
                    .offset(x: 0, y:-140)
                    .foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
            }
                
            if (self.colorScheme == .dark ){
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: self.colorScheme == .dark ? 2 : 0)
                    .frame(width: 60, height: 300)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: 60, height: 300)
                    .foregroundColor(Color.white)
                    .shadow(color: Colors.LegendText, radius: 12, x: 0, y: 6 )
                    .blendMode(.multiply)
            }
        }
        .offset(x: 0, y: -15)
    }
}
