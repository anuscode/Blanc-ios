import Foundation
import UIKit
import RxSwift

class NotificationView: UIView {

    private var disposeBag: DisposeBag = DisposeBag()

    private var ripple: Ripple = Ripple()

    private var avatar: String?

    private var message: String?

    lazy private var rightTransform: CGAffineTransform = {
        CGAffineTransform(translationX: 0, y: 0)
    }()

    lazy private var leftTransform: CGAffineTransform = {
        CGAffineTransform(translationX: -fixedWidth, y: 0)
    }()

    lazy var fixedWidth: CGFloat = {
        let window = UIApplication.shared.keyWindow!
        let screenWidth = UIScreen.main.bounds.width
        let width = screenWidth * 0.85
        return CGFloat(width)
    }()

    lazy private var blanc: UIView = {
        let view = UIView()

        let blanc = UILabel()
        blanc.text = "블랑"
        blanc.font = .boldSystemFont(ofSize: 12)
        blanc.textColor = .black

        let dot = UILabel()
        dot.text = "."
        dot.textColor = .bumble4
        dot.font = .boldSystemFont(ofSize: 17)

        view.addSubview(blanc)
        view.addSubview(dot)

        blanc.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
        dot.snp.makeConstraints { make in
            make.leading.equalTo(blanc.snp.trailing)
            make.bottom.equalTo(blanc.snp.bottom).inset(-1)
            make.trailing.equalToSuperview()
        }

        return view
    }()

    lazy private var nowLabel: UILabel = {
        let label = UILabel()
        label.text = "지금"
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textColor = .darkText
        label.numberOfLines = 1
        return label
    }()

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 12.5
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.width(25)
        imageView.height(25)
        imageView.url(avatar, size: CGSize(width: 25, height: 25))
        return imageView
    }()

    lazy private var messageLabel: UILabel = {
        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textColor = .darkText
        label.numberOfLines = 2
        return label
    }()

    lazy private var closeButton: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "ic_close_black")
        imageView.width(20)
        imageView.height(20)
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(hide))
        ripple.activate(to: imageView)
        return imageView
    }()

    required init(imageUrl: String?, message: String?) {
        super.init(frame: .zero)
        self.avatar = imageUrl
        self.message = message

        backgroundColor = UIColor.systemGray5.withAlphaComponent(0.95)
        layer.cornerRadius = 10
        layer.masksToBounds = true
        transform = CGAffineTransform(translationX: -fixedWidth, y: 0)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func configureSubviews() {
        addSubview(blanc)
        addSubview(nowLabel)
        addSubview(imageView)
        addSubview(messageLabel)
        addSubview(closeButton)
    }

    private func configureConstraints() {
        blanc.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(15)
        }

        nowLabel.snp.makeConstraints { make in
            make.centerX.equalTo(closeButton.snp.centerX)
            make.centerY.equalTo(blanc.snp.centerY)
        }

        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.25)
            make.leading.equalToSuperview().inset(15)
        }

        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).inset(-10)
            make.centerY.equalTo(imageView.snp.centerY)
            make.trailing.equalTo(closeButton.snp.leading).inset(-10)
        }

        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalTo(imageView.snp.centerY)
        }
    }

    private func setup() {
        configureSubviews()
        configureConstraints()
    }

    func insert(into: UIWindow) {
        into.addSubview(self)

        var height = UIScreen.main.bounds.height
        height = height / 15

        self.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(into.safeAreaLayoutGuide).inset(height)
            make.width.equalTo(self.fixedWidth)
            make.height.equalTo(60)
        }
    }

    func show(hideAfter: Int = 4) {
        UIView.animate(withDuration: 0.4, animations: {
            self.visible(true)
            self.transform = self.rightTransform
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(hideAfter)) {
                self.hide()
            }
        })
    }

    @objc func hide() {
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = self.leftTransform
        }) { _ in
            self.visible(false)
            self.removeFromSuperview()
        }
    }
}
