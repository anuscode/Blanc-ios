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
            favoriteUserCountLabel, descriptionLabel, lastCommentLabel, commentCountLabel
        ])
        let spacing = CGFloat(PostConfig.textVerticalMargin)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.setCustomSpacing(spacing, after: favoriteUserCountLabel)
        stackView.setCustomSpacing(spacing, after: descriptionLabel)
        stackView.setCustomSpacing(spacing, after: lastCommentLabel)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(
                top: 0, left: CGFloat(PostConfig.textHorizontalMargin),
                bottom: 0, right: CGFloat(PostConfig.textHorizontalMargin))
        return stackView
    }()

    lazy private var favoriteUserCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private(set) var lastCommentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private(set) var commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapCommentCountLabel))
        return label
    }()

    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
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
            make.width.equalTo(PostConfig.imageDiameter)
            make.height.equalTo(PostConfig.imageDiameter)
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
        favoriteUserCountLabel.text = "\(post?.favoriteUserIds?.count ?? 0) 명의 사람들이 이 게시물을 좋아합니다."
    }

    private func configureDescriptionLabel() {
        if (post?.description != nil && post?.description?.isEmpty != true) {
            descriptionLabel.text = "\(post?.description ?? "")"
            descriptionLabel.visible(true)
        } else {
            descriptionLabel.visible(false)
        }
    }

    private func configureLastCommentLabel() {
        let lastComment = post?.comments?.first
        if (lastComment != nil) {
            lastCommentLabel.text = "\(lastComment?.commenter?.nickname ?? "알 수 없음"): \(lastComment?.comment ?? "알 수 없음.")"
        } else {
            lastCommentLabel.text = "#: 등록 된 커멘트가 없습니다."
        }
    }

    private func configureCommentCountLabel() {
        commentCountLabel.text = "\(post?.comments?.count ?? 0) 개 댓글 전체 보기.."
    }

    private func configureHeartImage() {
        heartImageView.image = (delegate?.isCurrentUserFavoritePost(post) == true) ? redHeartImage : emptyHeartImage
    }

    private func configureCarousel() {
        if ((post?.resources?.count ?? 0) != 0) {
            carousel.visible(true)
            carousel.reloadData()
        } else {
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
}