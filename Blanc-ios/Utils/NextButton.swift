import Foundation
import UIKit

class NextButton: UIView {

    private let ripple: Ripple = Ripple()

    lazy private var forwardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_ios_forward_black")
        return imageView
    }()

    public override var intrinsicContentSize: CGSize {
        CGSize(width: 60, height: 60)
    }

    required init() {
        super.init(frame: .zero)
        layer.cornerRadius = 30
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
            make.center.equalToSuperview()
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        ripple.activate(to: self)
    }
}


