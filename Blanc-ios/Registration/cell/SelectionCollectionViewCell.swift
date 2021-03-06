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

    private var checkmark: UIView = {
        let view = UIImageView()
        let image = UIImage(systemName: "checkmark")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        view.image = image
        view.visible(false)
        return view
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
        contentView.addSubview(checkmark)
    }

    private func configureConstraints() {
        subject.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        checkmark.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    func select(_ isSelected: Bool) {
        layer.borderWidth = isSelected ? 2 : 0
        layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.clear.cgColor
        checkmark.visible(isSelected)
    }
}