import UIKit
import Moya
import RxSwift
import Foundation
import SwinjectStoryboard
import Lottie

class FavoriteUserListViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    private var dataSource: UITableViewDiffableDataSource<Section, UserDTO>!

    private var users: [UserDTO] = []

    internal var favoriteUserListViewModel: FavoriteUserListViewModel?

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

    lazy private var emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        let animationView = AnimationView()
        animationView.animation = Animation.named("bad_emoji")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()

        view.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(100).priority(800)
        }

        let mainLabel = UILabel()
        mainLabel.text = "현재 이 게시물을\n좋아하는 사람이 없습니다."
        mainLabel.textColor = .darkText
        mainLabel.numberOfLines = 2
        mainLabel.textAlignment = .center
        mainLabel.font = .systemFont(ofSize: 20)

        view.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }

        let secondaryLabel = UILabel()
        secondaryLabel.text = "먼저 다른 사람의 게시물에 좋아요를 눌러 보세요."
        secondaryLabel.textColor = .systemGray
        secondaryLabel.textAlignment = .center
        secondaryLabel.font = .systemFont(ofSize: 15)
        secondaryLabel.numberOfLines = 3

        view.addSubview(secondaryLabel)
        secondaryLabel.snp.makeConstraints { make in
            make.top.equalTo(mainLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        let button = UIView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapButton))
        ripple.activate(to: button)

        let buttonLabel = UILabel()
        buttonLabel.text = "뒤로가기"
        buttonLabel.textColor = .white
        buttonLabel.font = .boldSystemFont(ofSize: 16)

        button.addSubview(buttonLabel)
        buttonLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.top.equalTo(secondaryLabel.snp.bottom).offset(30)
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }

        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem.back
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
        view.addSubview(emptyView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(tableView.snp.edges)
        }
    }

    private func subscribeFavoriteUserListViewModel() {
        favoriteUserListViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] users in
                self.users = users
                update()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)

        favoriteUserListViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] users in
                let isEmpty = users.count == 0
                emptyView.visible(isEmpty)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapButton() {
        navigationController?.popViewController(animated: true)
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
        guard let user = user else {
            return
        }
        favoriteUserListViewModel?.channel(user: user)
        navigationController?.pushViewController(
            .userSingle,
            current: self,
            hideBottomWhenStart: true,
            hideBottomWhenEnd: true
        )
    }
}
