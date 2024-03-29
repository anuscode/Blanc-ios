import Foundation
import UIKit
import FSPagerView

class PostManagementBody: UIView {

    private let ripple = Ripple()

    private weak var post: PostDTO?

    private weak var delegate: PostManagementTableViewCellDelegate?

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

    lazy private var textsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            userFavoriteCountLabel, descriptionLabel, favoriteUserListLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.setCustomSpacing(8, after: userFavoriteCountLabel)
        stackView.setCustomSpacing(8, after: descriptionLabel)
        stackView.setCustomSpacing(8, after: favoriteUserListLabel)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: 0, left: PostConfig.textHorizontalMargin,
            bottom: 0, right: PostConfig.textHorizontalMargin)
        return stackView
    }()

    lazy private var userFavoriteCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PostConfig.favoriteUserCountFontSize)
        label.textColor = .black
        label.text = "0 명의 사람들이 이 게시물을 좋아합니다."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private(set) var favoriteUserListLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PostConfig.favoriteUserListFontSize)
        label.textColor = .systemPink
        label.text = "좋아요 누른 사람 보기"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapFavoriteUserListLabel))
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

        textsStackView.snp.makeConstraints { make in
            make.top.equalTo(heartImageView.snp.bottom).inset(-10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }

    func bind(post: PostDTO?, delegate: PostManagementTableViewCellDelegate?) {
        self.post = post
        self.delegate = delegate

        configureCarousel()
        configureDescriptionLabel()
        configureUserFavoriteCountLabel()
        configureHeartImage()
    }

    private func configureCarousel() {
        let numberOfItems = post?.resources?.count ?? 0
        if (numberOfItems > 0) {
            carousel.reloadData()
            pageControl.numberOfPages = numberOfItems
            pageControl.visible(true)
            pageControl.currentPage = 0
            carousel.visible(true)
        } else {
            pageControl.visible(false)
            carousel.visible(false)
        }
    }

    private func configureUserFavoriteCountLabel() {
        let text = "\(post?.favoriteUserIds?.count ?? 0) 명의 사람들이 이 게시물을 좋아합니다."
        userFavoriteCountLabel.text = text
    }

    private func configureDescriptionLabel() {
        let isNotEmpty = post?.description != nil && post?.description?.isEmpty != true
        descriptionLabel.text = isNotEmpty ? "\(post?.description ?? "")" : "..."
    }

    private func configureHeartImage() {
        let isCurrentUserFavoritePost = delegate?.isFavoritePost(post) == true
        heartImageView.image = isCurrentUserFavoritePost ? redHeartImage : emptyHeartImage
    }

    @objc private func didTapHeartImageView() {
        let isNotCurrentUserFavoritePost = delegate?.isFavoritePost(post) != true
        heartImageView.image = isNotCurrentUserFavoritePost ? redHeartImage : emptyHeartImage
        delegate?.favorite(post)
    }

    @objc private func didTapFavoriteUserListLabel() {
        delegate?.presentFavoriteUserListView(post)
    }
}

extension PostManagementBody: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        post?.resources?.count ?? 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "PostBodyPagerViewCell", at: index)
        guard let resources = post?.resources, resources.count > 0 else {
            return cell
        }
        let width = UIScreen.main.bounds.size.width
        let size = CGSize(width: width, height: width)
        let url = resources[index].url
        cell.imageView?.url(url, size: size)
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