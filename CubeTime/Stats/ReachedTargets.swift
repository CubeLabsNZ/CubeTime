//
//  ReachedTargets.swift
//  CubeTime
//
//  Created by Tim Xie on 4/01/22.
//

import SwiftUI

struct ReachedTargets: View {
    @ScaledMetric var offset = 30
    
    let reachedCount: Int
    let totalCount: Int

    var body: some View {
        GeometryReader { geometry in
            if (totalCount > 0) {
                ZStack (alignment: .leading) {
                    Capsule()
                        .fill(Color("red"))
                        .frame(width: geometry.size.width, height: 6)
                    
                    
                    Rectangle()
                        .fill(Color("green"))
                        .frame(width: geometry.size.width * (CGFloat(reachedCount) / CGFloat(totalCount)), height: 6)
                        .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                        .cornerRadius((Float(reachedCount) / Float(totalCount)) == 1 ? 10 : 0, corners: [.topRight, .bottomRight])
                }
            } else {
                Capsule()
                    .fill(Color("indent1"))
                    .frame(width: geometry.size.width, height: 6)
            }
        }
        .offset(y: offset)
    }
}
