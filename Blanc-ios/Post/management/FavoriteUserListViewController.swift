import UIKit
import Moya
import RxSwift
import Foundation
import SwinjectStoryboard

class FavoriteUserListViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var dataSource: UITableViewDiffableDataSource<Section, UserDTO>!

    private var users: [UserDTO] = []

    var favoriteUserListViewModel: FavoriteUserListViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "좋아요 누른 사람 보기"))
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SmallUserProfileTableViewCell.self,
                forCellReuseIdentifier: SmallUserProfileTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        return tableView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.barTintColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableViewDataSource()
        configureSubviews()
        configureConstraints()
        subscribeFavoriteUserListViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwinjectStoryboard.defaultContainer.resetObjectScope(.favoriteUserListScope)
    }

    private func configureSubviews() {
        view.addSubview(tableView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func subscribeFavoriteUserListViewModel() {
        favoriteUserListViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { users in
                    self.users = users
                    DispatchQueue.main.async { [self] in
                        update()
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}

extension FavoriteUserListViewController {

    fileprivate enum Section {
        case Main
    }

    private func configureTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, UserDTO>(tableView: tableView) { (tableView, indexPath, user) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SmallUserProfileTableViewCell.identifier, for: indexPath) as? SmallUserProfileTableViewCell else {
                return UITableViewCell()
            }
            cell.bind(user: user, delegate: self)
            return cell
        }
        tableView.dataSource = dataSource
    }

    private func update(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UserDTO>()
        snapshot.appendSections([.Main])
        snapshot.appendItems(users)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
    }
}


extension FavoriteUserListViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
    }
}

extension FavoriteUserListViewController: SmallUserProfileTableViewCellDelegate {
    func presentUserSingleView(user: UserDTO?) {
        favoriteUserListViewModel?.channel(user: user)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
                withIdentifier: "UserSingleViewController") as! UserSingleViewController
        vc.modalPresentationStyle = .fullScreen
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        navigationController?.pushViewController(vc, animated: true)
    }
}
