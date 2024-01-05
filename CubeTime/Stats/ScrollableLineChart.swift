//
//  ScrollableLineChart.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//
import UIKit
import SwiftUI

class HighlightedPoint: UIView {
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath()
        path = UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 8, height: 8))
        UIColor(Color("accent")).setStroke()
        UIColor(Color("overlay0")).setFill()
        path.lineWidth = 4
        path.stroke()
        path.fill()
    }
}


private let dotDiameter: CGFloat = 6

private let INTERVAL: Int = 30

struct LineChartPoint {
    var point: CGPoint
    var solve: Solve
    
    init(solve: Solve, position: Double, min: Double, max: Double, boundsHeight: CGFloat) {
        self.solve = solve
        self.point = CGPoint()
        self.point.y = getStandardisedYLocation(value: solve.timeIncPen, min: min, max: max, boundsHeight: boundsHeight)
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

func makeData(_ data: [Solve], _ limits: (min: Double, max: Double), _ boundsHeight: CGFloat=300) -> [LineChartPoint] {
    return data.enumerated().map({ (i, e) in
        return LineChartPoint(solve: e, position: Double(i * INTERVAL), min: limits.min, max: limits.max, boundsHeight: boundsHeight)
    })
}


class TimeDistViewController: UIViewController {
    let points: [LineChartPoint]
    let gapDelta: Int
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    var hightlightedPoint: HighlightedPoint!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    let crossView: CGPath!  // TODO: the crosses for DNFs that is drawn (copy)
    
    var yOffset: CGFloat!
    
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
    
    override func viewDidLoad() {
        let imageHeight: CGFloat = 300
        
        let imageSize = CGSize(width: CGFloat(points.count * gapDelta),
                               height: imageHeight)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.move(to: CGPoint(x: 0, y: imageHeight))
        
        context.setLineDash(phase: 0, lengths: [12, 6])
        context.setStrokeColor(UIColor(Color("grey")).cgColor)
        context.setLineWidth(2)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.addLine(to: CGPoint(x: 1200, y: imageHeight))

        context.drawPath(using: .stroke)
        
        context.setLineDash(phase: 0, lengths: [])
        context.setStrokeColor(UIColor(Color("accent")).cgColor)
        
        let trendLine: UIBezierPath = UIBezierPath()
        
        for i in 0 ..< points.count {
            let p = points[i].point
            
            if (trendLine.isEmpty) {
                trendLine.move(to: CGPointMake(dotSize/2, p.y))
            } else {
                trendLine.addLine(to: CGPointMake(p.x, p.y))
            }
        }
        
        trendLine.lineWidth = 2
        trendLine.lineCapStyle = .round
        trendLine.lineJoinStyle = .round
        
        let beforeLine = trendLine.copy() as! UIBezierPath
        
        trendLine.addLine(to: CGPoint(x: points.last!.point.x, y: imageHeight))
        trendLine.addLine(to: CGPoint(x: 0, y: imageHeight))

        let grad = CGGradient(colorsSpace: .none, 
                              colors: [
                                UIColor(staticGradient[0].opacity(0.6)).cgColor,
                                UIColor(staticGradient[1].opacity(0.2)).cgColor,
                                UIColor.clear.cgColor
                              ] as CFArray,
                              locations: [0.0, 0.4, 1.0])!
        
        trendLine.addClip()
        
        context.drawLinearGradient(grad, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: imageHeight), options: [] )
        
        context.resetClip()
        
        beforeLine.stroke()
        
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!

        self.scrollView = UIScrollView()
        
        imageView = UIImageView(image: newImage)
        let fr = imageView.frame
        self.yOffset = (self.view.frame.height - fr.height) / 2
        
        imageView.frame = CGRect(x: fr.minX, y: yOffset, width: fr.width, height: fr.height)
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        scrollView.frame = view.frame
        scrollView.contentSize = newImage.size
        
        scrollView.isUserInteractionEnabled = true
        scrollView.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(panning))
        )
        
        self.hightlightedPoint = HighlightedPoint(frame: CGRect(x: 10, y: 10, width: 12, height: 12))
        
        self.hightlightedPoint.backgroundColor = .clear
        self.hightlightedPoint.frame = CGRect(x: self.points[1].point.x - 6,
                                              y: self.points[1].point.y + yOffset - 6,
                                              width: 12, height: 12)
        scrollView.addSubview(self.hightlightedPoint)
    }
    
    @objc func panning(_ pgr: UILongPressGestureRecognizer) {
        if (pgr.state == .ended) {
            self.hightlightedPoint.isHidden = true
            return
        }
        
        self.hightlightedPoint.isHidden = false
        var closestIndex = Int((pgr.location(in: self.scrollView).x + 6) / CGFloat(INTERVAL))
        var closestPoint = self.points[closestIndex]
        
        self.hightlightedPoint.frame = CGRect(x: closestPoint.point.x - 6,
                                              y: closestPoint.point.y - 6 + yOffset,
                                              width: 12, height: 12)
    }
}


struct DetailTimeTrendBase: UIViewControllerRepresentable {
    let points: [LineChartPoint]
    let gapDelta: Int
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    init(rawDataPoints: [Solve], limits: (min: Double, max: Double), averageValue: Double, gapDelta: Int = 30) {
        self.points = makeData(rawDataPoints, limits)
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
