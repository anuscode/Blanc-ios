import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard
import Lottie

class PostSingleViewController: UIViewController {

    fileprivate enum Section {
        case Post, Comments
    }

    private class Const {
        static let navigationUserImageSize: Int = 28
        static let navigationUserLabelFont: UIFont = .systemFont(ofSize: 15)
        static let bottomViewHeight: Int = 55
        static let navigationUserImageCornerRadius: Int = {
            Const.navigationUserImageSize / 2
        }()
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let sections: [Section] = [.Post, .Comments]

    private var dataSource: UITableViewDiffableDataSource<Section, AnyHashable>!

    private let ripple: Ripple = Ripple()

    private var post: PostDTO?

    private var comments: [CommentDTO]?

    private var replyTo: CommentDTO?

    internal weak var session: Session?

    internal weak var postSingleViewModel: PostSingleViewModel?

    lazy private var leftBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(customView: LeftSideBarView(title: "그램"))
    }()

    lazy private var tableView: UITableView = {
        let tableView: UITableView = UITableView()
        // tableView.contentInsetAdjustmentBehavior = .never
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        // should use right size otherwise it will raise performance issue.
        tableView.estimatedRowHeight = 100
        tableView.register(PostSingleTableViewCell.self, forCellReuseIdentifier: PostSingleTableViewCell.identifier)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
        return tableView
    }()

    lazy private var bottomTextField: BottomTextView = {
        let view = BottomTextView()
        view.configure(avatar: session?.user?.avatar)
        view.configure(delegate: self)
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
        configureTableViewDataSource()
        subscribePostSingleViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    deinit {
        log.info("deinit post single view controller..")
        postSingleViewModel?.sync()
        SwinjectStoryboard.defaultContainer.resetObjectScope(.postSingleScope)
    }

    private func configureSubviews() {
        view.addSubview(tableView)
        view.addSubview(closeTapBackground)
        view.addSubview(bottomTextField)
    }

    private func configureConstraints() {

        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(bottomTextField.snp.top)
        }

        bottomTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        closeTapBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribePostSingleViewModel() {
        postSingleViewModel?
            .post
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] post in
                self.post = post
                comments = (post.comments?.flatten(post: post).toArray() as? [CommentDTO]) ?? [CommentDTO]()
                update(animatingDifferences: false)
            })
            .disposed(by: disposeBag)

        postSingleViewModel?
            .post
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] post in
                if (post.enableComment == false) {
                    bottomTextField.placeHolder = "댓글이 금지 된 게시물 입니다."
                    bottomTextField.isEditable = false
                }
            })
            .disposed(by: disposeBag)

        postSingleViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
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
        view.endEditing(true)
        replyTo = nil
    }
}

extension PostSingleViewController {

    private func configureTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, AnyHashable>(tableView: tableView) { [unowned self] (tableView, indexPath, item) -> UITableViewCell? in
            if let post = item as? PostDTO {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: PostSingleTableViewCell.identifier, for: indexPath) as? PostSingleTableViewCell else {
                    return UITableViewCell()
                }
                cell.bind(post: post, headerDelegate: self, bodyDelegate: self)
                return cell
            }
            if let comment = item as? CommentDTO {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else {
                    return UITableViewCell()
                }
                cell.bind(comment: comment, delegate: self)
                return cell
            }
            return nil
        }
        tableView.dataSource = dataSource
        dataSource.defaultRowAnimation = .left
    }

    private func update(animatingDifferences: Bool = false) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.Post, .Comments])
        snapshot.appendItems([post], toSection: .Post)
        snapshot.appendItems(comments ?? [], toSection: .Comments)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: nil)
    }
}

extension PostSingleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

extension PostSingleViewController: CommentTableViewCellDelegate {

    func thumbUp(comment: CommentDTO?) {
        postSingleViewModel?.thumbUp(post: post, comment: comment)
    }

    func thumbDown(comment: CommentDTO?) {
        postSingleViewModel?.thumbDown(post: post, comment: comment)
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        postSingleViewModel?.isThumbedUp(comment: comment) ?? false
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        postSingleViewModel?.isThumbedDown(comment: comment) ?? false
    }

    func isAuthorFavoriteComment(comment: CommentDTO?) -> Bool {
        guard let post = post,
              let author = post.author,
              let comment = comment else {
            return false
        }
        return comment.thumbUpUserIds?.firstIndex(where: { $0 == author.id }) != nil
    }

    func reply(comment: CommentDTO?) {
        replyTo = comment
        bottomTextField.configure(replyTo: comment)
    }
}

extension PostSingleViewController: BottomTextFieldDelegate {
    func trigger(message: String) {
        postSingleViewModel?.createComment(postId: post?.id, commentId: replyTo?.id, comment: message)
        dismissTextField()
    }

    func dismiss() {
        dismissTextField()
    }
}

extension PostSingleViewController: PostSingleHeaderDelegate {

    func goUserSingle(user: UserDTO?) {
        guard let user = user else {
            return
        }
        Channel.next(user: user)
        navigationController?.pushViewController(.userSingle, current: self)
    }

    func showOptions(post: PostDTO?) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "신고", style: .default) { [unowned self] (action) in
            guard let user = post?.author else {
                return
            }
            Channel.next(report: user)
            navigationController?.pushViewController(
                .reportUser,
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

extension PostSingleViewController: PostSingleBodyDelegate {
    func favorite() {
        postSingleViewModel?.favorite()
    }

    func isFavoritePost() -> Bool {
        postSingleViewModel?.isFavoritePost() ?? false
    }
}

