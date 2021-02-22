import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Shimmer


class HomeViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var ripple: Ripple = Ripple()

    private var data: HomeUserData = HomeUserData()

    private var dataSource: UITableViewDiffableDataSource<Section, UserDTO>!

    private var isLoading: Bool = true {
        didSet {
            DispatchQueue.main.async { [self] in
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

    var homeViewModel: HomeViewModel?

    var rightSideBarView: RightSideBarView?

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
            self.navigationController?.pushAlarmViewController(current: self)
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
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = leftBarButtonItem
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

    private func configureTableView() {
        dataSource = UITableViewDiffableDataSource<Section, UserDTO>(tableView: tableView) { [self] (tableView, indexPath, user) -> UITableViewCell? in
            if (indexPath.section == 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: UserCardTableViewCell.identifier, for: indexPath) as! UserCardTableViewCell
                let user = data.recommendedUsers[indexPath.row]
                cell.delegate = self
                cell.bind(user: user)
                return cell
            } else if (indexPath.section == 1) {
                let cell = tableView.dequeueReusableCell(withIdentifier: UserCardTableViewCell.identifier, for: indexPath) as! UserCardTableViewCell
                let user = data.closeUsers[indexPath.row]
                cell.delegate = self
                cell.bind(user: user)
                return cell
            } else if (indexPath.section == 2) {
                let cell = tableView.dequeueReusableCell(withIdentifier: UserCardTableViewCell.identifier, for: indexPath) as! UserCardTableViewCell
                let user = data.realTimeUsers[indexPath.row]
                cell.delegate = self
                cell.bind(user: user)
                return cell
            } else {
                return nil
            }
        }
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
        homeViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] data in
                    self.data = data
                    update()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func update() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserDTO>()
        snapshot.appendSections([.Recommendation, .Close, .RealTime])
        snapshot.appendItems(data.recommendedUsers, toSection: .Recommendation)
        snapshot.appendItems(data.closeUsers, toSection: .Close)
        snapshot.appendItems(data.realTimeUsers, toSection: .RealTime)
        dataSource.apply(snapshot, animatingDifferences: true) { [self] in
            isLoading = false
        }
    }

    @objc private func didTapAlarmImage() {
        navigationController?.pushAlarmViewController(current: self)
    }
}

extension HomeViewController: UITableViewDelegate {
    fileprivate enum Section {
        case Recommendation, Close, RealTime
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
        homeViewModel?.channel(user: user)
        navigationController?.pushUserSingleViewController(current: self)
    }

    func confirm(_ user: UserDTO?) -> Observable<Bool> {
        RequestConfirmViewBuilder.create(target: self, user: user)
    }

    func request(_ user: UserDTO?, animationDone: Observable<Void>) {
        homeViewModel?.request(user, animationDone: animationDone) { [self] message in
            toast(message: message)
        }
    }

    func poke(_ user: UserDTO?, onBegin: () -> Void) {
        homeViewModel?.poke(user, onBegin: onBegin, completion: { [self] message in
            toast(message: message)
        })
    }

    func rate(_ user: UserDTO?, score: Int) {
        homeViewModel?.rate(user, score: score) { [self] message in
            toast(message: message)
        }
    }

    func getStarRatingIRated(_ user: UserDTO?) -> StarRating? {
        homeViewModel?.getStarRatingIRated(user)
    }
}
