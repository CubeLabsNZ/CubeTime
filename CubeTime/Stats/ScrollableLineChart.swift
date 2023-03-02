//
//  ScrollableLineChart.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//
import UIKit
import SwiftUI

private let dotDiameter: CGFloat = 6

struct LineChartPoint {
    var point: CGPoint
    var rawValue: Double
    
    init(value: Double, position: Double, min: Double, max: Double, boundsHeight: CGFloat) {
        self.rawValue = value
        self.point = CGPoint()
        self.point.y = getStandardisedYLocation(value: value, min: min, max: max, boundsHeight: boundsHeight)
        self.point.x = position
    }
    
    func pointIn(_ other: CGPoint) -> Bool {
        let rect = CGRect(x: point.x - dotDiameter / 2, y: point.y - dotDiameter / 2, width: dotDiameter, height: dotDiameter)
        return rect.contains(other)
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


class TimeDistViewController: UIViewController {
    let points: [LineChartPoint]
    let gapDelta: Int
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    
    
    private let dotSize: CGFloat = 6
    
    init(points: [LineChartPoint], gapDelta: Int, averageValue: Double, limits: (min: Double, max: Double)) {
        self.points = points
        self.gapDelta = gapDelta
        self.averageValue = averageValue
        self.limits = limits
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        let textView = UITextView()
        textView.text = formatSolveTime(secs: limits.min)
        let size = textView.sizeThatFits(CGSize(width: Double.infinity, height: .infinity))
        textView.frame = CGRect(x: self.view.frame.width - size.width, y: UIScreen.screenHeight*0.618 - size.height / 2, width: size.width, height: size.height)
        
        textView.backgroundColor = .white
        textView.layer.zPosition = 2
        
        self.view.addSubview(textView)
        
        NSLog("FRAME TEXT \(textView.frame)")
    
        let imageSize = CGSize(width: CGFloat(points.count * gapDelta),
                               height: view.frame.height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        
        let height = getStandardisedYLocation(value: averageValue,
                                              min: limits.min,
                                              max: limits.max,
                                              boundsHeight: UIScreen.screenHeight*0.618)
        
        context.move(to: CGPoint(x: 0, y: UIScreen.screenHeight*0.618))
        
        context.setLineDash(phase: 0, lengths: [12, 6])
        context.setStrokeColor(UIColor(Color("grey")).cgColor)
        context.setLineWidth(2)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.addLine(to: CGPoint(x: 1200, y: UIScreen.screenHeight*0.618))

        context.drawPath(using: .stroke)
        
        context.setLineDash(phase: 0, lengths: [])
        context.setStrokeColor(UIColor(Color.accentColor).cgColor)
        
        let trendLine: UIBezierPath = UIBezierPath()
        
        for i in 0 ..< points.count {
            if (trendLine.isEmpty) {
                trendLine.move(to: CGPointMake(points[i].point.x + dotSize/2, points[i].point.y))
            } else {
                trendLine.addLine(to: points[i].point)
//                let a = points[i-1].point
//                let b = points[i].point
//                let mid = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
//                trendLine.addQuadCurve(to: points[i].point, controlPoint: mid)
            }
        }
        
        trendLine.lineWidth = 3
        trendLine.lineCapStyle = .round
        trendLine.lineJoinStyle = .round
        
        trendLine.stroke()
        
        trendLine.addLine(to: CGPoint(x: points.last!.point.x, y: UIScreen.screenHeight*0.618))
        trendLine.addLine(to: CGPoint(x: 0, y: UIScreen.screenHeight*0.618))

        for p in points {
            let circlePoint = CGRect(x: p.point.x - dotSize/2,
                                     y: p.point.y - dotSize/2,
                                     width: dotSize,
                                     height: dotSize)
            
            context.setFillColor(UIColor.red.cgColor)
            context.fillEllipse(in: circlePoint)
        }
        
        let grad = CGGradient(colorsSpace: .none, colors: [UIColor(Color.accentColor.opacity(0.6)).cgColor, UIColor(Color.accentColor.opacity(0.2)).cgColor] as CFArray, locations: [0, 1])!
        
//        context.saveGState()
        trendLine.addClip()
        
        context.drawLinearGradient(grad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: UIScreen.screenHeight*0.618), options: [] )
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!

        let scrollView = UIScrollView()
        imageView = UIImageView(image: newImage)
//        imageView.contentMode = .scaleToFill
//
//        var fr = imageView.frame
//        fr.size = newImage.size
//        imageView.frame = fr
        
        
        
//        self.view.addSubview(scrollView)
        self.view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.frame = view.frame
        scrollView.contentSize = newImage.size
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(clicked(g: )))
        )
    }
    
    @objc func clicked(g: UITapGestureRecognizer) {
        let p = g.location(in: imageView)
        let pointWhere = points.first(where: {$0.pointIn(p)})
        NSLog("\(pointWhere)")
    }
}


struct DetailTimeDist: UIViewControllerRepresentable {
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
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let view = TimeDistViewController(points: points, gapDelta: gapDelta, averageValue: averageValue, limits: limits)
        return view
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
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
    
    
    
    var body: some View {
        ScrollView(.horizontal) {
            Canvas { context, size in
                var averageLine = Path()
                
                let height = getStandardisedYLocation(value: averageValue,
                                                      min: limits.min,
                                                      max: limits.max,
                                                      boundsHeight: UIScreen.screenHeight*0.618)
                
                averageLine.move(to: CGPoint(x: dotDiameter,
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
                                             y: p.point.y - dotDiameter/2,
                                             width: dotDiameter,
                                             height: dotDiameter)
                        
                        path.move(to: CGPointMake(p.point.x + dotDiameter/2, p.point.y))
                    } else {
                        circlePoint = CGRect(x: p.point.x - dotDiameter/2,
                                             y: p.point.y - dotDiameter/2,
                                             width: dotDiameter,
                                             height: dotDiameter)
                        
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
