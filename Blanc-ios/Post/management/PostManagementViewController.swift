import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Hero

private typealias DataSource = UITableViewDiffableDataSource
private typealias PostCell = PostManagementTableViewCell
private typealias CommentCell = CommentTableViewCell


class PostManagementViewController: UIViewController {

    private var disposeBag: DisposeBag = DisposeBag()

    private var data: [AnyHashable] = []

    private var replyTo: CommentDTO?

    internal var session: Session?

    internal var postManagementViewModel: PostManagementViewModel?

    lazy private var dataSource: DataSource<Section, AnyHashable> = DataSource<Section, AnyHashable>(tableView: tableView) { [unowned self] (tableView, indexPath, data) -> UITableViewCell? in
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
        return UITableViewCell()
    }

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "내 게시물 관리"))
    }()

    lazy private var emptyView: EmptyView = {
        let emptyView = EmptyView(animationName: "girl_with_phone", animationSpeed: 1)
        emptyView.primaryText = "게시물이 존재하지 않습니다."
        emptyView.secondaryText = "첫번째 게시물을 작성해 보세요."
        emptyView.buttonText = "메인 화면으로"
        emptyView.didTapButtonDelegate = {
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

    lazy private var bottomTextField: BottomTextView = {
        let view = BottomTextView()
        view.configure(avatar: session?.user?.avatar)
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
        navigationItem.backBarButtonItem = UIBarButtonItem.back
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
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func subscribePostViewModel() {
        postManagementViewModel?
            .posts
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] posts in
                data = posts.flatten().toArray()
                update()
            })
            .disposed(by: disposeBag)

        postManagementViewModel?
            .posts
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] posts in
                emptyView.visible(posts.count == 0)
            })
            .disposed(by: disposeBag)

        postManagementViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
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
        bottomTextField.visible(false)
        view.endEditing(true)
        replyTo = nil
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
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
        postManagementViewModel?.favorite(post: post)
    }

    func isFavoritePost(_ post: PostDTO?) -> Bool {
        postManagementViewModel?.isFavoritePost(post) == true
    }

    func presentFavoriteUserListView(_ post: PostDTO?) {
        guard let post = post else {
            return
        }
        Channel.next(post: post)
        navigationController?.pushViewController(
            .favoriteUsers,
            current: self,
            hideBottomWhenStart: true,
            hideBottomWhenEnd: true
        )
    }

    func deletePost(postId: String?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "게시물 삭제", style: .default) { (action) in
            self.postManagementViewModel?.deletePost(postId: postId)
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.modalPresentationStyle = .popover

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
}

extension PostManagementViewController: CommentTableViewCellDelegate {
    func thumbUp(comment: CommentDTO?) {
        let post = findParentPost(of: comment)
        postManagementViewModel?.thumbUp(post: post, comment: comment)
    }

    func thumbDown(comment: CommentDTO?) {
        let post = findParentPost(of: comment)
        postManagementViewModel?.thumbDown(post: post, comment: comment)
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        postManagementViewModel?.isThumbedUp(comment: comment) ?? false
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        postManagementViewModel?.isThumbedDown(comment: comment) ?? false
    }

    func isAuthorFavoriteComment(comment: CommentDTO?) -> Bool {
        guard let post = findParentPost(of: comment),
              let author = post.author,
              let comment = comment else {
            return false
        }
        return comment.thumbUpUserIds?.firstIndex(where: { $0 == author.id }) != nil
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
        let post = findParentPost(of: replyTo)
        postManagementViewModel?.createComment(postId: post?.id, commentId: replyTo?.id, comment: message)
        dismissTextField()
    }

    func dismiss() {
        dismissTextField()
    }
}

extension PostManagementViewController {
    func findParentPost(of comment: CommentDTO?) -> PostDTO? {
        var post: PostDTO?
        for item in data {
            if (item is PostDTO) {
                post = (item as! PostDTO)
                continue
            }
            if (item is CommentDTO) {
                let candidate = (item as! CommentDTO)
                if (comment?.id == candidate.id) {
                    break
                }
            }
        }
        return post
    }
}