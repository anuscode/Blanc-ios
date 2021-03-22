import Foundation
import UIKit

public class Gradient45View: UIView {

    private let gradient: CAGradientLayer

    init(gradient: CAGradientLayer) {
        self.gradient = gradient
        super.init(frame: .zero)
        self.gradient.frame = bounds
        layer.insertSublayer(self.gradient, at: 0)
    }

    convenience init(colors: [UIColor]) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map {
            $0.cgColor
        }
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 0)
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

class AlarmTableViewCell: UITableViewCell {

    static var identifier: String = "AlarmTableViewCell"

    let ripple: Ripple = Ripple()

    private weak var push: PushDTO?

    private weak var user: UserDTO?

    private let inset = CGFloat(2)

    private class Const {
        static let imageDiameter: CGFloat = CGFloat(50)
    }

    lazy private var gradation: Gradient45View = {
        let view = Gradient45View(colors: [.bumble3, .purple])

        view.layer.cornerRadius = ((Const.imageDiameter + (inset) * 2)) / 2
        view.layer.masksToBounds = true
        view.width(Const.imageDiameter + (inset * 2))
        view.height(Const.imageDiameter + (inset * 2))

        let white = UIView()
        white.backgroundColor = .white
        white.layer.cornerRadius = Const.imageDiameter / 2
        white.layer.masksToBounds = true

        view.addSubview(white)

        view.addSubview(userImage)

        white.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Const.imageDiameter)
            make.height.equalTo(Const.imageDiameter)
        }

        userImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(Const.imageDiameter - CGFloat(inset * 2))
            make.height.equalTo(Const.imageDiameter - CGFloat(inset * 2))
        }
        return view
    }()

    lazy private var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.width(Const.imageDiameter)
        imageView.height(Const.imageDiameter)
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = (Const.imageDiameter - CGFloat(inset * 2)) / 2
        return imageView
    }()

    lazy private var line: UIView = {
        let view = UIView()
        view.addSubview(line1)
        view.addSubview(line2)
        line1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        line2.snp.makeConstraints { make in
            make.top.equalTo(line1.snp.bottom).inset(-5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        return view
    }()

    lazy private var line1: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()

    lazy private var line2: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 12)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSelf()
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configureSelf() {
        selectionStyle = UITableViewCell.SelectionStyle.none
        contentView.isUserInteractionEnabled = true
        ripple.activate(to: contentView)
    }

    private func configureSubviews() {
        contentView.addSubview(gradation)
        contentView.addSubview(line)
    }

    private func configureConstraints() {

        gradation.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(7.5)
            make.leading.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview().inset(7.5)
        }

        line.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).inset(-10)
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
    }

    func bind(push: PushDTO?) {
        self.push = push
        let diameter = Const.imageDiameter
        userImage.url(push?.imageUrl, cornerRadius: 0, size: CGSize(width: diameter, height: diameter))
        line1.text = "\(push?.message ?? "ERROR")"
        line2.text = "\(push?.createdAt.asStaledTime() ?? "알 수 없음")"
    }
}
