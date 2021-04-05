import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Shimmer
import Lottie
import CoreLocation


class HomeViewController: UIViewController {

    fileprivate enum Section {
        case Recommendation, Close, RealTime
    }

    private var disposeBag: DisposeBag = DisposeBag()

    private var ripple: Ripple = Ripple()

    private var data: HomeUserData = HomeUserData()

    private var dataSource: UITableViewDiffableDataSource<Section, UserDTO>!

    private var manager: CLLocationManager = CLLocationManager()

    private var isLoading: Bool = true {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                shimmer1.visible(isLoading)
                shimmer2.visible(isLoading)
                homeLoading1.visible(isLoading)
                homeLoading2.visible(isLoading)
                shimmer1.contentView = homeLoading1
                shimmer2.contentView = homeLoading2
                shimmer1.isShimmering = isLoading
                shimmer2.isShimmering = isLoading
                tableView.visible(!isLoading)
            }
        }
    }

    private let sections: [String] = ["블랑 추천", "근거리 추천", "실시간 추천"]

    private var empties: [[UserDTO]] = [[UserDTO()], [UserDTO()], [UserDTO()]]

    internal weak var homeViewModel: HomeViewModel?

    internal var rightSideBarView: RightSideBarView?

    lazy private var shimmer1: FBShimmeringView = {
        let shimmer = FBShimmeringView()
        shimmer.shimmeringHighlightLength = 0.80
        shimmer.shimmeringPauseDuration = 0.2
        return shimmer
    }()

    lazy private var shimmer2: FBShimmeringView = {
        let shimmer = FBShimmeringView()
        shimmer.shimmeringHighlightLength = 0.80
        shimmer.shimmeringPauseDuration = 0.2
        return shimmer
    }()

    lazy private var locationRecommendationView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(locationRecommendationMainLabel)
        view.addSubview(locationRecommendationSecondaryLabel)
        view.addSubview(locationRecommendationButton)
        view.addSubview(closeLocationRecommendation)
        view.visible(false)
        locationRecommendationMainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }
        locationRecommendationSecondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(locationRecommendationMainLabel.snp.bottom).inset(-7)
            make.centerX.equalToSuperview()
        }
        locationRecommendationButton.snp.makeConstraints { make in
            make.top.equalTo(locationRecommendationSecondaryLabel.snp.bottom).inset(-10)
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        closeLocationRecommendation.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        return view
    }()

    lazy private var closeLocationRecommendation: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "xmark")
        imageView.image = image
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.width(20)
        imageView.height(20)
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapCloseButton))
        return imageView
    }()

    lazy private var locationRecommendationMainLabel: UILabel = {
        let label = UILabel()
        label.text = "위치를 알 수 없어요. 😔"
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()

    lazy private var locationRecommendationSecondaryLabel: UILabel = {
        let label = UILabel()
        label.text = "위치를 알려 주시면 더 좋은 추천이 가능합니다."
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black4
        return label
    }()

    lazy private var locationRecommendationButton: UIButton = {
        let button = UIButton()
        button.setTitle("위치 권한", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 12)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5
        button.backgroundColor = .bumble3
        button.setTitleColor(.white, for: .normal)
        // button.addTarget(self, action: #selector(accept), for: .touchUpInside)
        ripple.activate(to: button)
        button.height(45, priority: 800)
        button.width(200, priority: 800)
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapAuthorizationButton))
        return button
    }()

    @objc private func didTapCloseButton() {
        hideLocationRecommendationView()
    }

    @objc private func didTapAuthorizationButton() {
        let authorization = manager.authorizationStatus
        if (authorization == .denied || authorization == .restricted) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        if (authorization == .authorizedAlways || authorization == .authorizedWhenInUse) {
            return
        }
        manager.requestAlwaysAuthorization()
        hideLocationRecommendationView()
    }

    private func showLocationRecommendationView() {
        locationRecommendationView.visible(true)
        locationRecommendationView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(locationRecommendationView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func hideLocationRecommendationView() {
        locationRecommendationView.visible(false)
        locationRecommendationView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        tableView.snp.remakeConstraints { make in
            make.top.equalTo(locationRecommendationView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
        tableView.register(
            UserCardTableViewCell.self,
            forCellReuseIdentifier: UserCardTableViewCell.identifier
        )
        tableView.register(
            EmptySectionTableViewCell.self,
            forCellReuseIdentifier: EmptySectionTableViewCell.identifier
        )
        tableView.register(
            HomeTableViewHeaderView.self,
            forHeaderFooterViewReuseIdentifier: HomeTableViewHeaderView.identifier
        )
        tableView.visible(false)
        return tableView
    }()

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView())
    }()

    lazy private var rightBarButtonItem: UIBarButtonItem = {
        guard (rightSideBarView != nil) else {
            return UIBarButtonItem()
        }
        rightSideBarView!.delegate {
            self.navigationController?.pushViewController(.alarms, current: self)
        }
        return UIBarButtonItem(customView: rightSideBarView!)
    }()

    lazy private var homeLoading1: HomeLoading = {
        HomeLoading()
    }()

    lazy private var homeLoading2: HomeLoading = {
        HomeLoading()
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        navigationController?.navigationBar.isTranslucent = true
        homeViewModel?.updateUserLastLoginAt()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSubviews()
        configureConstraints()
        subscribeHomeViewModel()
        isLoading = true
        if (manager.authorizationStatus.rawValue <= 2) {
            showLocationRecommendationView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        log.info("deinit home view controller..")
    }

    private func configureTableView() {
        dataSource = UITableViewDiffableDataSource<Section, UserDTO>(tableView: tableView) { [unowned self] (tableView, indexPath, user) -> UITableViewCell? in
            if (user.id == nil) {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: EmptySectionTableViewCell.identifier, for: indexPath) as! EmptySectionTableViewCell
                let mainText = "해당 되는 유저를 찾을 수 없습니다."
                let secondaryText = "최선을 다해 유저를 모집 중입니다.\n양해 부탁 드립니다."
                cell.bind(mainText: mainText, secondaryText: secondaryText)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: UserCardTableViewCell.identifier, for: indexPath) as! UserCardTableViewCell
                cell.bind(user: user, delegate: self)
                return cell
            }
        }
        dataSource.defaultRowAnimation = .none
        tableView.dataSource = dataSource
    }

    private func configureSubviews() {
        view.addSubview(locationRecommendationView)
        view.addSubview(tableView)
        view.addSubview(homeLoading1)
        view.addSubview(homeLoading2)
        view.addSubview(shimmer1)
        view.addSubview(shimmer2)
    }

    private func configureConstraints() {
        locationRecommendationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(locationRecommendationView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        homeLoading1.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.top).inset(10)
            make.centerX.equalToSuperview()
        }
        homeLoading2.snp.makeConstraints { make in
            make.top.equalTo(homeLoading1.snp.bottom).inset(-10)
            make.centerX.equalToSuperview()
        }
        shimmer1.snp.makeConstraints { make in
            make.edges.equalTo(homeLoading1.snp.edges)
        }
        shimmer2.snp.makeConstraints { make in
            make.edges.equalTo(homeLoading2.snp.edges)
        }
    }

    private func subscribeHomeViewModel() {
        homeViewModel?
            .data
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] data in
                self.data = data
                update(data)
            })
            .disposed(by: disposeBag)

        homeViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        homeViewModel?
            .loading
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] isLoading in
                self.isLoading = isLoading
            })
            .disposed(by: disposeBag)
    }

    private func update(_ data: HomeUserData) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserDTO>()

        snapshot.appendSections([.Recommendation, .Close, .RealTime])

        let recommends = !data.recommendedUsers.isEmpty ? data.recommendedUsers : empties[0]
        snapshot.appendItems(recommends, toSection: .Recommendation)

        let closes = !data.closeUsers.isEmpty ? data.closeUsers : empties[1]
        snapshot.appendItems(closes, toSection: .Close)

        let realTimes = !data.realTimeUsers.isEmpty ? data.realTimeUsers : empties[2]
        snapshot.appendItems(realTimes, toSection: .RealTime)

        dataSource.apply(snapshot, animatingDifferences: true) { [unowned self] in
            dataSource.defaultRowAnimation = .none
        }
    }

    @objc private func didTapAlarmImage() {
        navigationController?.pushViewController(.alarms, current: self)
    }
}

extension HomeViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: HomeTableViewHeaderView.identifier) as! HomeTableViewHeaderView
        view.bind(text: sections[section])
        return view
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 && data.recommendedUsers.count == 0) {
            return 300
        }
        if (indexPath.section == 1 && data.closeUsers.count == 0) {
            return 300
        }
        if (indexPath.section == 2 && data.realTimeUsers.count == 0) {
            return 300
        }
        return view.width + 55
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 && data.recommendedUsers.count == 0) {
            return 300
        }
        if (indexPath.section == 1 && data.closeUsers.count == 0) {
            return 300
        }
        if (indexPath.section == 2 && data.realTimeUsers.count == 0) {
            return 300
        }
        return view.width + 55
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController: UserCardCellDelegate {

    func goUserSingle(_ user: UserDTO?) {
        guard let user = user else {
            return
        }
        Channel.next(user: user)
        navigationController?.pushViewController(.userSingle, current: self)
    }

    func confirm(_ user: UserDTO?) -> Observable<ConfirmResult> {
        RequestConfirmViewController.present(target: self, user: user)
    }

    func request(_ user: UserDTO?, animationDone: Observable<Void>) {
        dataSource.defaultRowAnimation = .left
        homeViewModel?.request(user, animationDone: animationDone)
    }

    func poke(_ user: UserDTO?, onBegin: () -> Void) {
        homeViewModel?.poke(user, onBegin: onBegin)
    }

    func rate(_ user: UserDTO?, score: Int) {
        homeViewModel?.rate(user, score: score)
    }

    func purchase() {
        navigationController?.pushViewController(.inAppPurchase, current: self)
    }
}
