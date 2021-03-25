import Foundation
import RxSwift
import FirebaseAuth

class PostSingleViewModel {

    private class Repository {
        var post: PostDTO?
    }

    private let disposeBag: DisposeBag = DisposeBag()

    internal let post: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    private let repository: Repository = Repository()

    private var session: Session

    private var postSingleModel: PostSingleModel

    init(session: Session, postSingleModel: PostSingleModel) {
        self.session = session
        self.postSingleModel = postSingleModel
        subscribePostSingleModel()
    }

    deinit {
        log.info("deinit post single view model")
    }

    private func subscribePostSingleModel() {
        postSingleModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] post in
                repository.post = post
                self.post.onNext(post)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func thumbUp(post: PostDTO?, comment: CommentDTO?) {
        let onError = { [unowned self] message in
            toast.onNext(message)
        }
        postSingleModel.thumbUp(post: post, comment: comment, onError: onError)
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        postSingleModel.isThumbedUp(comment: comment)
    }

    func thumbDown(post: PostDTO?, comment: CommentDTO?) {
        let onError = { [unowned self] message in
            toast.onNext(message)
        }
        postSingleModel.thumbDown(post: post, comment: comment, onError: onError)
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        postSingleModel.isThumbedDown(comment: comment)
    }

    func createComment(postId: String?, commentId: String?, comment: String) {
        let onError = { [unowned self] message in
            toast.onNext(message)
        }
        postSingleModel.createComment(postId: postId, commentId: commentId, comment: comment, onError: onError)
    }

    func favorite() {
        let onError = { [unowned self] message in
            toast.onNext(message)
        }
        postSingleModel.favorite(onError: onError)
    }

    func isFavoritePost() -> Bool {
        postSingleModel.isCurrentUserFavoritePost()
    }

    func sync() {
        if let post = repository.post {
            Synchronize.next(post: post)
        }
    }
}
