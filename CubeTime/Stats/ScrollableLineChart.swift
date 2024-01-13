//
//  ScrollableLineChart.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//
import UIKit
import SwiftUI

class HighlightedPoint: UIView {
    let path = UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 8, height: 8))
    
    var isRegular = true {
        didSet { 
            self.setNeedsDisplay()
        }
    }
    
    init(at loc: CGPoint) {
        super.init(frame: CGRect(origin: loc, size: CGSize(width: 12, height: 12)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor(Color("overlay0")).setFill()
        UIColor(Color(self.isRegular ? "accent" : "grey")).setStroke()
        
        path.lineWidth = 4
        path.stroke()
        path.fill()
        
    }
}


private let dotDiameter: CGFloat = 6

struct LineChartPoint {
    var point: CGPoint
    var solve: Solve
    
    init(solve: Solve, 
         position: Double,
         min: Double, max: Double,
         imageHeight: CGFloat) {
        self.solve = solve
        self.point = CGPoint()
        self.point.y = getStandardisedYLocation(value: solve.timeIncPen, 
                                                min: min, max: max,
                                                imageHeight: imageHeight)
        self.point.x = position
    }
    
    func pointIn(_ other: CGPoint) -> Bool {
        let rect = CGRect(x: point.x - dotDiameter / 2, y: point.y - dotDiameter / 2, width: dotDiameter, height: dotDiameter)
        return rect.contains(other)
    }
}

func getStandardisedYLocation(value: Double, 
                              min: Double, max: Double,
                              imageHeight: CGFloat) -> CGFloat {
    return imageHeight - (((value - min) / (max - min)) * (imageHeight - 2) + 1)
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



class TimeDistViewController: UIViewController, UIScrollViewDelegate {
    var points: [LineChartPoint]
    var interval: Int {
        didSet {
            print("gap delta did set")
            self.drawGraph()
            self.drawYAxisValues()
        }
    }
    
    let stopwatchManager: StopwatchManager
    
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    var scrollView: UIScrollView!
    var imageView = UIImageView(frame: .zero)
    var highlightedPoint: HighlightedPoint!
    var highlightedCard: TimeDistributionPointCard!
    
    let imageHeight: CGFloat
    
    var yAxis: UIView!
    
    var imageWidthConstraint: NSLayoutConstraint!
    
    var lastSelectedSolve: Solve!
    
    // let crossView: CGPath!  // TODO: the crosses for DNFs that is drawn (copy)
    
    private let dotSize: CGFloat = 6
    
    init(stopwatchManager: StopwatchManager, points: [LineChartPoint], interval: Int, averageValue: Double, limits: (min: Double, max: Double), imageHeight: CGFloat) {
        self.stopwatchManager = stopwatchManager
        self.points = points
        self.interval = interval
        self.averageValue = averageValue
        self.limits = limits
        self.imageHeight = imageHeight
        
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
        self.scrollView.addSubview(self.imageView)
        
        self.drawGraph()
        
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(panning))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        tapGestureRecognizer.require(toFail: longPressGestureRecognizer)
        
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        scrollView.addGestureRecognizer(longPressGestureRecognizer)
        
        
        self.highlightedPoint = HighlightedPoint(at: .zero)
        
        self.highlightedPoint.backgroundColor = .clear
        self.highlightedPoint.frame = CGRect(x: self.points[1].point.x - 6,
                                             y: self.points[1].point.y - 6,
                                             width: 12, height: 12)
        self.highlightedPoint.layer.opacity = 1
        
        self.scrollView.addSubview(self.highlightedPoint)
        self.imageView.isUserInteractionEnabled = true
        
        
        self.highlightedCard = TimeDistributionPointCard(solve: nil)
        #warning("BUG: card only tappable when in imageview frame. otherwise not tappable")
        let cardTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(solveCardTapped))
        self.highlightedCard.addGestureRecognizer(cardTapGestureRecognizer)
        self.highlightedCard.layer.opacity = 1
        
        self.scrollView.addSubview(self.highlightedCard)
        
        tapGestureRecognizer.shouldRequireFailure(of: cardTapGestureRecognizer)
        
        self.yAxis = drawYAxisValues()
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.yAxis.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    private func createDNFPoint() -> UIImage {
        #warning("for some reason slightly different to swiftui version... config is exactly the same?")
        var config = UIImage.SymbolConfiguration(font: .preferredFont(for: .caption1, weight: .bold), scale: .medium)

        
        return UIImage(systemName: "xmark", withConfiguration: config)!
    }
    
    private func drawGraph() -> UIImage {
        var dnfedIndices: [Int] = []
        
        let imageSize = CGSize(width: CGFloat((points.count - 1) * interval + 6),
                               height: imageHeight)
        
        /// draw line
        let trendLine = UIBezierPath()
        let gradientLine = UIBezierPath()
        
        let xAxis = UIBezierPath()
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        
        /// x axis
        xAxis.move(to: CGPoint(x: 0, y: imageHeight - 0.5))
        xAxis.lineWidth = 1
        xAxis.addLine(to: CGPoint(x: CGFloat((points.count - 1) * self.interval), y: imageHeight - 0.5))
        context.setStrokeColor(UIColor(Color("indent0")).cgColor)
        xAxis.stroke()
        
        
        /// graph line
        context.setStrokeColor(UIColor(Color("accent")).cgColor)
        
        trendLine.lineWidth = 2
        trendLine.lineCapStyle = .round
        trendLine.lineJoinStyle = .round
        
        for i in 0 ..< points.count {
            let prev = points[i - 1 >= 0 ? i - 1 : 0]
            let cur = points[i]
            let next = points[i + 1 < points.count ? i + 1 : points.count - 1]
            
            if (trendLine.isEmpty) {
                trendLine.move(to: CGPoint(x: 0, y: cur.point.y))
                gradientLine.move(to: CGPoint(x: 0, y: cur.point.y))
                continue
            }
            
            let mid = CGPoint.midPointForPoints(p1: prev.point, p2: cur.point)
            
            trendLine.addQuadCurve(to: mid,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: prev.point))
            gradientLine.addQuadCurve(to: mid,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: prev.point))
            
            
            if Penalty(rawValue: cur.solve.penalty) == .dnf {
                trendLine.stroke()
                trendLine.removeAllPoints()
                trendLine.move(to: mid)
                context.setStrokeColor(UIColor(Color("indent0")).cgColor)
            }
            
            if Penalty(rawValue: prev.solve.penalty) == .dnf {
                trendLine.stroke()
                trendLine.removeAllPoints()
                trendLine.move(to: mid)
                context.setStrokeColor(UIColor(Color("accent")).cgColor)
            }
            
            trendLine.addQuadCurve(to: cur.point,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: cur.point))
            gradientLine.addQuadCurve(to: cur.point,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: cur.point))
            
            if Penalty(rawValue: cur.solve.penalty) == .dnf {
                dnfedIndices.append(i)
            }
        }
        
        
        gradientLine.addLine(to: CGPoint(x: points.last!.point.x, y: imageHeight))
        gradientLine.addLine(to: CGPoint(x: 0, y: imageHeight))
        gradientLine.addLine(to: CGPoint(x: 0, y: points.first!.point.y))
        
        gradientLine.close()
        
        gradientLine.addClip()
        
        context.drawLinearGradient(CGGradient(colorsSpace: .none,
                                              colors: [
                                                UIColor(staticGradient[0].opacity(0.6)).cgColor,
                                                UIColor(staticGradient[1].opacity(0.2)).cgColor,
                                                UIColor(staticGradient[1].opacity(0.01)).cgColor
                                              ] as CFArray,
                                              locations: [0.0, 0.4, 1.0])!,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: imageHeight),
                                   options: [])
        
        context.resetClip()
        
        trendLine.stroke()
        
        
        UIColor(Color("grey")).set()
        
        /// draw dnf crosses
        for i in dnfedIndices {
            let image = createDNFPoint()
            
            
            let imageRect = CGRect(x: points[i].point.x - 4, y: points[i].point.y - 4, width: 8, height: 8)
            
            context.clip(to: imageRect, mask: image.cgImage!)

            context.addRect(imageRect)
            context.drawPath(using: .fill)
        }
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        self.imageView.image = image
    
        
        NSLayoutConstraint.deactivate(self.imageView.constraints)
        
        NSLayoutConstraint.activate([
            self.imageView.heightAnchor.constraint(equalToConstant: self.imageHeight),
            self.imageView.bottomAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.bottomAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor),
            
            self.imageView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor),
            
            self.imageView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor),
            
            self.imageView.widthAnchor.constraint(equalToConstant: image.size.width)
        ])
        
        return image
    }
    
    private func drawYAxisValues() -> UIView {
        let range = self.limits.max - self.limits.min
        let view = UIStackView(frame: .zero)
        
        let stackView = UIStackView(frame: .zero)
        stackView.distribution = .equalSpacing
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addArrangedSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
        
        stackView.sizeToFit()
        
        view.alignment = .center
        view.axis = .horizontal
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        
        for i in (0 ..< 6).reversed() {
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.adjustsFontSizeToFitWidth = true
            label.font = .preferredFont(forTextStyle: .caption2)
            label.textColor = UIColor(Color("grey"))
            
            label.text = formatSolveTime(secs: self.limits.min + Double(i) * range / Double(5))
            
            stackView.addArrangedSubview(label)
            
            label.sizeToFit()
            
        }
        
        let imageSize = CGSize(width: 1, height: self.imageHeight)
        
        let yAxis = UIBezierPath()
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.setStrokeColor(UIColor(Color("indent0")).cgColor)
        
        yAxis.move(to: CGPoint(x: 0.5, y: 0))
        yAxis.addLine(to: CGPoint(x: 0.5, y: self.imageHeight))
        yAxis.lineWidth = 1
        yAxis.stroke()
        
        let lineView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext()!)
        
        view.spacing = 4
        view.addArrangedSubview(lineView)
        
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.heightAnchor.constraint(equalToConstant: self.imageHeight),
        ])
        
        
        return view
    }
    
    func updateGap(interval: Int, points: [LineChartPoint]) {
        self.points = points
        self.interval = interval
        
        self.removeSelectedPoint()
    }
    
    private func removeSelectedPoint(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseOut, animations: {
                self.highlightedCard.layer.opacity = 0
                self.highlightedPoint.layer.opacity = 0
            })
        } else {
            self.highlightedCard.layer.opacity = 0
            self.highlightedPoint.layer.opacity = 0
        }
    }
    
    @objc func tapped(_ g: UITapGestureRecognizer) {
        self.removeSelectedPoint()
    }
    
    @objc func panning(_ pgr: UILongPressGestureRecognizer) {
        let closestIndex = max(0, min(self.points.count - 1, Int((pgr.location(in: self.scrollView).x + 6) / CGFloat(self.interval))))
        let closestPoint = self.points[closestIndex]
        
        self.highlightedCard.updateLabel(with: closestPoint.solve)
        
        self.highlightedPoint.isRegular = Penalty(rawValue: closestPoint.solve.penalty) != .dnf
        
        self.highlightedPoint.frame.origin = imageView.convert(CGPoint(x: closestPoint.point.x - 6,
                                                                             y: closestPoint.point.y - 6), to: scrollView)

        
        self.lastSelectedSolve = closestPoint.solve

        self.highlightedCard.frame.origin = imageView.convert(CGPoint(x: min(max(self.scrollView.contentOffset.x,
                    closestPoint.point.x - (self.highlightedCard.frame.width / 2)),
                self.scrollView.frame.width - self.highlightedCard.frame.width + self.scrollView.contentOffset.x),
                                                                      y: closestPoint.point.y - 80), to: scrollView)
        
        self.highlightedPoint.layer.opacity = 1
        self.highlightedCard.layer.opacity = 1
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        removeSelectedPoint(animated: false)
    }
    
    @objc func solveCardTapped(_ g: UITapGestureRecognizer) {
        let solveSheet = UIHostingController(rootView: TimeDetailView(for: self.lastSelectedSolve, currentSolve: .constant(self.lastSelectedSolve)).environmentObject(stopwatchManager))
        
        #warning("BUG: the toolbar doesn't display")
        self.present(solveSheet, animated: true, completion: { self.removeSelectedPoint() })
    }
}


struct DetailTimeTrendBase: UIViewControllerRepresentable {
    typealias UIViewControllerType = TimeDistViewController
    
    let stopwatchManager: StopwatchManager
    let points: [LineChartPoint]
    let interval: Int
    let averageValue: Double
    let proxy: GeometryProxy
    
    let limits: (min: Double, max: Double)
    
    init(stopwatchManager: StopwatchManager, rawDataPoints: [Solve], limits: (min: Double, max: Double), averageValue: Double, interval: Int, proxy: GeometryProxy) {
        self.stopwatchManager = stopwatchManager
        self.points = rawDataPoints.enumerated().map({ (i, e) in
            return LineChartPoint(solve: e,
                                  position: Double(i * interval),
                                  min: limits.min, max: limits.max,
                                  imageHeight: proxy.size.height - 100)
        })
        self.averageValue = averageValue
        self.limits = limits
        self.interval = interval
        self.proxy = proxy
    }
    
    func makeUIViewController(context: Context) -> TimeDistViewController {
        let timeDistViewController = TimeDistViewController(stopwatchManager: stopwatchManager, points: points, interval: interval, averageValue: averageValue, limits: limits, imageHeight: proxy.size.height - 100)
        
        timeDistViewController.view.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        timeDistViewController.scrollView.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        
        return timeDistViewController
    }
    
    func updateUIViewController(_ uiViewController: TimeDistViewController, context: Context) {
        uiViewController.view?.frame = CGRect(x: 0, y: 0, width: proxy.size.width, height: proxy.size.height)
        uiViewController.updateGap(interval: interval, points: points)
    }
}
