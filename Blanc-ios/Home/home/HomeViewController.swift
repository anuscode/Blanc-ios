import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Shimmer
import Lottie


class HomeViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var ripple: Ripple = Ripple()

    private var data: HomeUserData = HomeUserData()

    private var dataSource: UITableViewDiffableDataSource<Section, UserDTO>!

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

    private var animations: [AnimationView] = []

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

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
        tableView.register(UserCardTableViewCell.self, forCellReuseIdentifier: UserCardTableViewCell.identifier)
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
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
        homeViewModel?.updateUserLastLoginAt()
        animations.forEach({ view in view.play() })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSubviews()
        configureConstraints()
        subscribeHomeViewModel()
        isLoading = true
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
            if (indexPath.section == 0) {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: UserCardTableViewCell.identifier, for: indexPath) as! UserCardTableViewCell
                cell.bind(user: user, delegate: self)
                return cell
            } else if (indexPath.section == 1) {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: UserCardTableViewCell.identifier, for: indexPath) as! UserCardTableViewCell
                cell.bind(user: user, delegate: self)
                return cell
            } else if (indexPath.section == 2) {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: UserCardTableViewCell.identifier, for: indexPath) as! UserCardTableViewCell
                cell.bind(user: user, delegate: self)
                return cell
            } else {
                return nil
            }
        }
        dataSource.defaultRowAnimation = .left
        tableView.dataSource = dataSource
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(homeLoading1)
        view.addSubview(homeLoading2)
        view.addSubview(shimmer1)
        view.addSubview(shimmer2)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        homeLoading1.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(10)
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
            .reload
            .delay(.milliseconds(700), scheduler: MainScheduler.asyncInstance)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func update(_ data: HomeUserData) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserDTO>()
        snapshot.appendSections([.Recommendation, .Close, .RealTime])
        snapshot.appendItems(data.recommendedUsers, toSection: .Recommendation)
        snapshot.appendItems(data.closeUsers, toSection: .Close)
        snapshot.appendItems(data.realTimeUsers, toSection: .RealTime)
        dataSource.apply(snapshot, animatingDifferences: true) { [unowned self] in
            isLoading = false
        }
    }

    @objc private func didTapAlarmImage() {
        navigationController?.pushViewController(.alarms, current: self)
    }
}

extension HomeViewController: UITableViewDelegate {
    fileprivate enum Section {
        case Recommendation, Close, RealTime
    }

    private func generateFooterView(mainText: String, secondaryText: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .white

        let animationView = AnimationView()
        animations.append(animationView)
        animationView.animation = Animation.named("bad_emoji")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(100).priority(800)
        }

        let mainLabel = UILabel()
        mainLabel.text = mainText
        mainLabel.textColor = .darkText
        mainLabel.textAlignment = .center
        mainLabel.font = .systemFont(ofSize: 20)

        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        let secondaryLabel = UILabel()
        secondaryLabel.text = secondaryText
        secondaryLabel.textColor = .systemGray
        secondaryLabel.textAlignment = .center
        secondaryLabel.font = .systemFont(ofSize: 15)
        secondaryLabel.numberOfLines = 3

        view.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
        }

        return view
    }

    private func generateHeaderView(text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = text
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = UIColor(hexCode: "0C090A")

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(10)
        }

        let underline = UIView()
        underline.backgroundColor = .bumble1
        view.addSubview(underline)

        underline.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(2)
            make.leading.equalTo(label.snp.leading)
            make.trailing.equalTo(label.snp.trailing)
            make.height.equalTo(3)
            make.bottom.equalToSuperview().inset(10)
        }

        return view
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        generateHeaderView(text: sections[section])
    }

    /** Footer is used for a empty message view. **/
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (section == 0) {
            return data.recommendedUsers.count == 0 ? generateFooterView(
                mainText: "해당 되는 유저를 찾을 수 없습니다.",
                secondaryText: "최선을 다해 유저를 모집 중입니다.\n양해 부탁 드립니다."
            ) : UIView()
        }
        if (section == 1) {
            return data.closeUsers.count == 0 ? generateFooterView(
                mainText: "해당 되는 유저를 찾을 수 없습니다.",
                secondaryText: "최선을 다해 유저를 모집 중입니다.\n양해 부탁 드립니다."
            ) : UIView()
        }
        if (section == 2) {
            return data.realTimeUsers.count == 0 ? generateFooterView(
                mainText: "해당 되는 유저를 찾을 수 없습니다.",
                secondaryText: "최선을 다해 유저를 모집 중입니다.\n양해 부탁 드립니다."
            ) : UIView()
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        view.width + 55
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        view.width + 55
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
    }
}

extension HomeViewController: UserCardCellDelegate {

    func didTapSearchView(_ user: UserDTO?) {
        guard let user = user else {
            return
        }
        Channel.user(value: user)
        navigationController?.pushViewController(.userSingle, current: self)
    }

    func confirm(_ user: UserDTO?) -> Observable<ConfirmResult> {
        RequestConfirmViewController.present(target: self, user: user)
    }

    func request(_ user: UserDTO?, animationDone: Observable<Void>) {
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
