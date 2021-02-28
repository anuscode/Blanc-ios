import Foundation
import UIKit
import Lottie

class InAppPurchaseTableViewCell: UITableViewCell {

    static var identifier: String = "InAppPurchaseTableViewCell"

    private let ripple = Ripple()

    lazy private var pointView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .tinderPink

        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.text = "P"
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, discountLabel
        ])
        stackView.setCustomSpacing(5, after: titleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    lazy private var titleLabel: UILabel = {
        let point = UILabel()
        point.textColor = .customBlack3
        point.font = .systemFont(ofSize: 16, weight: .semibold)
        point.text = "포인트 80"
        return point
    }()

    lazy private var discountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .tinderPink
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.text = "약 500원 할인"
        return label
    }()

    lazy private var tagView: UIView = {
        let view = UIView()

        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(hexCode: "f6eef9")
        view.addSubview(tagLabel)

        tagLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }

        return view
    }()

    lazy private var favoriteLottie: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("bad_emoji")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.play()
        return animationView
    }()

    lazy private var tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexCode: "a757d9")
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.text = "이 상품이 가장 적절 합니다. 👍"
        label.textAlignment = .center
        return label
    }()

    lazy private var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hexCode: "A0A0B0")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "₩11,000"
        label.textAlignment = .center
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
        selectionStyle = .none
        ripple.activate(to: contentView)
    }

    private func configureSubviews() {
        contentView.addSubview(pointView)
        contentView.addSubview(stackView)
        contentView.addSubview(priceLabel)
    }

    private func configureConstraints() {
        pointView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(25)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.leading.equalTo(pointView.snp.trailing).inset(-10)
        }

        priceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(pointView.snp.centerY).multipliedBy(0.98)
            make.trailing.equalToSuperview().inset(20)
        }
    }

    func bind(_ product: Product) {
        titleLabel.text = product.title
        discountLabel.text = product.discount
        priceLabel.text = product.price
        if (product.tag.isNotEmpty()) {
            tagLabel.text = product.tag!
            stackView.addArrangedSubview(tagView)
            stackView.setCustomSpacing(10, after: discountLabel)
        }
    }
}