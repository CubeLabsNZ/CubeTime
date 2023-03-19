//
//  GradientManager.swift
//  CubeTime
//
//  Created by Tim Xie on 8/03/23.
//

import Foundation
import Combine
import SwiftUI

func getGradient(gradientSelected: Int, isStaticGradient: Bool) -> LinearGradient {
    return isStaticGradient
    ? LinearGradient(gradient: Gradient(colors: staticGradient),
                     startPoint: .topLeading,
                     endPoint: .bottomTrailing)
    
    : LinearGradient(gradient: Gradient(colors: dynamicGradients[gradientSelected]),
                     startPoint: .topLeading,
                     endPoint: .bottomTrailing)
}

func getGradientColours(gradientSelected: Int, isStaticGradient: Bool) -> [Color] {
    return isStaticGradient ? staticGradient : dynamicGradients[gradientSelected]
}

let dynamicGradients: [[Color]] = [
    [Color(hex: 0x05537a), Color(hex: 0x0093c1)], // light blue - dark blue
    [Color(hex: 0x007caa), Color(hex: 0x52c8cd)], // aqua - light blue
    [Color(hex: 0x3ec4d0), Color(hex: 0xe6e29a)], // pale yellow/white ish - aqua
    [Color(hex: 0x94d7be), Color(hex: 0xffd325)], // yellow - green
    [Color(hex: 0xffd63c), Color(hex: 0xff9e45)], // pale orange-yellow
    
    [Color(hex: 0xffc337), Color(hex: 0xfc7018)], // darker orange - yellow
    [Color(hex: 0xff9528), Color(hex: 0xfb5b5c)], // pink-orange
    [Color(hex: 0xf77d4f), Color(hex: 0xd35082)], // magenta-orange
    [Color(hex: 0xd95378), Color(hex: 0x8548ba)], // purple-pink
    [Color(hex: 0x702f86), Color(hex: 0x3f248f)], // dark blue-purple
]

let staticGradient: [Color] = [Color(hex: 0x91B0FF), Color(hex: 0x365DEB)]



class GradientManager: ObservableObject {
    @Published var appGradient: Int!
    
    var timer = Timer.publish(every: 3600, on: .current, in: .common).autoconnect()
    var subscriber: AnyCancellable?
    
    init() {
        changeGradient(newTime: getSecondsUpTillNow(from: Date()))
        
        self.subscriber = timer
            .sink(receiveValue: { [self] newTime in
                let seconds = getSecondsUpTillNow(from: newTime)
                changeGradient(newTime: seconds)
        })
    }
    
    private func getSecondsUpTillNow(from date: Date) -> Double {
        return date.timeIntervalSince(Calendar.current.startOfDay(for: Date()))
    }
    
    private func changeGradient(newTime: Double) {
        let hour: Int = Int(newTime / 3600)
        
        if (2..<6 ~= hour) {
            self.appGradient = 0
        } else if (6..<8 ~= hour) {
            self.appGradient = 1
        } else if (8..<9 ~= hour) {
            self.appGradient = 2
        } else if (9..<10 ~= hour) {
            self.appGradient = 3
        } else if (10..<12 ~= hour) {
            self.appGradient = 4
        } else if (12..<14 ~= hour) {
            self.appGradient = 5
        } else if (14..<16 ~= hour) {
            self.appGradient = 6
        } else if (16..<19 ~= hour) {
            self.appGradient = 7
        } else if (19..<21 ~= hour) {
            self.appGradient = 8
        } else { // hour < 2 || hour >= 21
            self.appGradient = 9
        }
    }
}
