import Foundation
import UIKit

let checkboxUIImage = UIImage(systemName: "checkmark.circle.fill")!

class TimeCardView: UIStackView {
    let checkbox = UIImageView(image: checkboxUIImage)
    
//    private let gradientBorderLayer = CAGradientLayer()
//    private let borderLayer = CAShapeLayer()
    
    required init(coder: NSCoder) {
        fatalError("error")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCheckbox()
//        setupGradient()

        self.axis = .vertical
        self.alignment = .center
        self.distribution = .equalCentering
        self.spacing = 0
        
        self.addArrangedSubview(UIView())
        self.addArrangedSubview(checkbox)
        self.addArrangedSubview(UIView())
    }
    
    private func setupCheckbox() {
        checkbox.contentMode = .scaleAspectFit
        checkbox.isHidden = true
        
        var config = UIImage.SymbolConfiguration(paletteColors: [UIColor(named: "accent")!, UIColor(named: "overlay0")!])
        config = config.applying(UIImage.SymbolConfiguration(weight: .semibold))
        checkbox.preferredSymbolConfiguration = config
        checkbox.layer.shadowColor = UIColor.black.cgColor
        checkbox.layer.shadowOffset = .init(width: 0, height: 2)
        checkbox.layer.shadowRadius = 8
        checkbox.layer.shadowOpacity = 0.12
    }
    
//    private func setupGradient() {
//        gradientBorderLayer.colors = [
//            UIColor.systemRed.cgColor,
//            UIColor.systemBlue.cgColor
//        ]
//        gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientBorderLayer.endPoint = CGPoint(x: 1, y: 1)
//        gradientBorderLayer.cornerRadius = 8
//        gradientBorderLayer.mask = borderLayer
//        
//        layer.insertSublayer(gradientBorderLayer, at: 0)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        gradientBorderLayer.frame = bounds
//        borderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 8).cgPath
//        borderLayer.lineWidth = 5
//        borderLayer.fillColor = UIColor.clear.cgColor
//        borderLayer.strokeColor = UIColor.black.cgColor
//    }
}


class TimeCardLabel: UILabel {
    required init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.width += 8
            return contentSize
        }
    }
}
