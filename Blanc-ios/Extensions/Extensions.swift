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
import SnapKit

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
    func begin(with v: UIView, constraint: (_ make: ConstraintMaker) -> Void) -> Observable<Void> {
        v.addSubview(self)
        self.snp.makeConstraints(constraint)
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

    static func resize(image: UIImage, maxKb: Int = 1000, completion: @escaping (UIImage?) -> ()) {
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

extension UIBarButtonItem {
    static let back: UIBarButtonItem = {
        let item = UIBarButtonItem()
        item.title = ""
        item.tintColor = .black
        return item
    }()
}

extension UILabel {
    func underline() {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: text ?? "", attributes: underlineAttribute)
        attributedText = underlineAttributedString
    }
}

extension NSMutableAttributedString {
    var fontSize: CGFloat {
        return 14
    }
    var boldFont: UIFont {
        return UIFont.boldSystemFont(ofSize: fontSize)
    }

    var semiboldFont: UIFont {
        return UIFont.systemFont(ofSize: fontSize, weight: .semibold)
    }

    var normalFont: UIFont {
        return UIFont.systemFont(ofSize: fontSize)
    }

    func semibold(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: semiboldFont
        ]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func bold(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func normal(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
        ]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    /* Other styling methods */
    func orangeHighlight(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.orange
        ]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func blackHighlight(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black

        ]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func underlined(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: normalFont,
            .underlineStyle: NSUnderlineStyle.single.rawValue

        ]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
}