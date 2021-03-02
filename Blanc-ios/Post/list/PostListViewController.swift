import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Hero
import Lottie

private typealias DataSource = UITableViewDiffableDataSource
private typealias ResourceTableViewCell = PostListResourceTableViewCell

class PostListViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    lazy private var dataSource: DataSource<Section, PostDTO> = DataSource<Section, PostDTO>(tableView: tableView) { [self] (tableView, indexPath, post) -> UITableViewCell? in
        let cell = tableView.dequeueReusableCell(withIdentifier: ResourceTableViewCell.identifier,
                for: indexPath) as! ResourceTableViewCell
        cell.bind(post: post, headerDelegate: self, bodyDelegate: self)
        return cell
    }

    private var posts: [PostDTO] = []

    var channel: Channel?

    var postViewModel: PostViewModel?

    var scrollToRow: Int?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "그램"))
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.register(ResourceTableViewCell.self, forCellReuseIdentifier: ResourceTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        return tableView
    }()

    lazy private var favoriteLottie: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("heart_2_2")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 3
        return animationView
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
        configureSubviews()
        configureConstraints()
    }

    public func prepare() {
        configureTableView()
        subscribePostViewModel()
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(favoriteLottie)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribePostViewModel() {
        postViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] posts in
                    self.posts = posts.enumerated()
                            .filter { index, item in
                                index >= scrollToRow ?? 0
                            }.map {
                                $1
                            }
                    DispatchQueue.main.async {
                        update()
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}

extension PostListViewController {

    fileprivate enum Section {
        case main
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    private func update() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PostDTO>()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }
}


extension PostListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
}

extension PostListViewController: PostBodyDelegate {

    func favorite(post: PostDTO?) {
        postViewModel?.favorite(post: post,
                onBefore: {
                    self.favoriteLottie.begin(with: self.view, constraint: {
                        self.favoriteLottie.snp.makeConstraints { make in
                            make.edges.equalToSuperview()
                        }
                    })
                },
                onError: {
                    DispatchQueue.main.async {
                        self.toast(message: "좋아요 도중 에러가 발생 하였습니다.")
                    }
                })
    }

    func presentSinglePostView(post: PostDTO?) {
        channel(post: post)
        navigationController?.pushViewController(.postSingle, current: self)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        postViewModel?.isCurrentUserFavoritePost(post) == true
    }

    private func channel(post: PostDTO?) {
        guard post != nil else {
            return
        }
        channel?.next(value: post!)
    }
}

extension PostListViewController: PostHeaderDelegate {

    func didTapUserImage(user: UserDTO?) -> Void {
        channel(user: user)
        navigationController?.pushViewController(.userSingle, current: self)
    }

    private func channel(user: UserDTO?) {
        guard user != nil else {
            return
        }
        channel?.next(value: user!)
    }
}
