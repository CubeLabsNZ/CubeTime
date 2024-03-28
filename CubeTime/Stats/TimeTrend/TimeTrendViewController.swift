//
//  ScrollableLineChart.swift
//  CubeTime
//
//  Created by Tim Xie on 2/03/23.
//

import UIKit
import SwiftUI


fileprivate let CHART_BOTTOM_PADDING: CGFloat = 50  // Allow for x axis
fileprivate let CHART_TOP_PADDING: CGFloat = 100

fileprivate let AXIS_LABEL_FONT = FontManager.fontFor(size: 10, weight: 400)

fileprivate let DOT_DIAMETER: CGFloat = 6  // possible to modify for accessibility purposes


extension CGPoint {
    static func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2,
                       y: (p1.y + p2.y) / 2)
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



struct TimeTrendPoint {
    var min: CGFloat
    var max: CGFloat
    
    var idx: Int
    
    var solve: Solve
    
    init(solve: Solve,
         idx: Int,
         min: Double, max: Double) {
        self.solve = solve
        self.idx = idx
        self.min = min
        self.max = max
    }
    
    
    func getPointFor(interval: Int, imageHeight: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(interval * self.idx),
                       y: imageHeight - (((CGFloat(solve.timeIncPen) - min) / (max - min)) * (imageHeight - 2) + 1))
    }
    
    
    func pointIn(interval: Int, imageHeight: CGFloat, other: CGPoint) -> Bool {
        let point = getPointFor(interval: interval, imageHeight: imageHeight)
        let rect = CGRect(x: point.x - DOT_DIAMETER / 2, y: point.y - DOT_DIAMETER / 2, width: DOT_DIAMETER, height: DOT_DIAMETER)
        return rect.contains(other)
    }
}




// MARK: - HOVER VIEWS
class TimeTrendHoverPointView: UIView {
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


class TimeTrendHoverCardView: UIStackView {
    var solve: Solve?
    
    lazy var iconView: UIImageView = {
        var iconView = UIImageView()
        
        iconView = UIImageView(image: UIImage(named: PUZZLE_TYPES[Int(solve?.scrambleType ?? 0)].name))
        iconView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        iconView.tintColor = UIColor(Color("dark"))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        return iconView
    }()
    
    lazy var chevron: UIImageView = {
        var chevron = UIImageView()
        
        chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = UIColor(Color("dark"))
        
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .preferredFont(for: .footnote, weight: .medium))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        return chevron
        
    }()
    
    lazy var timeLabel: UILabel = {
        var timeLabel = UILabel()
        
        timeLabel.text = self.solve?.timeText ?? ""
        timeLabel.font = FontManager.fontFor(size: 15, weight: 600)
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
        
        dateLabel.font = .preferredFont(forTextStyle: .caption1)
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


class TimeTrendLineChartScrollView: UIScrollView {
    static private let dotSize: CGFloat = 6
    
    var interval: Int
    var points: [TimeTrendPoint]
    
    
    init(frame: CGRect, interval: Int, points: [TimeTrendPoint]) {
        self.interval = interval
        self.points = points
        
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createDNFPoint() -> UIImage {
        let config = UIImage.SymbolConfiguration(font: .preferredFont(for: .caption1, weight: .bold), scale: .large)
        
        return UIImage(systemName: "xmark", withConfiguration: config)!
    }
    
    static let drawCountAround = 100
    static let redrawDistance = 20
    
    override func draw(_ rect: CGRect) {
        var dnfedIndices: [Int] = []
        
        /// draw line
        let trendLine = UIBezierPath()
        let gradientLine = UIBezierPath()
        
        let context = UIGraphicsGetCurrentContext()!
        
        let xAxis = UIBezierPath()
        
        let leftX = rect.minX
        let rightX = leftX + rect.width
        
        /// x axis
        xAxis.move(to: CGPoint(x: leftX, y: self.frame.height - CHART_BOTTOM_PADDING - 0.5))
        xAxis.lineWidth = 1
        xAxis.addLine(to: CGPoint(x: rightX, y: self.frame.height - CHART_BOTTOM_PADDING - 0.5))
        context.setStrokeColor(UIColor(Color("indent0")).cgColor)
        xAxis.stroke()
        
        
        /// graph line
        let graphLineColor = UIColor(Color("accent")).cgColor
        context.setStrokeColor(graphLineColor)
        
        trendLine.lineWidth = 2
        trendLine.lineCapStyle = .round
        trendLine.lineJoinStyle = .round
        
        
        let pointsSubset = points[max(Int(leftX) / interval - 1, 0)...min(Int(rightX) / interval + 1, points.count - 1)]
        
        
        let padded_height = self.frame.height - CHART_TOP_PADDING - CHART_BOTTOM_PADDING
        
        let intervalLine = UIBezierPath()
        intervalLine.lineWidth = 1
        
        for i in pointsSubset.indices {
            let prev = points[i - 1 >= 0 ? i - 1 : 0]
            let cur = points[i]
            
            var prevcgpoint = prev.getPointFor(interval: interval, imageHeight: padded_height)
            var curcgpoint = cur.getPointFor(interval: interval, imageHeight: padded_height)
            curcgpoint.y += CHART_TOP_PADDING
            prevcgpoint.y += CHART_TOP_PADDING
            
            let drawText = (i % (Int(self.bounds.width) / (interval * 2))) == 0 && i != 0
            
            if drawText {
                context.saveGState()
                let string = "\(i + 1)" as NSString
                
                let attributes = [
                    NSAttributedString.Key.font : AXIS_LABEL_FONT,
                    NSAttributedString.Key.foregroundColor : UIColor(Color("grey"))
                ]
                
                // Get the width and height that the text will occupy.
                let stringSize = string.size(withAttributes: attributes)
                
                string.draw(
                    in: CGRectMake(
                        CGFloat(i) * CGFloat(interval) - stringSize.width / 2,
                        padded_height + CHART_TOP_PADDING,
                        stringSize.width,
                        stringSize.height
                    ),
                    withAttributes: attributes
                )
                
                intervalLine.move(to: CGPoint(x: CGFloat(i * interval), y: self.frame.height - CHART_BOTTOM_PADDING - 0.5))
                intervalLine.lineWidth = 1
                intervalLine.setLineDash([6, 6], count: 2, phase: 0)
                intervalLine.addLine(to: CGPoint(x: CGFloat(i * interval), y: CHART_TOP_PADDING + 0.5))
                context.setStrokeColor(UIColor(Color("indent1")).cgColor)
                intervalLine.stroke()
                
                
                // String drawing changes color
                context.restoreGState()
            }
            
            
            if (trendLine.isEmpty) {
                trendLine.move(to: CGPoint(x: 0, y: curcgpoint.y))
                gradientLine.move(to: CGPoint(x: 0, y: curcgpoint.y))
                continue
            }
            
            let mid = CGPoint.midPointForPoints(p1: prevcgpoint, p2: curcgpoint)
            
            trendLine.addQuadCurve(to: mid,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: prevcgpoint))
            gradientLine.addQuadCurve(to: mid,
                                      controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: prevcgpoint))
            
            
            if Penalty(rawValue: cur.solve.penalty) == .dnf {
                trendLine.stroke()
                trendLine.removeAllPoints()
                trendLine.move(to: mid)
                context.setStrokeColor(UIColor(Color("indent0")).cgColor)
            } else if Penalty(rawValue: prev.solve.penalty) == .dnf {
                trendLine.stroke()
                trendLine.removeAllPoints()
                trendLine.move(to: mid)
                context.setStrokeColor(UIColor(Color("accent")).cgColor)
            }
            
            
            trendLine.addQuadCurve(to: curcgpoint,
                                   controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: curcgpoint))
            gradientLine.addQuadCurve(to: curcgpoint,
                                      controlPoint: CGPoint.controlPointForPoints(p1: mid, p2: curcgpoint))
            
            if Penalty(rawValue: cur.solve.penalty) == .dnf {
                dnfedIndices.append(i)
            }
        }
        
        let lastcgpoint = points.last!.getPointFor(interval: interval, imageHeight: padded_height + CHART_TOP_PADDING)
        let firstcgpoint = points.first!.getPointFor(interval: interval, imageHeight: padded_height + CHART_TOP_PADDING)
        
        gradientLine.addLine(to: CGPoint(x: lastcgpoint.x, y: padded_height + CHART_TOP_PADDING))
        gradientLine.addLine(to: CGPoint(x: 0, y: padded_height + CHART_TOP_PADDING))
        gradientLine.addLine(to: CGPoint(x: 0, y: firstcgpoint.y))
        
        gradientLine.close()
        
        gradientLine.addClip()
        
        context.drawLinearGradient(CGGradient(colorsSpace: .none,
                                              colors: [
                                                UIColor(GradientManager.STATIC_GRADIENT[0].opacity(0.6)).cgColor,
                                                UIColor(GradientManager.STATIC_GRADIENT[1].opacity(0.2)).cgColor,
                                                UIColor(GradientManager.STATIC_GRADIENT[1].opacity(0.01)).cgColor
                                              ] as CFArray,
                                              locations: [0.0, 0.4, 1.0])!,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: padded_height + CHART_TOP_PADDING),
                                   options: [])
        
        context.resetClip()
        
        trendLine.stroke()
        
        
        UIColor(Color("grey")).set()
        
        /// draw dnf crosses
        for i in dnfedIndices {
            let image = createDNFPoint()
            
            var cgpoint = points[i].getPointFor(interval: interval, imageHeight: padded_height)
            cgpoint.y += CHART_TOP_PADDING
            
            let imageRect = CGRect(x: cgpoint.x - 4, y: cgpoint.y - 4, width: 8, height: 8)
            
            context.clip(to: imageRect, mask: image.cgImage!)
            
            context.addRect(imageRect)
            context.drawPath(using: .fill)
            
            context.resetClip()
        }
    }
}


class TimeTrendViewController: UIViewController, UIScrollViewDelegate {
    var points: [TimeTrendPoint]
    var interval: Int {
        didSet {
            self.drawYAxisValues()
            self.scrollView.interval = interval
            recalculateScrollViewSize()
            self.scrollView.setNeedsDisplay()
        }
    }
    
    let stopwatchManager: StopwatchManager
    
    let averageValue: Double
    
    let limits: (min: Double, max: Double)
    
    var scrollView: TimeTrendLineChartScrollView!
    var highlightedPoint: TimeTrendHoverPointView!
    var highlightedCard: TimeTrendHoverCardView!
    
    var yAxis: UIView!
    
    var imageWidthConstraint: NSLayoutConstraint!
    
    var lastSelectedSolve: Solve!
    
    private let dotSize: CGFloat = 6
    
    init(stopwatchManager: StopwatchManager, points: [TimeTrendPoint], interval: Int, averageValue: Double, limits: (min: Double, max: Double)) {
        self.stopwatchManager = stopwatchManager
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
        
        self.scrollView = TimeTrendLineChartScrollView(frame: .zero, interval: interval, points: points)
        self.scrollView.showsHorizontalScrollIndicator = true
        
        self.view.clipsToBounds = true
        
        self.view.addSubview(scrollView)
        
        self.scrollView.frame = self.view.frame
        self.scrollView.isUserInteractionEnabled = true
        self.scrollView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(panning))
        longPressGestureRecognizer.minimumPressDuration = 0.25
        tapGestureRecognizer.require(toFail: longPressGestureRecognizer)
        
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        scrollView.addGestureRecognizer(longPressGestureRecognizer)
        
        
        self.highlightedPoint = TimeTrendHoverPointView(at: .zero)
        
        self.highlightedPoint.backgroundColor = .clear
        
        self.highlightedPoint.frame = CGRect(x: 0,
                                             y: 0,
                                             width: 12, height: 12)
        self.highlightedPoint.layer.opacity = 1
        
        self.scrollView.addSubview(self.highlightedPoint)
        self.scrollView.isUserInteractionEnabled = true
        
        
        self.highlightedCard = TimeTrendHoverCardView(solve: nil)
        let cardTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(solveCardTapped))
        self.highlightedCard.addGestureRecognizer(cardTapGestureRecognizer)
        self.highlightedCard.layer.opacity = 1
        
        self.scrollView.addSubview(self.highlightedCard)
        
        tapGestureRecognizer.shouldRequireFailure(of: cardTapGestureRecognizer)
        
        self.yAxis = drawYAxisValues()
        
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.yAxis.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        recalculateScrollViewSize()
        
    }
    
    func recalculateScrollViewSize() {
        self.scrollView.contentSize.width = CGFloat((points.count - 1) * interval)
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
        view.spacing = 4
        
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        
        for i in (0 ..< 6).reversed() {
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.adjustsFontSizeToFitWidth = true
            label.font = AXIS_LABEL_FONT
            label.textColor = UIColor(Color("grey"))
            
            label.text = formatSolveTime(secs: self.limits.min + Double(i) * range / Double(5), dp: 2)
            
            stackView.addArrangedSubview(label)
            
            label.sizeToFit()
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor(Color("indent0"))
        
        view.spacing = 6
        view.addArrangedSubview(lineView)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: CHART_TOP_PADDING),
            view.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -CHART_BOTTOM_PADDING),
            
            lineView.widthAnchor.constraint(equalToConstant: 0.5),
            lineView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: CHART_TOP_PADDING),
            lineView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -CHART_BOTTOM_PADDING)
        ])
        
        
        return view
    }
    
    func updateGap(interval: Int, points: [TimeTrendPoint]) {
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
        var closestCGPoint = closestPoint.getPointFor(interval: interval, imageHeight: self.scrollView.frame.height - CHART_TOP_PADDING - CHART_BOTTOM_PADDING)
        closestCGPoint.y += CHART_TOP_PADDING
        
        self.highlightedCard.updateLabel(with: closestPoint.solve)
        
        self.highlightedPoint.isRegular = Penalty(rawValue: closestPoint.solve.penalty) != .dnf
        
        self.highlightedPoint.frame.origin = CGPoint(x: closestCGPoint.x - 6, y: closestCGPoint.y - 6)
        
        
        self.lastSelectedSolve = closestPoint.solve
        
        self.highlightedCard.frame.origin = CGPoint(
            x: min(max(self.scrollView.contentOffset.x,
                       closestCGPoint.x - (self.highlightedCard.frame.width / 2)),
                   self.scrollView.frame.width - self.highlightedCard.frame.width + self.scrollView.contentOffset.x),
            y: closestCGPoint.y - 80)
        
        self.highlightedPoint.layer.opacity = 1
        self.highlightedCard.layer.opacity = 1
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        removeSelectedPoint(animated: false)
        scrollView.setNeedsDisplay()
    }
    
    @objc func solveCardTapped(_ g: UITapGestureRecognizer) {
        let solveSheet = UIHostingController(rootView: TimeDetailView(for: self.lastSelectedSolve, currentSolve: .constant(self.lastSelectedSolve)).environmentObject(stopwatchManager))
        
#warning("BUG: the toolbar doesn't display")
        self.present(solveSheet, animated: true, completion: { self.removeSelectedPoint() })
    }
}


struct TimeTrendViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = TimeTrendViewController
    
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    let points: [TimeTrendPoint]
    let interval: Int
    let averageValue: Double
    let proxy: GeometryProxy
    
    let limits: (min: Double, max: Double)
    
    init(rawDataPoints: [Solve], limits: (min: Double, max: Double), averageValue: Double, interval: Int, proxy: GeometryProxy) {
        self.points = rawDataPoints.enumerated().map({ (i, e) in
            return TimeTrendPoint(solve: e,
                                  idx: i,
                                  min: limits.min, max: limits.max)
        })
        self.averageValue = averageValue
        self.limits = limits
        self.interval = interval
        self.proxy = proxy
    }
    
    func makeUIViewController(context: Context) -> TimeTrendViewController {
        let timeDistViewController = TimeTrendViewController(stopwatchManager: stopwatchManager, points: points, interval: interval, averageValue: averageValue, limits: limits)
        
        return timeDistViewController
    }
    
    func updateUIViewController(_ uiViewController: TimeTrendViewController, context: Context) {
        uiViewController.updateGap(interval: interval, points: points)
    }
}
