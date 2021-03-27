import Foundation
import UIKit

protocol PostCreateResourceCollectionViewCellDelegate {
    func delete(image: UIImage?)
}

class AddResourceCollectionViewCell: UICollectionViewCell {

    static let identifier = "PostCreateResourceCollectionViewCell"

    lazy private var cellWidth = {
        (UIScreen.main.bounds.size.width * 0.8 / 3) - 2
    }()

    private let ripple: Ripple = Ripple()

    private var delegate: PostCreateResourceCollectionViewCellDelegate?

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        ripple.activate(to: imageView)
        return imageView
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
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
        contentView.layer.cornerRadius = 10
        contentView.isUserInteractionEnabled = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapCell))
        accessibilityLabel = "User post image"
        ripple.activate(to: contentView)
    }

    private func configureSubviews() {
        contentView.addSubview(imageView)
    }

    private func configureConstraints() {
        imageView.frame = contentView.bounds
    }

    public func bind(_ image: UIImage?, delegate: PostCreateResourceCollectionViewCellDelegate) {
        imageView.image = image
        self.delegate = delegate
    }

    @objc private func didTapCell() {
        delegate?.delete(image: imageView.image)
    }
}