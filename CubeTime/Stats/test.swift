//
//  test.swift
//  CubeTime
//
//  Created by Tim Xie on 26/12/21.
//

import SwiftUI

struct test: View {
    var testData: [Int] = [1, 2, 4, 5, 3, 2, 1]
    var maxHeight = 5
    
    
    
    var body: some View {
    
        
        GeometryReader { geometry in
            
            var maxThing: CGFloat = geometry.size.height / CGFloat(maxHeight)
            
            ForEach((0..<testData.count), id: \.self) { point in
//                Path { path in
//                    path.move(to: CGPoint(x: geometry.size.width/10 * CGFloat(point), y: geometry.size.height))
//                    path.addLine(to: CGPoint(x: geometry.size.width/10 * CGFloat(point), y: geometry.size.height - maxThing * CGFloat(testData[point])))
//                }
//                .stroke(.blue, lineWidth: 10)
            }
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 100))
            }
            .stroke(.blue, lineWidth: 10)
            
        }
        .padding(.horizontal)
    }
}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
