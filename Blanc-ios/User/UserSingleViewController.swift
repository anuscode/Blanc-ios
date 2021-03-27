import Foundation
import UIKit
import RxSwift
import FSPagerView
import TTGTagCollectionView
import SwinjectStoryboard
import Lottie

private class Content: UIView {
    override var intrinsicContentSize: CGSize {
        UIView.layoutFittingExpandedSize
    }
}

private typealias DataSource = UITableViewDiffableDataSource

class UserSingleViewController: UIViewController {

    fileprivate enum Section {
        case Carousel, Belt, Body, Posts
    }

    private class Const {
        static let navigationUserImageSize: Int = 28
        static let navigationUserLabelFont: UIFont = .systemFont(ofSize: 15)
        static let bottomViewHeight: Int = 55
        static let navigationUserImageCornerRadius: Int = {
            Const.navigationUserImageSize / 2
        }()
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    private let sections: [String] = ["Carousel", "Matching", "Profile", "Posts"]

    private var data: UserSingleData?

    private var dataSource: DataSource<Section, AnyHashable>!

    internal var userSingleViewModel: UserSingleViewModel!

    lazy private var navigationBarContent: Content = {
        let content = Content()
        let view = UIView()

        view.addSubview(navigationUserImageView)
        view.addSubview(navigationUserLabel)

        navigationUserImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(Const.navigationUserImageSize)
            make.height.equalTo(Const.navigationUserImageSize)
        }

        navigationUserLabel.snp.makeConstraints { make in
            make.leading.equalTo(navigationUserImageView.snp.trailing).inset(-10)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        content.addSubview(view)
        content.addSubview(optionImageView)
        view.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
        }

        optionImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
            make.width.equalTo(Const.navigationUserImageSize)
            make.height.equalTo(Const.navigationUserImageSize)
        }

        return content
    }()

    lazy private var navigationUserImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 14
        imageView.clipsToBounds = true
        return imageView
    }()

    lazy private var navigationUserLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkText
        label.font = Const.navigationUserLabelFont
        return label
    }()

    lazy private var optionImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_more_vert")
        imageView.image = image
        imageView.layer.cornerRadius = CGFloat(Const.navigationUserImageSize / 2)
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapOptionImageView))
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.register(CarouselTableViewCell.self, forCellReuseIdentifier: CarouselTableViewCell.identifier)
        tableView.register(MatchingTableViewCell.self, forCellReuseIdentifier: MatchingTableViewCell.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(PostListResourceTableViewCell.self, forCellReuseIdentifier: PostListResourceTableViewCell.identifier)
        tableView.register(EmptySectionTableViewCell.self, forCellReuseIdentifier: EmptySectionTableViewCell.identifier)
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
        return tableView
    }()

    lazy private var bottomView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.addSubview(requestButton)
        view.addSubview(pokeButton)

        requestButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(pokeButton.snp.leading).inset(-5)
        }

        pokeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(5)
            make.leading.equalTo(requestButton.snp.trailing)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(55)
        }

        return view
    }()

    lazy private var requestButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .bumble3
        button.setTitle("친구요청", for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(request), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    lazy private var pokeButton: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.radius
        view.backgroundColor = .bumble3
        view.isUserInteractionEnabled = true
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
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(poke))
        return view
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
        animationView.animationSpeed = 1.5
        return animationView
    }()

    override var prefersStatusBarHidden: Bool {
        navigationController?.isNavigationBarHidden == true
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        UIStatusBarAnimation.slide
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.titleView = navigationBarContent
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        if (navigationController?.navigationBar.subviews.contains(navigationBarContent) == false) {
            navigationController?.navigationBar.addSubview(navigationBarContent)
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        scrollViewDidScroll(tableView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        configureTableView()
        subscribeUserSingleViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        extendedLayoutIncludesOpaqueBars = false
        navigationBarContent.alpha = 100
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.alpha = 100
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
        // should remove view model and model otherwise it shows the previous one.
        // SwinjectStoryboard.defaultContainer.resetObjectScope(.userSingleScope)
        log.info("deinit UserSingleViewController..")
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
    }

    private func configureConstraints() {
        let window = UIApplication.shared.windows[0]
        let height = view.height - CGFloat(Const.bottomViewHeight) - window.safeAreaInsets.bottom
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: height)

        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalTo(view.snp.centerX)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Const.bottomViewHeight)
        }
    }

    private func configureTableView() {
        dataSource = DataSource<Section, AnyHashable>(tableView: tableView) { [unowned self] (tableView, indexPath, item) -> UITableViewCell? in
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: CarouselTableViewCell.identifier, for: indexPath) as! CarouselTableViewCell
                cell.bind(user: data?.carousel[0].user)
                return cell
            } else if indexPath.section == 1 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: MatchingTableViewCell.identifier, for: indexPath) as! MatchingTableViewCell
                cell.bind(message: data?.belt[0].message)
                return cell
            } else if indexPath.section == 2 {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
                cell.bind(user: data?.body[0].user, delegate: self)
                return cell
            } else {
                let post = item as! PostDTO
                if (post.id.isEmpty()) {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: EmptySectionTableViewCell.identifier, for: indexPath) as! EmptySectionTableViewCell
                    let mainText = "게시물이 존재하지 않습니다."
                    let secondaryText = "해당 사용자는 게시물을 등록 한 적이 없습니다."
                    cell.bind(mainText: mainText, secondaryText: secondaryText)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: PostListResourceTableViewCell.identifier, for: indexPath) as! PostListResourceTableViewCell
                    cell.bind(post: post, bodyDelegate: self)
                    return cell
                }
            }
        }
        dataSource.defaultRowAnimation = .none
        tableView.dataSource = dataSource
    }

    private func subscribeUserSingleViewModel() {
        userSingleViewModel?
            .data
            .take(2)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] data in
                self.data = data
                update(data)
            })
            .disposed(by: disposeBag)

        userSingleViewModel?
            .data
            .skip(2)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] data in
                self.data = data
                update(data, animatingDifferences: false)
            })
            .disposed(by: disposeBag)

        userSingleViewModel?
            .data
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] data in
                navigation(data)
            })
            .disposed(by: disposeBag)

        userSingleViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        userSingleViewModel?
            .data
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] data in
                enableRequestButton(data)
            })
            .disposed(by: disposeBag)
    }

    private func navigation(_ data: UserSingleData) {
        let avatar = data.user?.avatar
        let nickname = data.user?.nickname ?? "알 수 없음"
        let age = data.user?.age ?? -1
        let text = "\(nickname), \(age)"
        navigationUserImageView.url(avatar)
        navigationUserLabel.text = text
    }

    private func enableRequestButton(_ data: UserSingleData) {
        let match = data.user?.relationship?.match
        switch match {
        case .isMatched:
            requestButton.setTitle("연결 된 유저", for: .normal)
            requestButton.isUserInteractionEnabled = false
            requestButton.backgroundColor = UIColor.bumble3.withAlphaComponent(0.7)
            return
        case .isUnmatched:
            requestButton.setTitle("이미 보냄", for: .normal)
            requestButton.isUserInteractionEnabled = false
            requestButton.backgroundColor = UIColor.bumble3.withAlphaComponent(0.7)
            return
        case .isWhoSentMe:
            requestButton.setTitle("수락", for: .normal)
            requestButton.isUserInteractionEnabled = true
            requestButton.backgroundColor = .bumble3
            return
        case .isWhoISent:
            requestButton.setTitle("이미 보냄", for: .normal)
            requestButton.isUserInteractionEnabled = false
            requestButton.backgroundColor = UIColor.bumble3.withAlphaComponent(0.7)
            return
        default:
            requestButton.setTitle("친구 신청", for: .normal)
            requestButton.isUserInteractionEnabled = true
            requestButton.backgroundColor = .bumble3
        }
    }

    private func update(_ data: UserSingleData, animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.Carousel, .Belt, .Body, .Posts])
        let carousel = data.carousel
        let belt = data.belt
        let body = data.body
        let posts = data.posts.isEmpty ? [PostDTO()] : data.posts
        snapshot.appendItems(carousel, toSection: .Carousel)
        snapshot.appendItems(belt, toSection: .Belt)
        snapshot.appendItems(body, toSection: .Body)
        snapshot.appendItems(posts, toSection: .Posts)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    @objc private func request() {
        guard let user = data?.user else {
            return
        }

        if (user.relationship?.match == .isMatched) {
            toast(message: "이미 연결 된 상대 입니다.")
            return
        }

        if (user.relationship?.match == .isUnmatched) {
            toast(message: "이미 보낸 상대 입니다.")
            return
        }

        if (user.relationship?.match == .isWhoSentMe) {
            userSingleViewModel?.createRequest()
            return
        }

        RequestConfirmViewController
            .present(target: self, user: user)
            .subscribe(onNext: { [unowned self] result in
                switch (result) {
                case .accept:
                    heartLottie.begin(with: view) { make in
                        make.edges.equalToSuperview().multipliedBy(0.8)
                        make.center.equalToSuperview()
                    }
                    userSingleViewModel?.createRequest()
                case .purchase:
                    navigationController?.pushViewController(.inAppPurchase, current: self)
                case .decline:
                    log.info("declined to request user..")
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    @objc private func poke() {
        let onBegin: () -> Void = { [unowned self] in
            pokeLottie.begin(with: view) { make in
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.5)
            }
        }
        userSingleViewModel?.poke(onBegin: onBegin)
    }

    @objc private func didTapOptionImageView() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "신고", style: .default) { [unowned self] (action) in
            guard let user = data?.user else {
                return
            }
            Channel.next(report: user)
            navigationController?.pushViewController(
                .reportUser,
                current: self,
                hideBottomWhenStart: true,
                hideBottomWhenEnd: true
            )
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        alertController.modalPresentationStyle = .popover
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                let sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.sourceView = view
                popoverController.sourceRect = sourceRect
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
}


extension UserSingleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return view.width
        } else if indexPath.section == 1 {
            return 28
        } else if indexPath.section == 2 {
            return UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    // cells parts..
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maximum = view.width - 80
        let y: CGFloat = min(scrollView.contentOffset.y, maximum)
        let percent = y / maximum
        let isThreshold = percent < 0.05
        navigationController?.navigationBar.isTranslucent = isThreshold ? true : false
        navigationController?.navigationBar.alpha = isThreshold ? 100 : percent
        navigationBarContent.alpha = isThreshold ? 0 : percent
        navigationController?.navigationBar.setValue(isThreshold, forKey: "hidesShadow")
        navigationUserLabel.visible(!isThreshold)
        navigationUserImageView.visible(!isThreshold)
        optionImageView.visible(!isThreshold)
    }
}

extension UserSingleViewController: ProfileCellDelegate {
    func rate(user: UserDTO?, score: Int) {
        starLottie.begin(with: view) { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        userSingleViewModel?.rate(score)
    }
}

extension UserSingleViewController: PostBodyDelegate {
    func favorite(post: PostDTO?) {
        userSingleViewModel?.favorite(post)
    }

    func presentSinglePostView(post: PostDTO?) {
        guard let post = post else {
            return
        }
        Channel.next(post: post)
        navigationController?.pushViewController(
            .postSingle,
            current: self,
            hideBottomWhenStart: true,
            hideBottomWhenEnd: true
        )
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        userSingleViewModel.isCurrentUserFavoritePost(post)
    }
}



