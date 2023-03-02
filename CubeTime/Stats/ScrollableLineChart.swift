//
//  ScrollableLineChart.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//

import SwiftUI

struct LineChartPoint {
    var point: CGPoint
    var rawValue: Double
    
    init(value: Double, position: Double, min: Double, max: Double, boundsHeight: CGFloat) {
        self.rawValue = value
        self.point = CGPoint()
        self.point.y = getStandardisedYLocation(value: value, min: min, max: max, boundsHeight: boundsHeight)
        self.point.x = position
    }
}

func getStandardisedYLocation(value: Double, min: Double, max: Double, boundsHeight: CGFloat) -> CGFloat {
    return ((value - min) / (max - min)) * boundsHeight
}

func getRandomData() -> [Double] {
    var temp: [Double] = []
    for _ in 0..<10000 {
        temp.append(Double.random(in: 0...2))
    }
    
    return temp
}

func makeData(_ data: [Double], _ limits: (min: Double, max: Double), _ boundsHeight: CGFloat=UIScreen.screenHeight*0.618) -> [LineChartPoint] {
    return data.enumerated().map({ (i, e) in
        return LineChartPoint(value: e, position: Double(i*30), min: limits.min, max: limits.max, boundsHeight: boundsHeight)
    })
}

struct InnerView: View {
    let points: [LineChartPoint]
    let gapDelta: Int
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    init(rawDataPoints: [Double], limits: (min: Double, max: Double), averageValue: Double, gapDelta: Int = 30) {
        self.points = makeData(rawDataPoints, limits)
        self.averageValue = averageValue
        self.limits = limits
        self.gapDelta = gapDelta
    }
    
    init(premadePoints: [LineChartPoint], limits: (min: Double, max: Double), averageValue: Double, gapDelta: Int = 30) {
        self.points = premadePoints
        self.averageValue = averageValue
        self.limits = limits
        self.gapDelta = gapDelta
    }
    
    private let dotSize: CGFloat = 6
    
    
    var body: some View {
        ScrollView(.horizontal) {
            Canvas { context, size in
                var averageLine = Path()
                
                let height = getStandardisedYLocation(value: averageValue,
                                                      min: limits.min,
                                                      max: limits.max,
                                                      boundsHeight: UIScreen.screenHeight*0.618)
                
                averageLine.move(to: CGPoint(x: dotSize,
                                             y: height))
                averageLine.addLine(to: CGPoint(x: CGFloat(points.count * 30),
                                                y: height))
                
                var path = Path()
                //                print("make data started")
                //                print("made data")
                //
                //                let maxX = context.clipBoundingRect.maxX
                //                let minX = context.clipBoundingRect.minX
                //
                //                print("difference: \(maxX - minX), uiscreenwidth: \(UIScreen.screenWidth)")
                
                for p in points {
                    let circlePoint: CGRect!
                    
                    if (path.isEmpty) {
                        circlePoint = CGRect(x: p.point.x,
                                             y: p.point.y - dotSize/2,
                                             width: dotSize,
                                             height: dotSize)
                        
                        path.move(to: CGPointMake(p.point.x + dotSize/2, p.point.y))
                    } else {
                        circlePoint = CGRect(x: p.point.x - dotSize/2,
                                             y: p.point.y - dotSize/2,
                                             width: dotSize,
                                             height: dotSize)
                        
                        path.addLine(to: p.point)
                    }
                    
                    context.fill(Circle().path(in: circlePoint), with: .color(.red))
                }
                
                context.stroke(path,
                               with: .color(.green),
                               style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                context.stroke(averageLine, with: .color(.gray), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
            .frame(width: CGFloat(points.count * 30))
        }
    }
}
