import Foundation
import UIKit

protocol PostCreateAddCollectionViewCellDelegate {
    func addImage()
}

class AddCollectionViewCell: UICollectionViewCell {

    static let identifier = "AddCollectionViewCell"

    private var post: PostDTO?

    private var delegate: PostCreateAddCollectionViewCellDelegate?

    private let ripple: Ripple = Ripple()

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(systemName: "plus")
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
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }

    func bind(delegate: PostCreateAddCollectionViewCellDelegate) {
        self.delegate = delegate
    }

    @objc private func didTapCell() {
        delegate?.addImage()
    }
}