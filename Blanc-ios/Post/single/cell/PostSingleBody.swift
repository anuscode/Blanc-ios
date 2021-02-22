import Foundation
import UIKit
import FSPagerView

class PostSingleBody: UIView {

    private var post: PostDTO?

    private let ripple = Ripple()

    private var delegate: PostSingleTableViewCellDelegate?

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
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        label.text = "3 명의 사람들이 이 게시물을 좋아합니다."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.text = "안녕하세요 :) 방갑습니다."
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
        addSubview(carousel)
        addSubview(pageControl)
        addSubview(heartView)
        addSubview(userFavoriteCountLabel)
        addSubview(descriptionLabel)
    }

    private func configureConstraints() {

        carousel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        pageControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        heartView.snp.makeConstraints { make in
            make.top.equalTo(carousel.snp.bottom).offset(8)
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
        setDescriptionLabel()
        setUserFavoriteCountLabel()
        setHeartImage()
    }

    private func configureCarousel() {
        if ((post?.resources?.count ?? 0) > 0) {
            carousel.visible(true)
            carousel.reloadData()
        } else {
            carousel.visible(false)
        }
    }

    private func setUserFavoriteCountLabel() {
        userFavoriteCountLabel.text = "\(post?.favoriteUserIds?.count ?? 0) 명의 사람들이 이 게시물을 좋아합니다."
    }

    private func setDescriptionLabel() {
        if (post?.description == nil || post?.description == "") {
            descriptionLabel.text = "이미지 only 게시물 입니다."
        } else {
            descriptionLabel.text = post?.description
        }
    }

    private func setHeartImage() {
        heartImageView.image = (delegate?.isCurrentUserFavoritePost() == true) ? redHeartImage : emptyHeartImage
    }

    @objc private func didTapHeartImageView() {
        heartImageView.image = (delegate?.isCurrentUserFavoritePost() != true) ? redHeartImage : emptyHeartImage
        delegate?.favorite()
    }
}

extension PostSingleBody: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        post?.resources?.count ?? 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "PostSingleBodyPagerViewCell", at: index)
        guard (post?.resources != nil || post?.resources?.count ?? 0 > 0) else {
            return cell
        }
        cell.imageView?.url(post?.resources![index].url, size: CGSize(width: frame.size.width, height: frame.size.width))
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