import CropViewController
import UIKit
import Firebase
import RxSwift
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import Kingfisher
import Lottie


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

    private func setConstraint(value: CGFloat, attribute: NSLayoutConstraint.Attribute, priority: Float? = nil) {
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
            single = single.flatMap({ [self]_ -> Single<Void> in
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

extension UIViewController {
    func toast(title: String? = nil, message: String?, seconds: Double = 1.5, callback: (() -> Void)? = nil) {
        DispatchQueue.main.async { [unowned self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.view.backgroundColor = .black
            alert.view.alpha = 0.5
            alert.view.layer.cornerRadius = 15
            present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
                alert.dismiss(animated: true)
                callback?()
            }
        }
    }
}

extension UIButton {
    func setImageLeftTextCenter(imagePadding: CGFloat = 30.0) {
        guard let imageViewWidth = imageView?.frame.width else {
            return
        }
        guard let titleLabelWidth = titleLabel?.intrinsicContentSize.width else {
            return
        }
        contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: imagePadding - imageViewWidth / 2, bottom: 0.0, right: 0.0)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - titleLabelWidth) / 2 - imageViewWidth, bottom: 0.0, right: 0.0)
    }
}

extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension UIColor {
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue = CGFloat(b) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        return String(format: "#%06x", rgb)
    }
}

extension Auth {
    public var uid: String? {
        return self.currentUser?.uid
    }
}

extension MDCOutlinedTextField {
    public func setColor(primary: UIColor, secondary: UIColor) {
        setOutlineColor(primary, for: .normal)
        setOutlineColor(primary, for: .editing)
        setNormalLabelColor(primary, for: .normal)
        setNormalLabelColor(primary, for: .editing)
        setFloatingLabelColor(primary, for: .normal)
        setFloatingLabelColor(primary, for: .editing)
        setTrailingAssistiveLabelColor(primary, for: .normal)
        setTrailingAssistiveLabelColor(primary, for: .editing)
        trailingView?.tintColor = primary
        setLeadingAssistiveLabelColor(secondary, for: .normal)
        setLeadingAssistiveLabelColor(secondary, for: .editing)
    }
}

extension UIImageView {

    public func url(_ url: String?, cornerRadius: CGFloat = 0.0, size: CGSize? = nil) {
        let url = URL(string: url ?? "")

        // TODO: it's hack. remove them later.
        var sizeTo: CGSize? = nil
        if bounds.size == .zero {
            sizeTo = (size != nil) ? size : CGSize(width: 300, height: 300)
        } else {
            sizeTo = bounds.size
        }

        let processor = DownsamplingImageProcessor(size: sizeTo!)
                |> RoundCornerImageProcessor(cornerRadius: cornerRadius)
        self.kf.indicatorType = .activity

        self.kf.setImage(
                with: url,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ], completionHandler: {
            result in
            switch result {
            case .success(let value):
                log.info("Task done for: \(value.source.url?.absoluteString ?? "") cacheType: \(value.cacheType)")
            case .failure(let error):
                self.image = nil
                log.error(error)
                log.error("Job failed: \(error.localizedDescription)")
            }
        })
    }
}

extension UILabel {
    func setMargins(margin: CGFloat = 10) {
        if let textString = self.text {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = margin
            paragraphStyle.headIndent = margin
            paragraphStyle.tailIndent = -margin
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}

extension AnimationView {
    @discardableResult
    func begin() -> Observable<Void> {
        let subject: ReplaySubject = ReplaySubject<Void>.create(bufferSize: 1)
        self.play(completion: { _ in
            self.removeFromSuperview()
            subject.onNext(Void())
        })
        return subject.take(1)
    }

    @discardableResult
    func begin(with v: UIView, constraint: () -> Void) -> Observable<Void> {
        v.addSubview(self)
        constraint()
        return self.begin()
    }
}

enum TextFieldPaddingDirection {
    case left, right
}

extension UITextField {
    func addPadding(direction: TextFieldPaddingDirection, width: Int) {
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: width, height: Int(frame.height)))
        if (direction == .left) {
            leftView = padding
            leftViewMode = ViewMode.always
        } else {
            rightView = padding
            rightViewMode = ViewMode.always
        }
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

    func applyShadow(color: UIColor, opacity: Float, radius: CGFloat, edge: AIEdge, shadowSpace: CGFloat) {

        var sizeOffset: CGSize = CGSize.zero
        switch edge {
        case .Top:
            sizeOffset = CGSize(width: 0, height: -shadowSpace)
        case .Left:
            sizeOffset = CGSize(width: -shadowSpace, height: 0)
        case .Bottom:
            sizeOffset = CGSize(width: 0, height: shadowSpace)
        case .Right:
            sizeOffset = CGSize(width: shadowSpace, height: 0)


        case .Top_Left:
            sizeOffset = CGSize(width: -shadowSpace, height: -shadowSpace)
        case .Top_Right:
            sizeOffset = CGSize(width: shadowSpace, height: -shadowSpace)
        case .Bottom_Left:
            sizeOffset = CGSize(width: -shadowSpace, height: shadowSpace)
        case .Bottom_Right:
            sizeOffset = CGSize(width: shadowSpace, height: shadowSpace)


        case .All:
            sizeOffset = CGSize(width: 0, height: 0)
        case .None:
            sizeOffset = CGSize.zero
        }

        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.masksToBounds = true;

        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = sizeOffset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false

        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
    }
}

enum AIEdge: Int {
    case
            Top,
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

extension CropViewController {
    static func getCropViewController(delegate: CropViewControllerDelegate, image: UIImage) -> CropViewController {
        let cropViewController = CropViewController(croppingStyle: CropViewCroppingStyle.default, image: image)
        cropViewController.modalPresentationStyle = .fullScreen
        cropViewController.delegate = delegate
        cropViewController.title = "이미지 영역을 선택 하세요."
        cropViewController.aspectRatioPreset = .presetSquare; // Set the initial aspect ratio as a square
        cropViewController.aspectRatioLockEnabled = true  // The crop box is locked to the aspect ratio and can't be resized away from it
        cropViewController.resetAspectRatioEnabled = false  // When tapping 'reset', the aspect ratio will NOT be reset back to default
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.rotateButtonsHidden = true
        cropViewController.rotateClockwiseButtonHidden = true
        cropViewController.doneButtonTitle = "확인"
        cropViewController.cancelButtonTitle = "취소"
        return cropViewController
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func compress(to kb: Int, allowedMargin: CGFloat = 0.2) -> Data {
        let bytes = kb * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        while (!complete) {
            if let data = holderImage.jpegData(compressionQuality: 1.0) {
                let ratio = data.count / bytes
                if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                    complete = true
                    return data
                } else {
                    let multiplier: CGFloat = CGFloat((ratio / 5) + 1)
                    compression -= (step * multiplier)
                }
            }

            guard let newImage = holderImage.resized(withPercentage: compression) else {
                break
            }
            holderImage = newImage
        }
        return Data()
    }

    static func resize(image: UIImage, maxKb: Int, completion: @escaping (UIImage?) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let currentImageSize = image.jpegData(compressionQuality: 1.0)?.count else {
                return completion(nil)
            }

            var imageSize = currentImageSize
            var percentage: CGFloat = 1.0
            var generatedImage: UIImage? = image
            let percentageDecrease: CGFloat = 0.1

            while imageSize > (maxKb * 1024) {
                let canvas = CGSize(width: image.size.width * percentage, height: image.size.height * percentage)
                let format = image.imageRendererFormat
                format.opaque = true
                generatedImage = UIGraphicsImageRenderer(size: canvas, format: format).image { _ in
                    image.draw(in: CGRect(origin: .zero, size: canvas))
                }
                guard let generatedImageSize = generatedImage?.jpegData(compressionQuality: 1.0)?.count else {
                    return completion(nil)
                }
                imageSize = generatedImageSize
                log.info("compressing.. current size: \(generatedImageSize / 1024) kb")
                percentage -= percentageDecrease
            }

            guard let generatedImageSize = generatedImage?.jpegData(compressionQuality: 1.0)?.count else {
                return completion(nil)
            }
            log.info("resized to: \(generatedImageSize / 1024) kb")

            completion(generatedImage)
        }
    }
}

public extension Optional where Wrapped == String {
    func isEmpty() -> Bool {
        if (self == nil) {
            return true
        }
        return (self! as String).isEmpty
    }

    func isNotEmpty() -> Bool {
        !isEmpty()
    }
}

extension UINavigationController {
    func pushUserSingleViewController(current: UIViewController) {
        DispatchQueue.main.async { [unowned self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "UserSingleViewController")
            vc.modalPresentationStyle = .fullScreen
            current.hidesBottomBarWhenPushed = true
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = ""
            backBarButtonItem.tintColor = .black
            current.navigationItem.backBarButtonItem = backBarButtonItem
            pushViewController(vc, animated: true)
            current.hidesBottomBarWhenPushed = false
        }
    }

    func pushPostSingleViewController(current: UIViewController) {
        DispatchQueue.main.async { [unowned self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PostSingleViewController")
            vc.modalPresentationStyle = .fullScreen
            current.hidesBottomBarWhenPushed = true
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = ""
            backBarButtonItem.tintColor = .black
            current.navigationItem.backBarButtonItem = backBarButtonItem
            pushViewController(vc, animated: true)
            current.hidesBottomBarWhenPushed = false
        }
    }

    func pushAlarmViewController(current: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AlarmViewController")
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        backBarButtonItem.tintColor = .black
        current.navigationItem.backBarButtonItem = backBarButtonItem
        current.hidesBottomBarWhenPushed = true
        pushViewController(vc, animated: true)
        current.hidesBottomBarWhenPushed = false
    }
}

extension Array where Element == UserDTO {
    func distance(_ user: UserDTO?) {
        forEach {
            $0.distance = $0.distance(from: user, type: String.self)
        }
    }

    func distance(_ session: Session) {
        distance(session.user)
    }
}

extension UIViewController {
    func replace(
            storyboard: String = "Main",
            bundle: Bundle? = nil,
            withIdentifier: String,
            animated: Bool = true,
            modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
            completion: (() -> Void)? = nil
    ) {
        log.info("presenting \(withIdentifier)..")
        let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: withIdentifier)
        nextViewController.modalPresentationStyle = modalPresentationStyle
        dismiss(animated: false) {
            let window = UIApplication.shared.windows.first
            window?.rootViewController?.present(nextViewController, animated: animated, completion: completion)
        }
    }
}