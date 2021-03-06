import Foundation
import UIKit

class SelectionCollectionViewCell: UICollectionViewCell {

    static let identifier = "SelectionCollectionViewCell"

    private let ripple: Ripple = Ripple()

    var subject: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        select(false)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSelf()
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func configureSelf() {
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = .secondarySystemBackground
        isUserInteractionEnabled = true
        ripple.activate(to: self)
    }

    private func configureSubviews() {
        contentView.addSubview(subject)
    }

    private func configureConstraints() {
        subject.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func select(_ isSelected: Bool) {
        layer.borderWidth = isSelected ? 2 : 0
        layer.borderColor = isSelected ? UIColor.tinderPink.cgColor : UIColor.clear.cgColor
    }
}