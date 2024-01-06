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

class TimeDistViewController: UIViewController {
    let points: [LineChartPoint]
    let gapDelta: Int
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    var hightlightedPoint: HighlightedPoint!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    let imageHeight: CGFloat = 300
    
    // let crossView: CGPath!  // TODO: the crosses for DNFs that is drawn (copy)
    
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
        self.scrollView = UIScrollView()
        self.scrollView.showsHorizontalScrollIndicator = true
        
        
        let imageSize = CGSize(width: CGFloat(points.count * gapDelta),
                               height: imageHeight)
        
        /// draw line
        let trendLine = UIBezierPath()
        let bottomLine = UIBezierPath()
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        
        /// bottom line
        bottomLine.move(to: CGPoint(x: 0, y: imageHeight))
        bottomLine.lineWidth = 2
        bottomLine.addLine(to: CGPoint(x: CGFloat((points.count - 1) * INTERVAL), y: imageHeight))
        context.setStrokeColor(UIColor(Color("indent0")).cgColor)
        bottomLine.stroke()
        
        /// graph line
        context.setStrokeColor(UIColor(Color("accent")).cgColor)
        
        for p in points {
            if (trendLine.isEmpty) {
                trendLine.move(to: CGPointMake(dotSize/2, imageHeight - p.point.y))
            } else {
                trendLine.addLine(to: CGPointMake(p.point.x, imageHeight - p.point.y))
            }
        }
        
        trendLine.lineWidth = 2
        trendLine.lineCapStyle = .round
        trendLine.lineJoinStyle = .round
        
        let beforeLine = trendLine.copy() as! UIBezierPath
        
        trendLine.addLine(to: CGPoint(x: points.last!.point.x, y: imageHeight))
        trendLine.addLine(to: CGPoint(x: 0, y: imageHeight))
        trendLine.addLine(to: CGPoint(x: 0, y: imageHeight - points.first!.point.y))
        
        trendLine.close()
        
        trendLine.addClip()
        
        context.drawLinearGradient(CGGradient(colorsSpace: .none,
                                              colors: [
                                                UIColor(staticGradient[0].opacity(0.6)).cgColor,
                                                UIColor(staticGradient[1].opacity(0.2)).cgColor,
                                                UIColor.clear.cgColor
                                              ] as CFArray,
                                              locations: [0.0, 0.4, 1.0])!,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: imageHeight),
                                   options: [] )
        
        context.resetClip()
        
        beforeLine.stroke()
        
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        self.view.clipsToBounds = true
        
        imageView = UIImageView(image: newImage)
        self.view.addSubview(scrollView)
        
        scrollView.addSubview(imageView)
        scrollView.frame = view.frame
        scrollView.contentSize = newImage.size
        
        scrollView.isUserInteractionEnabled = true
        
        scrollView.layer.borderWidth = 2
        scrollView.layer.borderColor = UIColor.blue.cgColor
        
        self.imageView.layer.borderWidth = 2
        self.imageView.layer.borderColor = UIColor.black.cgColor
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(panning))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        
        scrollView.addGestureRecognizer(longPressGestureRecognizer)
        
        self.hightlightedPoint = HighlightedPoint(frame: CGRect(x: 10, y: 10, width: 12, height: 12))
        
        self.hightlightedPoint.backgroundColor = .clear
        self.hightlightedPoint.frame = CGRect(x: self.points[1].point.x - 6,
                                              y: imageHeight - self.points[1].point.y - 6,
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
                                              y: self.imageHeight - closestPoint.point.y - 6,
                                              width: 12, height: 12)
    }
}


struct DetailTimeTrendBase: UIViewControllerRepresentable {
    let points: [LineChartPoint]
    let gapDelta: Int
    let averageValue: Double
    let proxy: GeometryProxy
    
    let limits: (min: Double, max: Double)
    
    init(rawDataPoints: [Solve], limits: (min: Double, max: Double), averageValue: Double, gapDelta: Int = 30, proxy: GeometryProxy) {
        self.points = rawDataPoints.enumerated().map({ (i, e) in
            return LineChartPoint(solve: e, position: Double(i * INTERVAL), min: limits.min, max: limits.max, boundsHeight: 300)
        })
        self.averageValue = averageValue
        self.limits = limits
        self.gapDelta = gapDelta
        self.proxy = proxy
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let timeDistViewController = TimeDistViewController(points: points, gapDelta: gapDelta, averageValue: averageValue, limits: limits)
        print(proxy.size.width, proxy.size.height)
        timeDistViewController.view.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        timeDistViewController.scrollView.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        
        return timeDistViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.view?.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
    }
}
