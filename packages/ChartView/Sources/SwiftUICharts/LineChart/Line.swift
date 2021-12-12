//
//  Line.swift
//  LineChart
//
//  Created by András Samu on 2019. 08. 30..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI


extension Color {
    init(_ hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
}

func hi(gradientArray: [[Color]]) -> LinearGradient {
    return LinearGradient(gradient: Gradient(colors: gradientArray[5]), startPoint: .bottomTrailing, endPoint: .topLeading)
}

class hi2 {
    static let hi3: [[Color]] = [
        [Color(0x0093c1), Color(0x05537a)], // light blue - dark blue
        [Color(0x52c8cd), Color(0x007caa)], // aqua - light blue
        [Color(0xe6e29a), Color(0x3ec4d0)], // pale yellow/white ish - aqua
        [Color(0xffd325), Color(0x94d7be)], // yellow - green
        [Color(0xff9e45), Color(0xffd63c)], // pale orange-yellow
        
        [Color(0xfc7018), Color(0xffc337)], // darker orange - yellow
        [Color(0xfb5b5c), Color(0xff9528)], // pink-orange
        [Color(0xd35082), Color(0xf77d4f)], // magenta-orange
        [Color(0x8548ba), Color(0xd95378)], // purple-pink
        [Color(0x3f248f), Color(0x702f86)] // dark blue-purple
    ]
}



public struct Line: View {
    @ObservedObject var data: ChartData
    @Binding var frame: CGRect
    @Binding var touchLocation: CGPoint
    @Binding var showIndicator: Bool
    @Binding var minDataValue: Double?
    @Binding var maxDataValue: Double?
    @State private var showFull: Bool = false
    @State var showBackground: Bool = true
    var gradient: GradientColor = GradientColor(start: Colors.GradientPurple, end: Colors.GradientNeonBlue)
    var index:Int = 0
    let padding:CGFloat = 30
    var curvedLines: Bool = true
    var stepWidth: CGFloat {
        if data.points.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.points.count-1)
    }
    var stepHeight: CGFloat {
        var min: Double?
        var max: Double?
        let points = self.data.onlyPoints()
        if minDataValue != nil && maxDataValue != nil {
            min = minDataValue!
            max = maxDataValue!
        }else if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        }else {
            return 0
        }
        if let min = min, let max = max, min != max {
            if (min <= 0){
                return (frame.size.height-padding) / CGFloat(max - min)
            }else{
                return (frame.size.height-padding) / CGFloat(max - min)
            }
        }
        return 0
    }
    var path: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadCurvedPathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue) : Path.linePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    var closedPath: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadClosedCurvedPathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue) : Path.closedLinePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    
    public var body: some View {
        ZStack {
            if(self.showFull && self.showBackground){
                
                
                self.closedPath
                    .fill(LinearGradient(gradient: Gradient(colors: [Colors.GradientUpperBlue, .white]), startPoint: .bottom, endPoint: .top))
                //                    .shadow(color: .green, radius: 12, x: 0, y: 3)
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .transition(.opacity)
                    .animation(.easeIn(duration: 1.6))
            }
            
            
                
            self.path
                .trim(from: 0, to: self.showFull ? 1:0)
                .stroke(LinearGradient(gradient: gradient.getGradient(), startPoint: .leading, endPoint: .trailing) ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
//                .colouredGlow()
            
            //                .shadow(color: .green, radius: 12, x: 0, y: 6)
            //                .colouredGlow()
            
            
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
//                .animation(Animation.easeInOut(duration: 1.2).delay(Double(self.index)*0.4))
                .animation(.easeInOut(duration: 1.2))
                
                .onAppear {
                    self.showFull = true
                }
                .onDisappear {
                    self.showFull = false
                }
                
            
            
            
            if(self.showIndicator) {
                IndicatorPoint()
                    .position(self.getClosestPointOnPath(touchLocation: self.touchLocation))
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
        }
    }
    
    func getClosestPointOnPath(touchLocation: CGPoint) -> CGPoint {
        let closest = self.path.point(to: touchLocation.x)
        return closest
    }
    
}

extension View {
    func colouredGlow() -> some View {
        ForEach(0..<2) { i in
            Rectangle()
                .fill(hi(gradientArray: hi2.hi3))
                //.frame(width: 400, height: 400)
                .mask(self.blur(radius: 20))
                .overlay(self.blur(radius: 5 - CGFloat(i * 5)))
                
        }
    }
}

struct Line_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            Line(data: ChartData(points: [12,-230,10,54]), frame: .constant(geometry.frame(in: .local)), touchLocation: .constant(CGPoint(x: 100, y: 12)), showIndicator: .constant(true), minDataValue: .constant(nil), maxDataValue: .constant(nil))
        }.frame(width: 320, height: 160)
    }
}
