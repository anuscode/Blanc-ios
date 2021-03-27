import Foundation
import UIKit
import Lottie

class EmptyView: UIView {

    private var ripple: Ripple = Ripple()

    internal var animationSpeed: CGFloat = 1 {
        didSet {
            animationView.animationSpeed = animationSpeed
        }
    }

    internal var animationName: String = "girl_with_phone"

    internal var primaryText: String = "" {
        didSet {
            primaryLabel.text = primaryText
        }
    }

    internal var secondaryText: String = "" {
        didSet {
            secondaryLabel.text = secondaryText
        }
    }

    internal var buttonText: String = "" {
        didSet {
            buttonLabel.text = buttonText
        }
    }

    internal var didTapButtonDelegate: (() -> Void)?

    lazy private var contentView: UIView = {
        let view = UIView()
        return view
    }()

    lazy private var animationView: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named(animationName)
        animationView.loopMode = .loop
        animationView.animationSpeed = animationSpeed
        animationView.play()
        return animationView
    }()

    lazy private var primaryLabel: UILabel = {
        let label = UILabel()
        label.text = primaryText
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black4
        return label
    }()

    lazy private var secondaryLabel: UILabel = {
        let label = UILabel()
        label.text = secondaryText
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()

    lazy private var button: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.backgroundColor = .tinderPink
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapButton))

        view.addSubview(buttonLabel)
        buttonLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        ripple.activate(to: view)
        return view
    }()

    lazy private var buttonLabel: UILabel = {
        let label = UILabel()
        label.text = "메인 화면으로"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    required init(animationName: String, animationSpeed: CGFloat) {
        self.animationSpeed = animationSpeed
        self.animationName = animationName
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setup() {
        addSubview(contentView)
        contentView.addSubview(animationView)
        contentView.addSubview(primaryLabel)
        contentView.addSubview(secondaryLabel)
        contentView.addSubview(button)

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        animationView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(animationView.snp.width)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.65)
        }

        primaryLabel.snp.makeConstraints { make in
            make.bottom.equalTo(animationView.snp.bottom).inset(10)
            make.centerX.equalToSuperview()
        }

        secondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(primaryLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        button.snp.makeConstraints { make in
            make.top.equalTo(secondaryLabel.snp.bottom).offset(30)
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
    }

    func play() {
        animationView.play()
    }

    @objc private func didTapButton() {
        didTapButtonDelegate?()
    }
}