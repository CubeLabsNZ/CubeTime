//
//  AveragePhases.swift
//  CubeTime
//
//  Created by Tim Xie on 14/01/22.
//

import SwiftUI

struct AveragePhases: View {
    var timesBySpeedNoDNFs: [Double]
    
    init(_ times: [Double]) {
        self.timesBySpeedNoDNFs = times
    }

    var body: some View {
        VStack {
            if timesBySpeedNoDNFs.count >= 1 {
                VStack (spacing: 8) {
                    Capsule()
                        .frame(height: 10)
                    
                    ForEach(0...4, id: \.self) { phase in
                        HStack (spacing: 16) {
                            Circle()
                                .frame(width: 10, height: 10)
                            
                            HStack (spacing: 8) {
                                Text("Phase \(phase):")
                                    .font(.system(size: 17, weight: .medium))
                                
                                Text("1.50")
                                    .font(.system(size: 17))
                                
                                Text("(25%)")
                                    .foregroundColor(Color(uiColor: .systemGray))
                                    .font(.system(size: 17))
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            Spacer()
        }
        .padding(12)
        
        if timesBySpeedNoDNFs.count == 0 {
            Text("not enough solves to\ndisplay graph")
                .font(.system(size: 17, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundColor(Color(uiColor: .systemGray))
        }
    }
}
