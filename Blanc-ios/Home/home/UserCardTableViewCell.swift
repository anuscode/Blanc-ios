import Foundation
import UIKit
import FSPagerView
import RxSwift
import Lottie

enum Mode {
    case label, star
}

class StarTapGesture: UITapGestureRecognizer {
    var index: Int!
}

protocol UserCardCellDelegate: class {
    func didTapSearchView(_ user: UserDTO?)
    func confirm(_ user: UserDTO?) -> Observable<ConfirmResult>
    func request(_ user: UserDTO?, animationDone: Observable<Void>)
    func poke(_ user: UserDTO?, onBegin: () -> Void)
    func rate(_ user: UserDTO?, score: Int)
    func purchase()
}

class UserCardTableViewCell: UITableViewCell {

    private class Const {
        static let horizontalInset: CGFloat = 10
        static let bottomMargin: CGFloat = 10
        static let starSize: CGFloat = 40
        static let starHorizontalInset: CGFloat = -6
        static var length: CGFloat {
            get {
                let width = UIScreen.main.bounds.width - (Const.horizontalInset * 2)
                return width
            }
        }
        static var diameter: CGFloat {
            get {
                length / 5.5
            }
        }
    }

    static let identifier = "UserCardTableViewCell"

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple = Ripple()

    private let fireworkController = ClassicFireworkController()

    private weak var user: UserDTO?

    private weak var delegate: UserCardCellDelegate?

    lazy private var carousel: FSPagerView = {
        let pagerView = FSPagerView(frame: frame)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.translatesAutoresizingMaskIntoConstraints = false
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapCarousel))
        return pagerView
    }()

    lazy private var heartLottie: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("heart")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        return animationView
    }()

    lazy private var pokeLottie: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("poke")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 3
        return animationView
    }()

    lazy private var starLottie: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("star")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 2
        return animationView
    }()

    lazy private var pageControl: FSPageControl = {
        let pageControl = FSPageControl()
        pageControl.contentHorizontalAlignment = .right
        return pageControl
    }()

    lazy private var gradientView: GradientView = {
        let alpha0 = UIColor.userCardGradientBlack.withAlphaComponent(0)
        let alpha1 = UIColor.userCardGradientBlack.withAlphaComponent(1)
        let gradient = GradientView(colors: [alpha0, alpha1, alpha1], locations: [0.0, 0.67, 1.0])
        return gradient
    }()

    lazy private var searchView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = Const.diameter / 2
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.15).cgColor
        view.layer.borderWidth = 2
        view.visible(false)

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_search")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
        return view
    }()

    lazy private var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .userCardGradientBlack
        return view
    }()

    lazy private var button1: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.radius
        view.backgroundColor = .bumble0
        view.isUserInteractionEnabled = true
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapStarRatingButton))
        ripple.activate(to: view)

        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textColor = .bumble5
        label.text = "평가하기"

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_star_bumble_r")
        view.addSubview(label)
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.width.equalTo(25)
            make.height.equalTo(25)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
        }
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(3)
        }
        return view
    }()

    lazy private var button2: UIButton = {
        let button = UIButton()
        button.setTitle("친구신청", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = .bumble3
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapRequestButton), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    lazy private var button3: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.radius
        view.backgroundColor = .bumble3
        view.isUserInteractionEnabled = true
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapPokeButton))
        ripple.activate(to: view)

        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 10)
        label.textColor = .white
        label.text = "찔러보기"

        let image = UIImage(named: "ic_backhand")
        let imageView = UIImageView()
        imageView.image = image
        view.addSubview(label)
        view.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
        }
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(3)
        }
        return view
    }()

    lazy private var label1: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = .white
        return label
    }()

    lazy private var label2: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()

    lazy private var label3: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray5
        return label
    }()

    lazy private var stars: [UIImageView] = {
        [star1, star2, star3, star4, star5]
    }()

    lazy private var star1: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_white_r")
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var star2: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_white_r")
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var star3: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_white_r")
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var star4: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_white_r")
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var star5: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = UIImage(named: "ic_star_white_r")
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var starLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()

    lazy private var starsView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSelf()
        configureSearchViewTapListener()
        configureSubviews()
        configureConstraints()
        configureInitialTransform()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        if (label1.isHidden) {
            switchCardBodyMode(to: .label)
        }
        button1.isUserInteractionEnabled = true
        if (!searchView.isHidden) {
            searchView.visible(false)
        }
    }

    private func configureSelf() {
        contentView.layer.cornerRadius = 15
        contentView.clipsToBounds = true
    }

    private func configureSearchViewTapListener() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapSearchView))
        searchView.addGestureRecognizer(gesture)
    }

    private func configureStarsAndTapListener(_ starRating: StarRating?) {
        if (starRating != nil) {
            rate(score: starRating!.score)
            for i in 0...4 {
                let star = stars[i]
                for recognizer in star.gestureRecognizers ?? [] {
                    star.removeGestureRecognizer(recognizer)
                }
            }
        } else {
            rate(score: 0)
            for i in 0...4 {
                let star = stars[i]
                let gesture = StarTapGesture(target: self, action: #selector(didTapStarImage))
                gesture.index = i
                star.addGestureRecognizer(gesture)
            }
        }
    }

    private func configureSubviews() {
        contentView.addSubview(carousel)
        contentView.addSubview(gradientView)
        contentView.addSubview(searchView)
        contentView.addSubview(bottomView)
        contentView.addSubview(pageControl)
        contentView.addSubview(label1)
        contentView.addSubview(label2)
        contentView.addSubview(label3)
        contentView.addSubview(starsView)

        // buttons in bottomView..
        bottomView.addSubview(button1)
        bottomView.addSubview(button2)
        bottomView.addSubview(button3)

        // stars in starsView..
        starsView.addSubview(starLabel)
        starsView.addSubview(star1)
        starsView.addSubview(star2)
        starsView.addSubview(star3)
        starsView.addSubview(star4)
        starsView.addSubview(star5)
    }

    private func configureConstraints() {

        carousel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.equalTo(Const.length).priority(800)
            make.height.equalTo(Const.length).priority(800)
        }

        searchView.snp.makeConstraints { make in
            make.center.equalTo(carousel.snp.center)
            make.width.equalTo(Const.diameter)
            make.height.equalTo(Const.diameter)
        }

        bottomView.snp.makeConstraints { make in
            make.top.equalTo(carousel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        label1.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(label2.snp.top).inset(-8)
        }

        label2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(label3.snp.top).inset(-5)
        }

        label3.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(bottomView.snp.top).inset(-9)
        }

        gradientView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.bottom)
            make.height.equalTo(200)
        }

        pageControl.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        starsView.snp.makeConstraints { make in
            make.top.equalTo(label1.snp.top)
            make.bottom.equalTo(bottomView.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        button1.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.width.equalTo(55)
        }

        button2.snp.makeConstraints { make in
            make.leading.equalTo(button1.snp.trailing).inset(-8)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }

        button3.snp.makeConstraints { make in
            make.leading.equalTo(button2.snp.trailing).inset(-8)
            make.top.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.width.equalTo(55)
            make.trailing.equalToSuperview().inset(15)
        }

        let size = Const.starSize
        let margin = Const.starHorizontalInset

        starLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        star1.snp.makeConstraints { make in
            make.trailing.equalTo(star2.snp.leading).inset(margin)
            make.top.equalTo(starLabel.snp.bottom).inset(-5)
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star2.snp.makeConstraints { make in
            make.trailing.equalTo(star3.snp.leading).inset(margin)
            make.top.equalTo(starLabel.snp.bottom).inset(-5)
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star3.snp.makeConstraints { make in
            make.top.equalTo(starLabel.snp.bottom).inset(-5)
            make.centerX.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star4.snp.makeConstraints { make in
            make.leading.equalTo(star3.snp.trailing).inset(margin)
            make.top.equalTo(starLabel.snp.bottom).inset(-5)
            make.centerY.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }

        star5.snp.makeConstraints { make in
            make.leading.equalTo(star4.snp.trailing).inset(margin)
            make.top.equalTo(starLabel.snp.bottom).inset(-5)
            make.centerY.equalToSuperview()
            make.width.equalTo(size)
            make.height.equalTo(size)
        }
    }

    private func configureInitialTransform() {
        starsView.transform = CGAffineTransform(translationX: -width, y: 0)
        starsView.visible(false)
        label1.transform = CGAffineTransform(translationX: 0, y: 0)
        label2.transform = CGAffineTransform(translationX: 0, y: 0)
        label3.transform = CGAffineTransform(translationX: 0, y: 0)
        label1.visible(true)
        label2.visible(true)
        label3.visible(true)
    }

    @objc func didTapStarRatingButton(sender: UITapGestureRecognizer) {
        fireworkController.addFireworks(count: 2, around: button1)
        if (label1.isHidden) {
            switchCardBodyMode(to: .label)
        } else {
            let starRating = user?.relationship?.starRating
            configureStarsAndTapListener(starRating)
            switchCardBodyMode(to: .star)
        }
        button1.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            button1.isUserInteractionEnabled = true
        }
    }

    @objc func didTapRequestButton() {
        guard let user = user else {
            return
        }
        fireworkController.addFireworks(count: 2, around: button2)
        delegate?
            .confirm(user)
            .subscribe(onNext: { [unowned self] result in
                switch (result) {
                case .accept:
                    let done = heartLottie.begin(with: contentView, constraint: {
                        heartLottie.snp.makeConstraints { make in
                            make.edges.equalTo(carousel.snp.edges)
                        }
                    })
                    delegate?.request(user, animationDone: done)
                case .purchase:
                    delegate?.purchase()
                case .decline:
                    log.info("declined request user..")
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    @objc func didTapPokeButton(sender: UITapGestureRecognizer) {
        fireworkController.addFireworks(count: 2, around: button3)
        delegate?.poke(user, onBegin: {
            pokeLottie.begin(with: contentView) {
                pokeLottie.snp.makeConstraints { make in
                    make.center.equalTo(carousel.snp.center)
                    make.width.equalTo(carousel.snp.width).multipliedBy(0.5)
                    make.height.equalTo(carousel.snp.height).multipliedBy(0.5)
                }
            }
        })
    }

    @objc func didTapStarImage(sender: StarTapGesture) {
        let score = sender.index! + 1
        rate(score: score)
        starLottie.begin(with: contentView) {
            starLottie.snp.makeConstraints { make in
                make.center.equalTo(carousel.snp.center)
                make.width.equalTo(carousel.snp.width).multipliedBy(0.5)
                make.height.equalTo(carousel.snp.height).multipliedBy(0.5)
            }
        }
        delegate?.rate(user, score: score)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.switchCardBodyMode(to: .label)
        }
    }

    @objc func didTapSearchView(sender: UITapGestureRecognizer) {
        searchView.visible(false)
        delegate?.didTapSearchView(user)
    }

    @objc private func didTapCarousel() {
        if (searchView.isHidden) {
            searchView.visible(true)
            var transform = CGAffineTransform.identity
            transform = transform.rotated(by: -1 * .pi / 2)
            transform = transform.scaledBy(x: 0.1, y: 0.1)
            searchView.transform = transform
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn) {
                self.searchView.transform = CGAffineTransform.identity
            }
        } else {
            searchView.visible(false)
        }
    }

    private func rate(score: Int?) {
        let threshold = (score ?? 0 - 1)
        let bumbleStar = UIImage(named: "ic_star_bumble_r")
        let whiteStar = UIImage(named: "ic_star_white_r")
        for i in 0...4 {
            let star = stars[i]
            if (i < threshold) {
                star.image = bumbleStar
            } else {
                star.image = whiteStar
            }
        }
    }

    func bind(user: UserDTO, delegate: UserCardCellDelegate) {
        self.user = user
        self.delegate = delegate

        let numberOfPages = user.userImages?.count ?? 0
        let label1Text = "\(user.nickname ?? "알 수 없음"), \(user.age ?? 0)"
        let label2Text = "\(user.area ?? "알 수 없음") · \(user.distance ?? "알 수 없음")"
        let label3Text = "\(user.occupation ?? "알 수 없음") · \(user.lastLoginAt?.asStaledDay() ?? "오래 전") 접속"
        let starLabelText = "\(user.nickname ?? "알 수 없음")님의 매력을 알려주세요."

        pageControl.numberOfPages = numberOfPages
        label1.text = label1Text
        label2.text = label2Text
        label3.text = label3Text
        starLabel.text = starLabelText

        carousel.reloadData()
    }
}

extension UserCardTableViewCell: FSPagerViewDataSource, FSPagerViewDelegate {

    func numberOfItems(in pagerView: FSPagerView) -> Int {
        user?.userImages?.count ?? 0
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        guard (user?.userImages != nil || user?.userImages?.count ?? 0 > 0) else {
            return cell
        }
        cell.imageView?.url(user?.userImages?[index].url, size: CGSize(width: Const.length, height: Const.length))
        return cell
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }

    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        pageControl.currentPage = pagerView.currentIndex
    }
}

extension UserCardTableViewCell {
    private func showLabels() {
        let left = CGAffineTransform(translationX: 0, y: 0)
        label1.visible(true)
        label2.visible(true)
        label3.visible(true)
        UIView.animate(withDuration: 0.4, animations: {
            self.label1.transform = left
            self.label2.transform = left
            self.label3.transform = left
        })
    }

    private func hideLabels() {
        let right = CGAffineTransform(translationX: width, y: 0)
        UIView.animate(withDuration: 0.4, animations: {
            self.label1.transform = right
            self.label2.transform = right
            self.label3.transform = right
        }) { (finished) in
            self.label1.isHidden = finished
            self.label2.isHidden = finished
            self.label3.isHidden = finished
        }
    }

    private func showStars() {
        let right = CGAffineTransform(translationX: 0, y: 0)
        starsView.visible(true)
        UIView.animate(withDuration: 0.4, animations: {
            self.starsView.transform = right
        })
    }

    private func hideStars() {
        let left = CGAffineTransform(translationX: -width, y: 0)
        UIView.animate(withDuration: 0.4, animations: {
            self.starsView.transform = left
        }) { (finished) in
            self.starsView.isHidden = finished
        }
    }

    private func switchCardBodyMode(to: Mode) {
        switch (to) {
        case .label:
            showLabels()
            hideStars()
        case .star:
            hideLabels()
            showStars()
            guard let _ = user?.relationship?.starRating else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.switchCardBodyMode(to: .label)
            }
        }
    }
}
