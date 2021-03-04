import Foundation
import RxSwift

class PostManagementViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[PostDTO]>.create(bufferSize: 1)

    private var posts: [PostDTO] = []

    private let postManagementModel: PostManagementModel

    private var session: Session

    init(session: Session, postManagementModel: PostManagementModel) {
        self.session = session
        self.postManagementModel = postManagementModel
        subscribePostManagementModel()
    }

    func observe() -> Observable<[PostDTO]> {
        observable
    }

    private func publish() {
        observable.onNext(posts)
    }

    private func subscribePostManagementModel() {
        postManagementModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] posts in
                    self.posts = posts
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func favorite(post: PostDTO?, onError: (() -> Void)?) {
        postManagementModel.favorite(post: post, onError: onError)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        postManagementModel.isCurrentUserFavoritePost(post)
    }

    func thumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        postManagementModel.thumbUp(post: post, comment: comment, onError: onError)
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        postManagementModel.isThumbedUp(comment: comment)
    }

    func thumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        postManagementModel.thumbDown(post: post, comment: comment, onError: onError)
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        postManagementModel.isThumbedDown(comment: comment)
    }

    func isAuthorFavoriteComment(post: PostDTO?, comment: CommentDTO?) -> Bool {
        postManagementModel.isAuthorFavoriteComment(post: post, comment: comment)
    }

    func createComment(postId: String?, commentId: String?, comment: String, onError: @escaping (_ message: String?) -> Void) {
        postManagementModel.createComment(postId: postId, commentId: commentId, comment: comment, onError: onError)
    }

    func deletePost(postId: String?, onError: @escaping () -> Void) {
        postManagementModel.deletePost(postId: postId, onError: onError)
    }
}
