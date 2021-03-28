import Foundation
import UIKit

class SendingHeaderReusableView: UICollectionReusableView {

    static let identifier = "SendingHeaderReusableView"

    lazy private var label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor(hexCode: "0C090A")
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureSubviews() {
        addSubview(label)
    }

    private func configureConstraints() {
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
        }
    }

    public func bind(_ text: String) {
        label.text = text
    }
}
