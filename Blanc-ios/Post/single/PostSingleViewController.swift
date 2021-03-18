import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard
import Lottie

class PostSingleViewController: UIViewController {

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
        tableView.register(PostSingleBodyTableViewCell.self, forCellReuseIdentifier: PostSingleBodyTableViewCell.identifier)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.separatorColor = .clear
        tableView.allowsSelection = false
        return tableView
    }()

    lazy private var bottomTextField: BottomTextField = {
        let view = BottomTextField()
        view.configure(avatarUrl: session?.user?.avatar)
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
        // should remove view model and model otherwise it shows the previous one.
        postSingleViewModel?.sync()
        navigationController?.setNavigationBarHidden(false, animated: animated)
        SwinjectStoryboard.defaultContainer.resetObjectScope(.postSingleScope)
    }

    deinit {
        log.info("deinit post single view controller..")
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

                let isFirst = self.post == nil
                let isThumbUpdates = self.post?.comments?.count == post.comments?.count
                let animatingDifferences: Bool = (!isFirst && !isThumbUpdates)
                update(animatingDifferences: animatingDifferences)
            })
            .disposed(by: disposeBag)

        postSingleViewModel?
            .post
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] post in
                if (post.enableComment == false) {
                    bottomTextField.placeHolder = "댓글이 금지 된 게시물 입니다."
                    bottomTextField.isEnabled = false
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

    fileprivate enum Section {
        case Post, Comments
    }

    private func configureTableViewDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, AnyHashable>(tableView: tableView) { [unowned self] (tableView, indexPath, item) -> UITableViewCell? in
            if let post = item as? PostDTO {
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: PostSingleBodyTableViewCell.identifier, for: indexPath) as? PostSingleBodyTableViewCell else {
                    return UITableViewCell()
                }
                cell.bind(post: post, delegate: self)
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

extension PostSingleViewController: PostSingleTableViewCellDelegate {
    func favorite() {
        postSingleViewModel?.favorite()
    }

    func isFavoritePost() -> Bool {
        postSingleViewModel?.isFavoritePost() ?? false
    }
}