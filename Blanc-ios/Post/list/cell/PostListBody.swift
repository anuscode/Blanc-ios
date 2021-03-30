import Foundation
import UIKit
import FSPagerView

private extension UIView {
    func image(_ url: String?) {
        if let imageView: UIImageView = subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            imageView.url(url ?? "")
        }
    }
}

class PostListBody: UIView {

    private let ripple = Ripple()

    private weak var post: PostDTO?

    private weak var delegate: PostBodyDelegate?

    private let horizontalMargin: CGFloat = 15

    lazy private var imageContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            image1Container,
            image2Container,
            image3Container
        ])
        stackView.axis = .vertical
        return stackView
    }()

    lazy private var image1Container: UIView = {
        let view = UIView()
        let width = (UIScreen.main.bounds.size.width - (horizontalMargin * 2))
        view.width(width, priority: 800)
        view.height(width, priority: 800)

        view.addSubview(image1_1)

        image1_1.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var image2Container: UIView = {
        let view = UIView()
        let width = (UIScreen.main.bounds.size.width - 2 * horizontalMargin)
        let height = (UIScreen.main.bounds.size.width - (horizontalMargin * 2.5)) / 2
        view.width(width, priority: 800)
        view.height(height, priority: 800)

        view.addSubview(image2_1)
        view.addSubview(image2_2)

        image2_1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        image2_2.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        return view
    }()

    lazy private var image3Container: UIView = {
        let view = UIView()
        let width = (UIScreen.main.bounds.size.width - (horizontalMargin * 2))
        let height = (width - horizontalMargin) / 3
        view.width(width, priority: 800)
        view.height(height, priority: 800)

        view.addSubview(image3_1)
        view.addSubview(image3_2)
        view.addSubview(image3_3)

        image3_1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        image3_2.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(image3_1.snp.trailing).inset(-horizontalMargin / 2)
        }
        image3_3.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(image3_2.snp.trailing).inset(-horizontalMargin / 2)
        }
        return view
    }()

//    lazy private var imageContainer: UIView = {
//        let view = UIView()
//        view.width(UIScreen.main.bounds.size.width, priority: 800)
//        view.height(UIScreen.main.bounds.size.width, priority: 800)
//
//        view.addSubview(image1_1)
//        view.addSubview(image2_1)
//        view.addSubview(image2_2)
//        view.addSubview(image3_1)
//        view.addSubview(image3_2)
//        view.addSubview(image3_3)
//
//        image1_1.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//
//        image2_1.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.leading.equalToSuperview()
//        }
//        image2_2.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
//            make.trailing.equalToSuperview()
//        }
//
//        image3_1.snp.makeConstraints { make in
//            make.top.equalToSuperview()
//            make.centerX.equalToSuperview()
//        }
//        image3_2.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().inset(30)
//            make.leading.equalToSuperview()
//        }
//        image3_3.snp.makeConstraints { make in
//            make.bottom.equalToSuperview()
//            make.trailing.equalToSuperview()
//        }
//
//        return view
//    }()

    lazy private var image1_1: UIView = {
        let view = UIView()
        let width = UIScreen.main.bounds.size.width - (horizontalMargin * 2)
        view.width(width, priority: 800)
        view.height(width, priority: 800)
        view.applyShadow(
            offset: CGSize.init(width: 0, height: 3),
            color: UIColor.black,
            radius: 2.0,
            opacity: 0.35
        )
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.width(width, priority: 800)
        imageView.height(width, priority: 800)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var image2_1: UIView = {
        let view = UIView()
        let diameter = (UIScreen.main.bounds.size.width - (horizontalMargin * 2.5)) / 2
        view.width(diameter, priority: 800)
        view.height(diameter, priority: 800)
        view.applyShadow(
            offset: CGSize.init(width: 0, height: 3),
            color: UIColor.black,
            radius: 2.0,
            opacity: 0.35
        )
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.width(diameter, priority: 800)
        imageView.height(diameter, priority: 800)
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapImage2_1))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var image2_2: UIView = {
        let view = UIView()
        let diameter = (UIScreen.main.bounds.size.width - (horizontalMargin * 2.5)) / 2
        view.width(diameter, priority: 800)
        view.height(diameter, priority: 800)
        view.applyShadow(
            offset: CGSize.init(width: 0, height: 3),
            color: UIColor.black,
            radius: 2.0,
            opacity: 0.35
        )
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.width(diameter, priority: 800)
        imageView.height(diameter, priority: 800)
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapImage2_2))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var image3_1: UIView = {
        let view = UIView()
        let width = (UIScreen.main.bounds.size.width - (horizontalMargin * 2))
        let diameter = (width - horizontalMargin) / 3
        view.width(diameter, priority: 800)
        view.height(diameter, priority: 800)
        view.applyShadow(
            offset: CGSize.init(width: 0, height: 3),
            color: UIColor.black,
            radius: 2.0,
            opacity: 0.35
        )
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.width(diameter, priority: 800)
        imageView.height(diameter, priority: 800)
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapImage3_1))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var image3_2: UIView = {
        let view = UIView()
        let width = (UIScreen.main.bounds.size.width - (horizontalMargin * 2))
        let diameter = (width - horizontalMargin) / 3
        view.width(diameter, priority: 800)
        view.height(diameter, priority: 800)
        view.applyShadow(
            offset: CGSize.init(width: 0, height: 3),
            color: UIColor.black,
            radius: 2.0,
            opacity: 0.35
        )
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.width(diameter, priority: 800)
        imageView.height(diameter, priority: 800)
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapImage3_2))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var image3_3: UIView = {
        let view = UIView()
        let width = (UIScreen.main.bounds.size.width - (horizontalMargin * 2))
        let diameter = (width - horizontalMargin) / 3
        view.width(diameter, priority: 800)
        view.height(diameter, priority: 800)
        view.applyShadow(
            offset: CGSize.init(width: 0, height: 3),
            color: UIColor.black,
            radius: 2.0,
            opacity: 0.35
        )
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.width(diameter, priority: 800)
        imageView.height(diameter, priority: 800)
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapImage3_3))
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    lazy private var textsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            favoriteUserCountLabel,
            descriptionLabel,
            commentCountLabel,
            lastCommentLabel
        ])
        let spacing = CGFloat(PostConfig.textVerticalMargin)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.setCustomSpacing(spacing, after: favoriteUserCountLabel)
        stackView.setCustomSpacing(spacing, after: descriptionLabel)
        stackView.setCustomSpacing(spacing, after: commentCountLabel)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(
            top: 0, left: CGFloat(PostConfig.textHorizontalMargin),
            bottom: 0, right: CGFloat(PostConfig.textHorizontalMargin))
        return stackView
    }()

    lazy private var favoriteUserCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PostConfig.favoriteUserCountFontSize, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private(set) var lastCommentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PostConfig.lastCommentFontSize)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private(set) var commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PostConfig.commentCountFontSize)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapCommentCountLabel))
        return label
    }()

    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PostConfig.descriptionFontSize)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var heartView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.isUserInteractionEnabled = true
        view.addSubview(heartImageView)
        view.translatesAutoresizingMaskIntoConstraints = false
        heartImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(PostConfig.imageDiameter)
            make.height.equalTo(PostConfig.imageDiameter)
        }
        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapHeartImageView))
        return view
    }()

    lazy private var heartImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_heart_red")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy private var redHeartImage: UIImage? = {
        UIImage(named: "ic_heart_red")
    }()

    lazy private var emptyHeartImage: UIImage? = {
        UIImage(named: "ic_heart_empty")
    }()

    lazy private(set) var conversationView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.isUserInteractionEnabled = true
        view.addSubview(conversationImageView)
        view.translatesAutoresizingMaskIntoConstraints = false
        conversationImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(PostConfig.imageDiameter - 2)
            make.height.equalTo(PostConfig.imageDiameter - 2)
        }
        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapConversationImageView))
        return view
    }()

    lazy private var conversationImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_conversation")
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configureSubviews() {
        addSubview(imageContainerStackView)
        addSubview(heartView)
        addSubview(conversationView)
        addSubview(textsStackView)
    }

    private func configureConstraints() {
        imageContainerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(horizontalMargin)
            make.trailing.equalToSuperview().inset(horizontalMargin)
        }
        heartView.snp.makeConstraints { make in
            make.top.equalTo(imageContainerStackView.snp.bottom).inset(-8)
            make.leading.equalToSuperview().inset(12)
            make.width.equalTo(PostConfig.containerDiameter)
            make.height.equalTo(PostConfig.containerDiameter)
        }
        conversationView.snp.makeConstraints { make in
            make.top.equalTo(imageContainerStackView.snp.bottom).inset(-8)
            make.leading.equalTo(heartView.snp.trailing).inset(-8)
            make.width.equalTo(PostConfig.containerDiameter)
            make.height.equalTo(PostConfig.containerDiameter)
        }
        textsStackView.snp.makeConstraints { make in
            make.top.equalTo(heartImageView.snp.bottom).inset(-10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }

    func bind(post: PostDTO?, delegate: PostBodyDelegate?) {
        self.post = post
        self.delegate = delegate

        configureLastCommentLabel()
        configureDescriptionLabel()
        configureFavoriteUserCountLabel()
        configureCommentCountLabel()
        configureHeartImage()
        configureCarousel()
    }

    private func configureFavoriteUserCountLabel() {
        let text = "좋아요 \(post?.favoriteUserIds?.count ?? 0)개"
        favoriteUserCountLabel.text = text
    }

    private func configureDescriptionLabel() {
        let isNotEmpty = post?.description != nil && post?.description?.isEmpty != true
        descriptionLabel.text = isNotEmpty ? "\(post?.description ?? "")" : "..."
    }

    private func configureLastCommentLabel() {
        if let lastComment = post?.comments?.first {
            let nickname = "\(lastComment.commenter?.nickname ?? "알 수 없음"): "
            let comment = "\(lastComment.comment ?? "알 수 없음.")"
            let attributedText = NSMutableAttributedString().semibold(nickname).normal(comment)
            lastCommentLabel.attributedText = attributedText
        } else {
            let nickname = "#: "
            let comment = "등록 된 커멘트가 없습니다."
            let attributedText = NSMutableAttributedString().semibold(nickname).normal(comment)
            lastCommentLabel.attributedText = attributedText
        }
    }

    private func configureCommentCountLabel() {
        let text = "\(post?.comments?.count ?? 0) 개 댓글 전체 보기.."
        commentCountLabel.text = text
    }

    private func configureHeartImage() {
        let image = (delegate?.isCurrentUserFavoritePost(post) == true) ? redHeartImage : emptyHeartImage
        heartImageView.image = image
    }

    private func configureCarousel() {
        guard let post = post,
              let resources = post.resources else {
            image1Container.visible(false)
            image2Container.visible(false)
            image3Container.visible(false)
            return
        }
        let resourceCount = resources.count

        if (resourceCount == 0) {
            image1Container.visible(false)
            image2Container.visible(false)
            image3Container.visible(false)
        } else if (resourceCount == 1) {
            image1Container.visible(true)
            image2Container.visible(false)
            image3Container.visible(false)
            image1_1.image(resources[0].url)
        } else if (resourceCount == 2) {
            image1Container.visible(false)
            image2Container.visible(true)
            image3Container.visible(false)
            image2_1.image(resources[0].url)
            image2_2.image(resources[1].url)
        } else if (resourceCount == 3) {
            image1Container.visible(false)
            image2Container.visible(false)
            image3Container.visible(true)
            image3_1.image(resources[0].url)
            image3_2.image(resources[1].url)
            image3_3.image(resources[2].url)
        }
    }

    @objc private func didTapImage2_1() {
        image2Container.bringSubviewToFront(image2_1)
    }

    @objc private func didTapImage2_2() {
        image2Container.bringSubviewToFront(image2_2)
    }

    @objc private func didTapImage3_1() {
        image3Container.bringSubviewToFront(image3_1)
    }

    @objc private func didTapImage3_2() {
        image3Container.bringSubviewToFront(image3_2)
    }

    @objc private func didTapImage3_3() {
        image3Container.bringSubviewToFront(image3_3)
    }

    @objc private func didTapHeartImageView() {
        heartImageView.image = (delegate?.isCurrentUserFavoritePost(post) != true) ? redHeartImage : emptyHeartImage
        delegate?.favorite(post: post)
    }

    @objc private func didTapConversationImageView() {
        delegate?.presentSinglePostView(post: post)
    }

    @objc private func didTapCommentCountLabel() {
        delegate?.presentSinglePostView(post: post)
    }
}
