import Foundation
import RxSwift
import FirebaseAuth

class PostSingleViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    private var post: PostDTO?

    private var session: Session

    private var postSingleModel: PostSingleModel

    private var postModel: PostModel

    init(session: Session, postSingleModel: PostSingleModel, postModel: PostModel) {
        self.session = session
        self.postSingleModel = postSingleModel
        self.postModel = postModel
        subscribePostSingleModel()
    }

    func publish() {
        if (post == nil) {
            return
        }
        observable.onNext(post!)
    }

    func observe() -> Observable<PostDTO> {
        observable
    }

    private func subscribePostSingleModel() {
        postSingleModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] post in
                    self.post = post
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func thumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        postSingleModel.thumbUp(post: post, comment: comment, onError: onError)
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        postSingleModel.isThumbedUp(comment: comment)
    }

    func thumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        postSingleModel.thumbDown(post: post, comment: comment, onError: onError)
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        postSingleModel.isThumbedDown(comment: comment)
    }

    func isAuthorFavoriteComment(post: PostDTO?, comment: CommentDTO?) -> Bool {
        postSingleModel.isAuthorFavoriteComment(post: post, comment: comment)
    }

    func createComment(postId: String?, commentId: String?, comment: String, onError: @escaping (_ message: String?) -> Void) {
        postSingleModel.createComment(postId: postId, commentId: commentId, comment: comment, onError: onError)
    }

    func favorite(onBefore: @escaping () -> Void, onError: @escaping () -> Void) {
        postSingleModel.favorite(onBefore: onBefore, onError: onError)
    }

    func isCurrentUserFavoritePost() -> Bool {
        postSingleModel.isCurrentUserFavoritePost()
    }

    func sync() {
        postModel.sync(post: post)
    }
}
