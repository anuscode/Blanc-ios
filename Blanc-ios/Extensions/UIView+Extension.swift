import Foundation
import UIKit
import RxSwift

extension UIView {

    public var width: CGFloat {
        frame.size.width
    }

    public var height: CGFloat {
        frame.size.height
    }

    public var top: CGFloat {
        frame.origin.y
    }

    public var bottom: CGFloat {
        frame.origin.y + frame.size.height
    }

    public var left: CGFloat {
        frame.origin.x
    }

    public var right: CGFloat {
        frame.origin.x + frame.size.width
    }

    public func alignCenter(parent: UIView) {
        center.x = parent.center.x
    }

    @objc public func visible(_ flag: Bool) {
        isHidden = !flag
    }
}

extension UIView {

    func setX(_ x: CGFloat) {
        var frame: CGRect = self.frame
        frame.origin.x = x
        self.frame = frame
    }

    func setY(_ y: CGFloat) {
        var frame: CGRect = self.frame
        frame.origin.y = y
        self.frame = frame
    }

    func setWidth(_ width: CGFloat) {
        var frame: CGRect = self.frame
        frame.size.width = width
        self.frame = frame
    }

    func setHeight(_ height: CGFloat) {
        var frame: CGRect = self.frame
        frame.size.height = height
        self.frame = frame
    }
}

extension UIView {

    @discardableResult
    func width(_ constant: CGFloat, priority: Float? = nil) -> UIView {
        setConstraint(value: constant, attribute: .width, priority: priority)
        return self
    }

    @discardableResult
    func height(_ constant: CGFloat, priority: Float? = nil) -> UIView {
        setConstraint(value: constant, attribute: .height, priority: priority)
        return self
    }

    func removeConstraint(attribute: NSLayoutConstraint.Attribute) {
        constraints.forEach {
            if $0.firstAttribute == attribute {
                removeConstraint($0)
            }
        }
    }

    private func setConstraint(value: CGFloat,
                               attribute: NSLayoutConstraint.Attribute,
                               priority: Float? = nil) {

        removeConstraint(attribute: attribute)
        let constraint = NSLayoutConstraint(
            item: self, attribute: attribute, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: value)
        constraint.priority = UILayoutPriority(rawValue: priority ?? 999)
        addConstraint(constraint)
    }
}

extension UIView {

    private func bounce(withDuration: Double = 0.25,
                        delay: Double = 0.0,
                        options: UIView.AnimationOptions = .curveEaseIn) -> Single<Void> {

        let subject: ReplaySubject = ReplaySubject<Void>.create(bufferSize: 1)
        UIView.animate(withDuration: withDuration, delay: delay, options: options, animations: {
            self.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
        }) { finished in
            UIView.animate(withDuration: withDuration * 2, delay: delay, options: options, animations: {
                self.transform = CGAffineTransform.identity.scaledBy(x: 2, y: 2)
            }) { finished in
                subject.onNext(Void())
            }
        }
        return subject.take(1).asSingle()
    }

    public func bounce(count: Int,
                       withDuration: Double = 0.25,
                       delay: Double = 0.0,
                       options: UIView.AnimationOptions = .curveLinear) {

        var single = Single.just(Void())
        for _ in 1...count {
            single = single.flatMap({ [unowned self]_ -> Single<Void> in
                self.bounce(withDuration: withDuration, delay: delay, options: options)
            })
        }
        single.subscribe()
    }
}

extension UIView {

    func addTapGesture(numberOfTapsRequired: Int, target: Any, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = numberOfTapsRequired
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
}

extension UIView {

    func rotate(withDuration: Int, infinite: Bool = false) {
        UIView.animate(
            withDuration: TimeInterval(withDuration),
            delay: 0,
            options: UIView.AnimationOptions.curveLinear,
            animations: { () -> Void in
                self.transform = self.transform.rotated(by: .pi / 2)
            }) { (finished) -> Void in
            if finished && infinite {
                self.rotate(withDuration: withDuration, infinite: infinite)
            }
        }
    }
}

extension UIView {

    func squircle(_ cornerRadius: CGFloat) {
        let mask = CAShapeLayer()
        mask.frame = bounds
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.mask = mask
    }

    func applyShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor = backgroundCGColor
    }
}

enum AIEdge {
    case Top,
         Left,
         Bottom,
         Right,
         Top_Left,
         Top_Right,
         Bottom_Left,
         Bottom_Right,
         All,
         None
}
