import UIKit
import RxSwift
import SwinjectStoryboard

class AlarmViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var dataSource: UITableViewDiffableDataSource<Section, PushDTO>!

    private var pushes: [PushDTO] = []

    internal weak var alarmViewModel: AlarmViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "알림"))
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(AlarmTableViewCell.self, forCellReuseIdentifier: AlarmTableViewCell.identifier)
        tableView.allowsSelection = true
        tableView.separatorColor = .clear
        tableView.delegate = self
        return tableView
    }()

    lazy private var loadingView: LoadingView = {
        let view = LoadingView()
        return view
    }()

    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView(animationName: "girl_with_phone", animationSpeed: 1)
        emptyView.primaryText = "생성 된 알림이 없습니다."
        emptyView.secondaryText = "이벤트 발생 시 이곳에서 확인 할 수 있습니다."
        emptyView.buttonText = "메인 화면으로.."
        emptyView.didTapButtonDelegate = {
            self.navigationController?.popViewController(animated: true)
        }
        emptyView.visible(false)
        return emptyView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        if (!emptyView.isHidden) {
            emptyView.play()
        }
        alarmViewModel?.updateAllAlarmsAsRead()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViewDataSource()
        configureSubviews()
        configureConstraints()
        subscribeAlarmViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        log.info("deinit AlarmViewController..")
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(emptyView)
        view.addSubview(loadingView)
    }

    private func configureConstraints() {

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        emptyView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribeAlarmViewModel() {
        alarmViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { pushes in
                self.pushes = pushes
                self.loadingView.visible(false)
                self.emptyView.visible(pushes.count == 0)
                self.update()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}

extension AlarmViewController {

    fileprivate enum Section {
        case Main
    }

    private func configureTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, PushDTO>(tableView: tableView) { (tableView, indexPath, push) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AlarmTableViewCell.identifier, for: indexPath) as? AlarmTableViewCell else {
                return UITableViewCell()
            }
            cell.bind(push: push)
            return cell
        }
        tableView.dataSource = dataSource
    }

    private func update(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PushDTO>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(pushes)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
    }
}


extension AlarmViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let push = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        if (push.isFavorite() || push.isComment()) {
            guard let postId = push.postId else {
                return
            }
            alarmViewModel?.getPost(postId: postId, onSuccess: { post in
                DispatchQueue.main.async {
                    Channel.next(post: post)
                    self.navigationController?.pushViewController(.postSingle, current: self)
                }
            }, onError: {
                self.toast(message: "게시물 정보를 가져오지 못했습니다.")
            })
            return
        }

        guard let userId = push.userId else {
            return
        }
        alarmViewModel?.getUser(userId: userId, onSuccess: { user in
            DispatchQueue.main.async {
                Channel.next(user: user)
                self.navigationController?.pushViewController(.userSingle, current: self)
            }
        }, onError: {
            self.toast(message: "유저 정보를 가져오지 못했습니다.")
        })
    }
}
