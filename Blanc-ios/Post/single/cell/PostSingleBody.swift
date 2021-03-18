import Foundation
import UIKit
import FSPagerView

class PostSingleBody: UIView {

    private var post: PostDTO?

    private let ripple = Ripple()

    private weak var delegate: PostSingleTableViewCellDelegate?

    lazy private var carouselStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [carousel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy private var carousel: FSPagerView = {
        let pagerView = FSPagerView(frame: frame)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "PostSingleBodyPagerViewCell")
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

    lazy private var userFavoriteCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: PostConfig.favoriteUserCountFontSize)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
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
        addSubview(userFavoriteCountLabel)
        addSubview(descriptionLabel)
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
            make.top.equalTo(carouselStackView.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(12)
            make.width.equalTo(PostConfig.containerDiameter)
            make.height.equalTo(PostConfig.containerDiameter)
        }

        userFavoriteCountLabel.snp.makeConstraints { make in
            make.top.equalTo(heartView.snp.bottom).offset(6)
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(userFavoriteCountLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(15)
            make.trailing.equalToSuperview().inset(15)
            make.width.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    }

    func bind(post: PostDTO?, delegate: PostSingleTableViewCellDelegate) {
        self.post = post
        self.delegate = delegate

        configureCarousel()
        configureDescriptionLabel()
        configureUserFavoriteCountLabel()
        configureHeartImage()
    }

    private func configureCarousel() {
        let numberOfPosts = post?.resources?.count ?? 0
        if (numberOfPosts > 0) {
            pageControl.numberOfPages = numberOfPosts
            pageControl.currentPage = 0
            pageControl.visible(true)
            carousel.reloadData()
            carousel.visible(true)
        } else {
            pageControl.visible(false)
            carousel.visible(false)
        }
    }

    private func configureUserFavoriteCountLabel() {
        let favoriteUsersCount = post?.favoriteUserIds?.count ?? 0
        userFavoriteCountLabel.text = "\(favoriteUsersCount) 명의 사람들이 이 게시물을 좋아합니다."
    }

    private func configureDescriptionLabel() {
        let isNotEmpty = post?.description != nil && post?.description?.isEmpty != true
        descriptionLabel.text = isNotEmpty ? "\(post?.description ?? "")" : "..."
    }

    private func configureHeartImage() {
        let isCurrentUserFavoritePost = delegate?.isFavoritePost() == true
        heartImageView.image = isCurrentUserFavoritePost ? redHeartImage : emptyHeartImage
    }

    @objc private func didTapHeartImageView() {
        let isNotCurrentUserFavoritePost = delegate?.isFavoritePost() != true
        heartImageView.image = isNotCurrentUserFavoritePost ? redHeartImage : emptyHeartImage
        delegate?.favorite()
    }
}

extension PostSingleBody: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        post?.resources?.count ?? 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "PostSingleBodyPagerViewCell", at: index)
        guard let resources = post?.resources, resources.count > 0 else {
            return cell
        }
        let size = CGSize(width: frame.size.width, height: frame.size.width)
        cell.imageView?.url(resources[index].url, size: size)
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
        false
    }
}