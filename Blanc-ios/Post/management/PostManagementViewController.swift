import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Hero

private typealias DataSource = UITableViewDiffableDataSource
private typealias PostCell = PostManagementTableViewCell
private typealias CommentCell = CommentTableViewCell


private extension Array where Element: Postable {
    func findApplicablePost(comment: CommentDTO?) -> PostDTO? {
        var postIndices: [Int] = []
        var commentIndex: Int = 0

        enumerated().forEach { (i: Int, v: Element) in
            if (v is PostDTO) {
                postIndices.append(i)
            }
            if (v === comment) {
                commentIndex = i
            }
        }

        let postIndex = postIndices.filter {
            $0 < commentIndex
        }.max()

        return postIndex != nil ? self[postIndex!] as! PostDTO : nil
    }
}

class PostManagementViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var data: [Postable] = []

    private var replyTo: CommentDTO?

    var channel: Channel?

    var session: Session?

    var postManagementViewModel: PostManagementViewModel?

    lazy private var dataSource: DataSource<Section, Postable> = DataSource<Section, Postable>(tableView: tableView) { [unowned self] (tableView, indexPath, data) -> UITableViewCell? in
        if (data is PostDTO) {
            let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as! PostCell
            cell.bind(post: (data as! PostDTO), delegate: self)
            return cell
        }

        if (data is CommentDTO) {
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath) as! CommentCell
            cell.bind(comment: (data as! CommentDTO), delegate: self)
            return cell
        }

        return nil
    }

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "내 게시물 관리"))
    }()

    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView(animationName: "girl_with_phone", animationSpeed: 1)
        emptyView.primaryText = "앗!? 관리 가능한 게시물이\n존재하지 않습니다."
        emptyView.secondaryText = "나의 게시물은 이곳에서 관리 할 수 있습니다."
        emptyView.buttonText = "메인 화면으로.."
        emptyView.didTapButtonDelegate = { [unowned self] in
            self.navigationController?.popToRootViewController(animated: true)
        };
        emptyView.visible(false)
        return emptyView
    }()

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.identifier)
        tableView.register(CommentCell.self, forCellReuseIdentifier: CommentCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        return tableView
    }()

    lazy private var bottomTextField: BottomTextField = {
        let view = BottomTextField()
        view.configure(avatarUrl: session?.user?.avatar)
        view.configure(delegate: self)
        view.visible(false)
        return view
    }()

    lazy private var closeTapBackground: UIView = {
        let view = UIView()
        view.visible(false)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(dismissTextField))
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = leftBarButtonItem
        navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.barTintColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                name: UIResponder.keyboardWillHideNotification, object: nil)
        configureSubviews()
        configureConstraints()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SwinjectStoryboard.defaultContainer.resetObjectScope(.postManagementScope)
    }

    public func prepare() {
        configureTableView()
        subscribePostViewModel()
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(closeTapBackground)
        view.addSubview(bottomTextField)
        view.addSubview(emptyView)
    }

    private func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bottomTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        closeTapBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.center.equalToSuperview()
        }
    }

    private func subscribePostViewModel() {
        postManagementViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] posts in
                    data = PostDTO.flatten(posts: posts).toArray()
                    DispatchQueue.main.async {
                        update()
                        emptyView.visible(data.count == 0)
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                let window = UIApplication.shared.keyWindow
                view.frame.origin.y -= (keyboardSize.height - (window?.safeAreaInsets.bottom ?? 0))
            }
            closeTapBackground.visible(true)
        }
    }

    @objc private func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }

    @objc private func dismissTextField() {
        closeTapBackground.visible(false)
        bottomTextField.dismiss()
        view.endEditing(true)
        replyTo = nil
        bottomTextField.visible(false)
    }
}

extension PostManagementViewController {

    fileprivate enum Section {
        case main
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    private func update() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Postable>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }
}

extension PostManagementViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CoreGraphics.CGFloat {
        let item = data[indexPath.row]
        if item is PostDTO {
            let post = item as! PostDTO
            if ((post.resources?.count ?? 0) > 0) {
                return UIScreen.main.bounds.size.width + 150
            } else {
                return 150
            }
        } else {
            return 100
        }
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
}

extension PostManagementViewController: PostManagementTableViewCellDelegate {

    func favorite(_ post: PostDTO?) {
        postManagementViewModel?.favorite(post: post) { [unowned self] in
            toast(message: "좋아요 도중 에러가 발생 하였습니다.")
        }
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        postManagementViewModel?.isCurrentUserFavoritePost(post) == true
    }

    func presentFavoriteUserListView(_ post: PostDTO?) {
        if (post == nil) {
            return
        }
        channel?.next(value: post!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(
                withIdentifier: "FavoriteUserListViewController") as! FavoriteUserListViewController
        hidesBottomBarWhenPushed = true
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        backBarButtonItem.tintColor = .black
        navigationItem.backBarButtonItem = backBarButtonItem
        navigationController?.pushViewController(vc, animated: true)
    }

    private func channel(post: PostDTO?) {
        if (post == nil) {
            return
        }
        channel?.next(value: post!)
    }
}

extension PostManagementViewController: CommentTableViewCellDelegate {
    func thumbUp(comment: CommentDTO?) {
        let post = data.findApplicablePost(comment: comment)
        postManagementViewModel?.thumbUp(post: post, comment: comment, onError: { [unowned self] message in
            toast(message: message)
        })
    }

    func thumbDown(comment: CommentDTO?) {
        let post = data.findApplicablePost(comment: comment)
        postManagementViewModel?.thumbDown(post: post, comment: comment, onError: { [unowned self] message in
            toast(message: message)
        })
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        postManagementViewModel?.isThumbedUp(comment: comment) ?? false
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        postManagementViewModel?.isThumbedDown(comment: comment) ?? false
    }

    func isAuthorFavoriteComment(comment: CommentDTO?) -> Bool {
        let post = data.findApplicablePost(comment: comment)
        return postManagementViewModel?.isAuthorFavoriteComment(post: post, comment: comment) ?? false
    }

    func reply(comment: CommentDTO?) {
        bottomTextField.visible(true)
        bottomTextField.becomeFirstResponder()
        replyTo = comment
        bottomTextField.configure(replyTo: comment)
    }
}

extension PostManagementViewController: BottomTextFieldDelegate {
    func trigger(message: String) {
        let post = data.findApplicablePost(comment: replyTo)
        postManagementViewModel?.createComment(postId: post?.id, commentId: replyTo?.id, comment: message, onError: { [unowned self] message in
            toast(message: message)
        })
        dismissTextField()
    }

    func dismiss() {
        dismissTextField()
    }
}