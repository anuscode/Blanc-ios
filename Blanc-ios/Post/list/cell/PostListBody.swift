import Foundation
import UIKit
import FSPagerView

class PostListBody: UIView {

    private let ripple = Ripple()

    private weak var post: PostDTO?

    private weak var delegate: PostBodyDelegate?

    lazy private var carouselStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [carousel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy private var carousel: FSPagerView = {
        let pagerView = FSPagerView(frame: frame)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "PostBodyPagerViewCell")
        pagerView.translatesAutoresizingMaskIntoConstraints = false
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.width(UIScreen.main.bounds.size.width, priority: 800)
        pagerView.height(UIScreen.main.bounds.size.width, priority: 800)
        return pagerView
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

    lazy private var pageControl: FSPageControl = {
        let pageControl = FSPageControl()
        pageControl.contentHorizontalAlignment = .right
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
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
        addSubview(carouselStackView)
        addSubview(pageControl)
        addSubview(heartView)
        addSubview(conversationView)
        addSubview(textsStackView)
    }

    private func configureConstraints() {

        carouselStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        pageControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        heartView.snp.makeConstraints { make in
            make.top.equalTo(carouselStackView.snp.bottom).inset(-8)
            make.leading.equalToSuperview().inset(12)
            make.width.equalTo(PostConfig.containerDiameter)
            make.height.equalTo(PostConfig.containerDiameter)
        }

        conversationView.snp.makeConstraints { make in
            make.top.equalTo(carouselStackView.snp.bottom).inset(-8)
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
        let resourceCount = post?.resources?.count ?? 0

        if (resourceCount != 0) {
            carousel.visible(true)
            carousel.reloadData()
            pageControl.visible(true)
            pageControl.numberOfPages = resourceCount
        } else {
            pageControl.visible(false)
            carousel.visible(false)
        }
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

extension PostListBody: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        post?.resources?.count ?? 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "PostBodyPagerViewCell", at: index)
        guard (post?.resources != nil || post?.resources?.count ?? 0 > 0) else {
            return cell
        }
        let width = UIScreen.main.bounds.size.width
        cell.imageView?.url(post?.resources![index].url, size: CGSize(width: width, height: width))
        cell.imageView?.contentMode = .scaleAspectFill
        return cell
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }

    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
}