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
    return boundsHeight - (((value - min) / (max - min)) * boundsHeight)
}

extension CGPoint {
    static func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x:(p1.x + p2.x) / 2,y: (p1.y + p2.y) / 2)
    }
    
    static func controlPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        var controlPoint = CGPoint.midPointForPoints(p1: p1, p2: p2)
        
        let diffY = abs(p2.y - controlPoint.y)
        
        if (p1.y < p2.y){
            controlPoint.y += diffY
        } else if (p1.y > p2.y) {
            controlPoint.y -= diffY
        }
        
        return controlPoint
    }
}

class TimeDistributionPointCard: UIStackView {
    var solve: Solve?
    
    lazy var iconView: UIImageView = {
        var iconView = UIImageView()
        
        iconView = UIImageView(image: UIImage(named: puzzleTypes[Int(solve?.scrambleType ?? 0)].name))
        iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        iconView.tintColor = .black
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        return iconView
    }()
    
    lazy var chevron: UIImageView = {
        var chevron = UIImageView()
        
        chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor.black
        
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .preferredFont(for: .footnote, weight: .medium))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        return chevron
        
    }()
    
    lazy var timeLabel: UILabel = {
        var timeLabel = UILabel()
        
        timeLabel.text = self.solve?.timeText ?? ""
        timeLabel.font = .preferredFont(for: .subheadline, weight: .semibold)
        timeLabel.adjustsFontForContentSizeCategory = true
        
        return timeLabel
    }()
    
    lazy var dateLabel: UILabel = {
        var dateLabel = UILabel()
        
        if let date = self.solve?.date {
            dateLabel.text = getSolveDateFormatter(date).string(from: date)
        } else {
            dateLabel.text = "Unknown Date"
        }
        
        dateLabel.font = .preferredFont(forTextStyle: .footnote)
        dateLabel.textColor = UIColor(Color("grey"))
        dateLabel.adjustsFontForContentSizeCategory = true
        
        return dateLabel
    }()
    
    lazy var infoStack: UIStackView = {
        var infoStack = UIStackView(frame: .zero)
        
        infoStack.axis = .vertical
        infoStack.alignment = .leading
        infoStack.distribution = .fill
        infoStack.spacing = -2
        infoStack.addArrangedSubview(self.timeLabel)
        infoStack.addArrangedSubview(self.dateLabel)
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        
        return infoStack
    }()
    
    init(solve: Solve?) {
        self.solve = solve
        
        super.init(frame: .zero)
        
        self.setupCard()
        
        
        self.addArrangedSubview(self.iconView)
        self.addArrangedSubview(self.infoStack)
        self.addArrangedSubview(self.chevron)
        
        
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 44),
            
            self.iconView.widthAnchor.constraint(equalToConstant: 24),
            self.iconView.heightAnchor.constraint(equalTo: self.iconView.widthAnchor),
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    private func setupCard() {
        self.layer.cornerRadius = 6
        self.layer.cornerCurve = .continuous
        self.backgroundColor = UIColor(Color("overlay0"))
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.04
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.distribution = .fill
        self.alignment = .center
        self.spacing = 10
        
        self.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.isLayoutMarginsRelativeArrangement = true
        
        self.setCustomSpacing(16, after: self.infoStack)
    }
    
    func updateLabel(with solve: Solve) {
        self.timeLabel.text = solve.timeText
        
        if let date = solve.date {
            self.dateLabel.text = getSolveDateFormatter(date).string(from: date)
        } else {
            self.dateLabel.text = "Unknown Date"
        }
    }
}



class TimeDistViewController: UIViewController {
    let points: [LineChartPoint]
    var interval: Int {
        didSet {
            print("gap delta did set")
            self.drawGraph()
        }
    }
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var highlightedPoint: HighlightedPoint!
    var highlightedCard: TimeDistributionPointCard!
    
    let imageHeight: CGFloat = 300
    
    // let crossView: CGPath!  // TODO: the crosses for DNFs that is drawn (copy)
    
    private let dotSize: CGFloat = 6
    
    init(points: [LineChartPoint], interval: Int, averageValue: Double, limits: (min: Double, max: Double)) {
        self.points = points
        self.interval = interval
        self.averageValue = averageValue
        self.limits = limits
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = UIScrollView()
        self.scrollView.showsHorizontalScrollIndicator = true
        
        self.view.clipsToBounds = true
        
        self.view.addSubview(scrollView)
        
        self.imageView = UIImageView(frame: .zero)
        self.imageView = UIImageView(image: self.drawGraph())
        
        self.scrollView.addSubview(self.imageView)
        self.scrollView.frame = self.view.frame
        
        self.scrollView.isUserInteractionEnabled = true
        
        /// debug: add border
                scrollView.layer.borderWidth = 2
                scrollView.layer.borderColor = UIColor.blue.cgColor
        
                self.imageView.layer.borderWidth = 2
                self.imageView.layer.borderColor = UIColor.black.cgColor
        /// end debug
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(panning))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        
        scrollView.addGestureRecognizer(longPressGestureRecognizer)
        
        self.highlightedPoint = HighlightedPoint(frame: CGRect(x: 10, y: 10, width: 12, height: 12))
        
        self.highlightedPoint.backgroundColor = .clear
        self.highlightedPoint.frame = CGRect(x: self.points[1].point.x - 6,
                                             y: self.points[1].point.y - 6,
                                             width: 12, height: 12)
        self.highlightedPoint.isHidden = true
        
        self.scrollView.addSubview(self.highlightedPoint)
        
        
        self.highlightedCard = TimeDistributionPointCard(solve: nil)
        self.highlightedCard.isHidden = true
        
        self.scrollView.addSubview(self.highlightedCard)
    }
    
    private func drawGraph() -> UIImage {
        let imageSize = CGSize(width: CGFloat((points.count - 1) * interval),
                               height: imageHeight)
        
        /// draw line
        let trendLine = UIBezierPath()
        let bottomLine = UIBezierPath()
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        
        /// bottom line
        bottomLine.move(to: CGPoint(x: 0, y: imageHeight))
        bottomLine.lineWidth = 2
        bottomLine.addLine(to: CGPoint(x: CGFloat((points.count - 1) * self.interval), y: imageHeight))
        context.setStrokeColor(UIColor(Color("indent0")).cgColor)
        bottomLine.stroke()
        
        /// graph line
        context.setStrokeColor(UIColor(Color("accent")).cgColor)
        
        for i in 0 ..< points.count {
            let prev = points[i - 1 >= 0 ? i - 1 : 0]
            let cur = points[i]
            
            if (trendLine.isEmpty) {
                trendLine.move(to: CGPointMake(dotSize/2, cur.point.y))
                continue
            }
            
            let mid = CGPoint.midPointForPoints(p1: prev.point, p2: cur.point)
            
            trendLine.addQuadCurve(to: mid,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: prev.point))
            
            trendLine.addQuadCurve(to: cur.point,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: cur.point))
        }
        
        trendLine.lineWidth = 2
        trendLine.lineCapStyle = .round
        trendLine.lineJoinStyle = .round
        
        let beforeLine = trendLine.copy() as! UIBezierPath
        
        trendLine.addLine(to: CGPoint(x: points.last!.point.x, y: imageHeight))
        trendLine.addLine(to: CGPoint(x: 0, y: imageHeight))
        trendLine.addLine(to: CGPoint(x: 0, y: points.first!.point.y))
        
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
        
        self.imageView.image = newImage
        self.scrollView.contentSize = newImage.size
        
        return newImage
    }
    
    @objc func updateGap(_ interval: Int) {
        self.interval = interval
        print(self.interval)
    }
    
    @objc func panning(_ pgr: UILongPressGestureRecognizer) {
        #warning("when you first long press and don't move the card is at .zero, but only for the first time - other times when you just press it's fine and is at the correct location")
        if (pgr.state == .ended) {
            self.highlightedPoint.isHidden = true
            self.highlightedCard.isHidden = true
            return
        }
        
        let closestIndex = Int((pgr.location(in: self.scrollView).x + 6) / CGFloat(self.interval))
        let closestPoint = self.points[closestIndex]
        
        self.highlightedCard.updateLabel(with: closestPoint.solve)
        
        self.highlightedPoint.frame.origin = CGPoint(x: closestPoint.point.x - 6,
                                                     y: closestPoint.point.y - 6)
        
        #warning("this only work for when there is no scroll offset...")
        self.highlightedCard.frame.origin = CGPoint(x: min(max(0, closestPoint.point.x - (self.highlightedCard.frame.width / 2)), self.scrollView.frame.width - self.highlightedCard.frame.width),
                                                    y: closestPoint.point.y - 80)
        
        self.highlightedPoint.isHidden = false
        self.highlightedCard.isHidden = false
        
        
    }
}


struct DetailTimeTrendBase: UIViewControllerRepresentable {
    typealias UIViewControllerType = TimeDistViewController
    
    let points: [LineChartPoint]
    let interval: Int
    let averageValue: Double
    let proxy: GeometryProxy
    
    let limits: (min: Double, max: Double)
    
    init(rawDataPoints: [Solve], limits: (min: Double, max: Double), averageValue: Double, interval: Int, proxy: GeometryProxy) {
        self.points = rawDataPoints.enumerated().map({ (i, e) in
            return LineChartPoint(solve: e, position: Double(i * interval), min: limits.min, max: limits.max, boundsHeight: 300)
        })
        self.averageValue = averageValue
        self.limits = limits
        self.interval = interval
        self.proxy = proxy
        
        print("detail time trend reinit with \(interval)")
    }
    
    func makeUIViewController(context: Context) -> TimeDistViewController {
        let timeDistViewController = TimeDistViewController(points: points, interval: interval, averageValue: averageValue, limits: limits)
        print(proxy.size.width, proxy.size.height)
        timeDistViewController.view.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        timeDistViewController.scrollView.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        
        return timeDistViewController
    }
    
    func updateUIViewController(_ uiViewController: TimeDistViewController, context: Context) {
        uiViewController.view?.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        print("new gap delta \(interval)")
        uiViewController.updateGap(interval)
        
        print("vc updated")
    }
}
