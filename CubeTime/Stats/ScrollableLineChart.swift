//
//  ScrollableLineChart.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//

import SwiftUI

let tempData = getRandomData()

struct LineChartPoint {
    var graphicalValue: Double  // y-pos
    var rawValue: Double
    
    init(value: Double, max: Double, min: Double, boundsHeight: CGFloat) {
        self.rawValue = value
        self.graphicalValue = ((value - min) / (max - min)) * boundsHeight
    }
}

func getRandomData() -> [Double] {
    var temp: [Double] = []
    for _ in 0..<10000 {
        temp.append(Double.random(in: 0...2))
    }
    
    return temp
}

func makeData(_ data: [Double], _ boundsHeight: CGFloat=UIScreen.screenHeight*0.618) -> [LineChartPoint] {
    let max: Double = data.max()!
    let min: Double = data.min()!
    return data.map({ LineChartPoint(value: $0, max: max, min: min, boundsHeight: boundsHeight) })
}

struct InnerView: View {
    let points: [LineChartPoint]
    let gapDelta: Int
    
    init(rawDataPoints: [Double], gapDelta: Int = 30) {
        self.points = makeData(tempData)
        self.gapDelta = gapDelta
    }
    
    init(premadePoints: [LineChartPoint], gapDelta: Int = 30) {
        self.points = premadePoints
        self.gapDelta = gapDelta
    }
    
    
    var body: some View {
        ScrollView(.horizontal) {
            Canvas { context, size in
                var path = Path()
//                print("make data started")
//                print("made data")
//
//                let maxX = context.clipBoundingRect.maxX
//                let minX = context.clipBoundingRect.minX
//
//                print("difference: \(maxX - minX), uiscreenwidth: \(UIScreen.screenWidth)")

                for (i,p) in points.enumerated() {
                    if (path.isEmpty) {
                        path.move(to: CGPointMake(CGFloat(i*gapDelta), p.graphicalValue))
                    } else {
                        path.addLine(to: CGPointMake(CGFloat(i*gapDelta), p.graphicalValue))
                    }
                }


                context.stroke(path,
                               with: .color(.green),
                               style: StrokeStyle(lineWidth: 2))
            }
            .frame(width: CGFloat(points.count * 10))
        }
    }
}
