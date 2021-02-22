import Foundation
import UIKit

class PostCollectionViewCell: UICollectionViewCell {

    static let identifier = "PostCollectionViewCell"

    private var post: PostDTO?

    lazy private var fixedDimension = {
        UIScreen.main.bounds.size.width / 3
    }()

    let ripple: Ripple = Ripple()

    lazy private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var userImageView: GradientCircleImageView = {
        let imageView = GradientCircleImageView(diameter: fixedDimension / 3)
        return imageView
    }()

    lazy internal var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: UIFont.Weight.thin)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
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
        contentView.isUserInteractionEnabled = true
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        accessibilityLabel = "User post image"
        ripple.activate(to: contentView)
    }

    private func configureSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(userImageView)
        contentView.addSubview(descriptionLabel)
    }

    private func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        userImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.7)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.top.equalTo(userImageView.snp.bottom).inset(-10)
        }
    }

    public func bind(_ post: PostDTO, isLargeScale: Bool = false) {
        self.post = post

        let resource = self.post?.resources?.first
        let contentDimension = fixedDimension * (isLargeScale ? 2 : 1)
        print(contentDimension)
        let contentSize = CGSize(width: contentDimension, height: contentDimension)
        imageView.url(resource?.url, size: contentSize)

        let authorImageUrl = post.author?.avatar
        userImageView.url(authorImageUrl)
        descriptionLabel.text = post.description

        let hasResource = (self.post?.resources?.count ?? 0) > 0
        imageView.visible(hasResource)
        userImageView.visible(!hasResource)
        descriptionLabel.visible(!hasResource)
    }
}