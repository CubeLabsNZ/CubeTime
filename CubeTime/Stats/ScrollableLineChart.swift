//
//  ScrollableLineChart.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//

import SwiftUI

let tempData = getRandomData()

struct ScrollableLineChart: View {
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(tempData, id: \.self) { point in
                    Text("\(point)")
                }
            }
        }
    }
}

struct LineChartPoint {
    private var graphicalValue: Double
    private var rawValue: Double
    
    init(value: Double) {
        self.graphicalValue = value
        self.rawValue = value
    }
    
    var point: Double {
        get {
            return graphicalValue
        }
        
        set {
            self.rawValue = newValue
            self.graphicalValue = rawValue * 0.8
        }
    }
}

func getRandomData() -> [Double] {
    var temp: [Double] = []
    for _ in 0..<50000 {
        temp.append(Double.random(in: 0...2))
    }
    
    return temp
}

struct InnerView: View {
    var dataPoints: [Double]
    var min: Double
    var max: Double
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(0..<10000) { i in
                    Text("\(i)").padding()
                }
//                Canvas(rendersAsynchronously: true) { context, size in
//                    var path = Path()
//                    let points = self.dataPoints
//
//                    for (index, point) in points.enumerated() {
//                        if (path.isEmpty) {
//                            path.move(to: CGPointMake(CGFloat(index*10), point*100))
//                        } else {
//                            path.addLine(to: CGPointMake(CGFloat(index*10), point*100))
//                        }
//                    }
//
//
//                    context.stroke(path,
//                                   with: .color(.green),
//                                   style: StrokeStyle(lineWidth: 2))
//                }
                .frame(width: CGFloat(dataPoints.count * 10))
                .background(
                    GeometryReader { proxy in
                        let _ = print(proxy.size)
                        let offset = proxy.frame(in: .named("scroll")).origin.y
                        Color.clear.preference(key: ScrollViewOffsetKey.self, value: offset)
                    }
                )

            }
            .onPreferenceChange(ScrollViewOffsetKey.self) { value in
                print(value)
            }
        }
        .coordinateSpace(name: "scroll")
    }
}

struct ScrollableLineChart_Previews: PreviewProvider {
    static var previews: some View {
        InnerView(dataPoints: tempData, min: tempData.min()!, max: tempData.max()!)
    }
}

struct ScrollViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
