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

    private var dataSource: DataSource<Section, PostDTO>!

    private var posts: [PostDTO] = []

    internal var postViewModel: PostViewModel?

    internal var scrollToRow: Int?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "그램"))
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.register(ResourceTableViewCell.self, forCellReuseIdentifier: ResourceTableViewCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.delegate = self
        return tableView
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

    deinit {
        log.info("deinit post list view controller..")
    }

    public func prepare() {
        configureTableView()
        subscribePostViewModel()
    }

    private func configureSubviews() {
        view.addSubview(tableView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribePostViewModel() {
        postViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] posts in
                self.posts = posts.enumerated()
                    .filter { index, item in
                        index >= scrollToRow ?? 0
                    }.map {
                        $1
                    }
                update(self.posts)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)

        postViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
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
        dataSource = DataSource<Section, PostDTO>(tableView: tableView) { (tableView, indexPath, post) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: ResourceTableViewCell.identifier,
                for: indexPath) as! ResourceTableViewCell
            cell.bind(post: post, headerDelegate: self, bodyDelegate: self)
            return cell
        }
        tableView.dataSource = dataSource
    }

    private func update(_ posts: [PostDTO]) {
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
        postViewModel?.favorite(post: post)
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
        postViewModel?.isCurrentUserFavoritePost(post) == true
    }
}

extension PostListViewController: PostListHeaderDelegate {

    func goUserSingle(user: UserDTO?) -> Void {
        guard let user = user else {
            return
        }
        Channel.next(user: user)
        navigationController?.pushViewController(.userSingle, current: self)
    }

    func showOptions(user: UserDTO?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "신고", style: .default) { [unowned self] (action) in
            guard let user = user else {
                return
            }
            Channel.next(reportee: user)
            navigationController?.pushViewController(
                .report,
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
