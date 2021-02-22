import Foundation
import UIKit

class BackButton: UIView {

    private let ripple: Ripple = Ripple()

    lazy private var forwardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_ios_back_black")
        return imageView
    }()

    public override var intrinsicContentSize: CGSize {
        CGSize(width: 45, height: 45)
    }

    required init() {
        super.init(frame: .zero)
        layer.cornerRadius = 45 / 2
        layer.masksToBounds = true
        backgroundColor = .white
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setup() {
        addSubview(forwardImageView)
        forwardImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.1)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        ripple.activate(to: self)
    }
}


