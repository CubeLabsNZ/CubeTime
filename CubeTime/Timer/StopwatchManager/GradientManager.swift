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

func getGradientColours(gradientSelected: Int) -> [Color] {
    return dynamicGradients[gradientSelected]
}

let dynamicGradients: [[Color]] = [
    [Color(0x0093c1), Color(0x05537a)], // light blue - dark blue
    [Color(0x52c8cd), Color(0x007caa)], // aqua - light blue
    [Color(0xe6e29a), Color(0x3ec4d0)], // pale yellow/white ish - aqua
    [Color(0xffd325), Color(0x94d7be)], // yellow - green
    [Color(0xff9e45), Color(0xffd63c)], // pale orange-yellow
    
    [Color(0xfc7018), Color(0xffc337)], // darker orange - yellow
    [Color(0xfb5b5c), Color(0xff9528)], // pink-orange
    [Color(0xd35082), Color(0xf77d4f)], // magenta-orange
    [Color(0x8548ba), Color(0xd95378)], // purple-pink
    [Color(0x3f248f), Color(0x702f86)], // dark blue-purple
]

let staticGradient: [Color] = [Color(0x3E6BF8), Color(0x9DBCFF)]



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
        print(hour)
        
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
