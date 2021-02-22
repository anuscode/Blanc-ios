import UIKit

@IBDesignable
public class GradientView: UIView {

    let gradient: CAGradientLayer

    init(gradient: CAGradientLayer) {
        self.gradient = gradient
        super.init(frame: .zero)
        self.gradient.frame = bounds
        layer.insertSublayer(self.gradient, at: 0)
    }

    convenience init(colors: [UIColor], locations: [Float] = [0.0, 1.0],
                     startPoint: CGPoint? = nil, endPoint: CGPoint? = nil
    ) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map {
            $0.cgColor
        }
        gradient.locations = locations.map {
            NSNumber(value: $0)
        }
        if (startPoint != nil) {
            gradient.startPoint = startPoint!
        }
        if (endPoint != nil) {
            gradient.endPoint = endPoint!
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