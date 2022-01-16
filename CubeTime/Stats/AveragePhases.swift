//
//  AveragePhases.swift
//  CubeTime
//
//  Created by Tim Xie on 14/01/22.
//

import SwiftUI

let phaseColours: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo]

struct AveragePhases: View {
    var timesBySpeedNoDNFs: [Double]
    var phaseTimes: [Double]
    
    init(_ times: [Double], _ phaseTimes: [Double]) {
        self.timesBySpeedNoDNFs = times
        self.phaseTimes = phaseTimes
    }

    var body: some View {
        if timesBySpeedNoDNFs.count >= 1 {
            VStack (spacing: 0) {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        ForEach(Array(zip(phaseTimes.indices, phaseTimes)), id: \.0) { index, phase in
                            Rectangle()
                                .fill(phaseColours[index])
                                .frame(width: geometry.size.width * (phase / phaseTimes.reduce(0, +)), height: 10)
                                .cornerRadius(index == 0 ? 10 : 0, corners: [.topLeft, .bottomLeft])
                                .cornerRadius(index == phaseTimes.count-1 ? 10 : 0, corners: [.topRight, .bottomRight])
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    ForEach(Array(zip(phaseTimes.indices, phaseTimes)), id: \.0) { index, phase in
                        HStack (spacing: 16) {
                            Circle()
                                .fill(phaseColours[index])
                                .frame(width: 10, height: 10)
                            
                            HStack (spacing: 8) {
                                Text("Phase \(index+1):")
                                    .font(.system(size: 17, weight: .medium))
                                
                                Text(formatSolveTime(secs: phase))
                                    .font(.system(size: 17))
                                
                                
                                Text("("+String(format: "%.1f", (phase / phaseTimes.reduce(0, +))*100)+"%)")
                                    .foregroundColor(Color(uiColor: .systemGray))
                                    .font(.system(size: 17))
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        } else {
            Text("not enough solves to\ndisplay graph")
                .font(.system(size: 17, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(uiColor: .systemGray))
        }
    }
}
