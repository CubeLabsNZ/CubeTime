//
//  ReachedTargets.swift
//  CubeTime
//
//  Created by Tim Xie on 4/01/22.
//

import SwiftUI

struct ReachedTargets: View {
    
    var reachedPercentage: Float
    
    init(_ amount: Float) {
        reachedPercentage = amount
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack (alignment: .leading) {
                Capsule()
                    .fill(.red)
                    .frame(width: geometry.size.width, height: 6)
                
                
                Rectangle()
                    .fill(.green)
                    .frame(width: geometry.size.width * CGFloat(reachedPercentage), height: 6)
                    .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                    .cornerRadius(reachedPercentage == 1 ? 10 : 0, corners: [.topRight, .bottomRight])
            }
        }
    }
}
