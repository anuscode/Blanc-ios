import Foundation
import UIKit
import RxSwift
import FSPagerView
import TTGTagCollectionView
import SwinjectStoryboard
import Lottie

class UserSingleViewController: UIViewController {

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

    var userSingleViewModel: UserSingleViewModel?

    lazy private var navigationBarContent: UIView = {
        let view = UIView()
        view.addSubview(navigationUserImage)
        view.addSubview(navigationUserLabel)
        navigationUserImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(Const.navigationUserImageSize)
            make.height.equalTo(Const.navigationUserImageSize)
        }
        navigationUserLabel.snp.makeConstraints { make in
            make.leading.equalTo(navigationUserImage.snp.trailing).inset(-10)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        return view
    }()

    lazy private var navigationUserImage: UIImageView = {
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

    lazy private var tableView: UITableView = {
        let tableView: UITableView = UITableView()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CarouselTableViewCell.self, forCellReuseIdentifier: CarouselTableViewCell.identifier)
        tableView.register(MatchingTableViewCell.self, forCellReuseIdentifier: MatchingTableViewCell.identifier)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.register(PostListResourceTableViewCell.self, forCellReuseIdentifier: PostListResourceTableViewCell.identifier)
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
        navigationController?.navigationBar.addSubview(navigationBarContent)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.titleView = navigationBarContent
        navigationUserLabel.visible(false)
        navigationUserImage.visible(false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeUserSingleViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        extendedLayoutIncludesOpaqueBars = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.alpha = 100
        navigationBarContent.alpha = 100
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // should remove view model and model otherwise it shows the previous one.
        SwinjectStoryboard.defaultContainer.resetObjectScope(.userSingleScope)
    }

    deinit {
        log.info("deinit UserSingleViewController..")
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(bottomView)
    }

    private func configureConstraints() {
        let window = UIApplication.shared.windows[0]
        tableView.frame = CGRect(x: 0, y: 0, width: view.width,
                height: view.height - CGFloat(Const.bottomViewHeight) - window.safeAreaInsets.bottom)

        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalTo(view.snp.centerX)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(Const.bottomViewHeight)
        }
    }

    private func subscribeUserSingleViewModel() {
        userSingleViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { [unowned self] data in
                    self.data = data
                    tableView.reloadData()
                    calculateRequestButtonActivation()
                    updateNavigation()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func updateNavigation() {
        navigationUserImage.url(data?.user?.avatar)
        navigationUserLabel.text = "\(data?.user?.nickName ?? "알 수 없음"), \(data?.user?.age ?? -1)"
    }

    private func calculateRequestButtonActivation() {
        if (userSingleViewModel?.isWhoMatched() ?? false) {
            requestButton.setTitle("이미 매칭 된 유저 입니다.", for: .normal)
            requestButton.isUserInteractionEnabled = false
            requestButton.backgroundColor = .bumble0
        }

        if (userSingleViewModel?.isWhoISent() ?? false) {
            requestButton.setTitle("이미 친구신청을 보냈습니다.", for: .normal)
            requestButton.isUserInteractionEnabled = false
            requestButton.backgroundColor = .bumble0
        }

        if (userSingleViewModel?.isWhoSentMe() ?? false) {
            requestButton.setTitle("친구신청 수락", for: .normal)
            requestButton.isUserInteractionEnabled = true
            requestButton.backgroundColor = .bumble3
        }
    }

    @objc private func request(user: UserDTO?) {
        if (data == nil || data?.user == nil) {
            return
        }

        if (userSingleViewModel?.isWhoSentMe() ?? false) {
            // do not ask when it's a request already sent.
            userSingleViewModel?.createRequest(data!.user, onError: {
                self.toast(message: "친구신청 도중 에러가 발생 하였습니다.")
            })
            return
        }

        RequestConfirmViewBuilder.create(target: self, user: data!.user)
                .subscribe(onNext: { [unowned self] result in
                    guard (result) else {
                        return
                    }

                    heartLottie.begin(with: view, constraint: {
                        heartLottie.snp.makeConstraints { make in
                            make.edges.equalToSuperview().multipliedBy(0.8)
                            make.center.equalToSuperview()
                        }
                    })

                    userSingleViewModel?.createRequest(data!.user, onError: {
                        toast(message: "친구신청 도중 에러가 발생 하였습니다.")
                    })

                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    @objc private func poke() {
        userSingleViewModel?.poke(
                data?.user,
                onBegin: {
                    pokeLottie.begin(with: view) {
                        pokeLottie.snp.makeConstraints { make in
                            make.center.equalToSuperview()
                            make.width.equalToSuperview().multipliedBy(0.5)
                            make.height.equalToSuperview().multipliedBy(0.5)
                        }
                    }
                },
                completion: { message in
                    self.toast(message: message)
                }
        )
    }
}


extension UserSingleViewController: UITableViewDelegate, UITableViewDataSource {

    // sections parts..
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return view.width
        } else if indexPath.section == 1 {
            return 25
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            if (userSingleViewModel?.isWhoSentMe() == true) {
                return 1
            }
            if (userSingleViewModel?.isWhoISent() == true) {
                return 1
            }
            if (userSingleViewModel?.isWhoMatched() == true) {
                return 1
            }
            return 0
        } else if section == 2 {
            return 1
        } else {
            return data?.posts?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CarouselTableViewCell.identifier, for: indexPath) as! CarouselTableViewCell
            cell.bind(user: data?.user)
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MatchingTableViewCell.identifier, for: indexPath) as! MatchingTableViewCell
            if (userSingleViewModel?.isWhoSentMe() == true) {
                cell.bind(message: "내게 친구신청을 보낸 상대 입니다.")
            } else if (userSingleViewModel?.isWhoISent() == true) {
                cell.bind(message: "이미 친구신청을 보냈습니다.")
            } else if (userSingleViewModel?.isWhoMatched() == true) {
                cell.bind(message: "이미 매칭 된 유저 입니다.")
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
            let starRating = userSingleViewModel?.getStarRatingIRated(data?.user)
            cell.delegate = self
            cell.bind(user: data?.user, starRating: starRating)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostListResourceTableViewCell.identifier, for: indexPath) as! PostListResourceTableViewCell
            cell.bind(post: data?.posts?[indexPath.row])
            return cell
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maximum = view.width - 80
        let y: CGFloat = min(scrollView.contentOffset.y, maximum)
        let percent = y / maximum
        navigationController?.navigationBar.isTranslucent = percent < 0.05 ? true : false
        navigationController?.navigationBar.alpha = percent < 0.05 ? 100 : percent
        navigationBarContent.alpha = percent < 0.05 ? 0 : percent
        if (navigationUserImage.isHidden || navigationUserLabel.isHidden) {
            navigationUserLabel.visible(true)
            navigationUserImage.visible(true)
        }
    }
}

extension UserSingleViewController: ProfileCellDelegate {
    func rate(user: UserDTO?, score: Int) {
        starLottie.begin(with: view) {
            starLottie.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.5)
                make.height.equalToSuperview().multipliedBy(0.5)
            }
        }
        userSingleViewModel?.rate(user, score) { [unowned self] message in
            toast(message: message)
        }
    }
}



