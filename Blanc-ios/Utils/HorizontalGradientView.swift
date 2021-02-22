import UIKit

@IBDesignable
public class HorizontalGradientView: UIView {

    let gradient: CAGradientLayer

    init(gradient: CAGradientLayer) {
        self.gradient = gradient
        super.init(frame: .zero)
        self.gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        layer.insertSublayer(self.gradient, at: 0)
    }

    convenience init(colors: [UIColor], locations: [Float] = [0.0, 1.0]) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map {
            $0.cgColor
        }
        gradient.locations = locations.map {
            NSNumber(value: $0)
        }
        self.init(gradient: gradient)
    }

    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = bounds
    }

    required init?(coder: NSCoder) {
        fatalError("no init(coder:)")
    }
}