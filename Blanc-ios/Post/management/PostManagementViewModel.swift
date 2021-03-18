import Foundation
import RxSwift

class PostManagementViewModel {

    private class Repository {
        var posts: [PostDTO] = []
    }

    private let disposeBag: DisposeBag = DisposeBag()

    internal let posts: ReplaySubject = ReplaySubject<[PostDTO]>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    private var repository: Repository = Repository()

    private let postManagementModel: PostManagementModel

    private var session: Session

    init(session: Session, postManagementModel: PostManagementModel) {
        self.session = session
        self.postManagementModel = postManagementModel
        subscribePostManagementModel()
    }

    private func publish() {
        posts.onNext(repository.posts)
    }

    private func subscribePostManagementModel() {
        postManagementModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] posts in
                repository.posts = posts
                publish()
            })
            .disposed(by: disposeBag)
    }

    func favorite(post: PostDTO?) {
        let onError = {
            self.toast.onNext("좋아요 도중 에러가 발생 하였습니다.")
        }
        postManagementModel.favorite(post: post, onError: onError)
    }

    func isFavoritePost(_ post: PostDTO?) -> Bool {
        postManagementModel.isFavoritePost(post)
    }

    func thumbUp(post: PostDTO?, comment: CommentDTO?) {
        let onError: (_ message: String) -> Void = { [unowned self] message in
            toast.onNext(message)
        }
        postManagementModel.thumbUp(post: post, comment: comment, onError: onError)
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        postManagementModel.isThumbedUp(comment: comment)
    }

    func thumbDown(post: PostDTO?, comment: CommentDTO?) {
        let onError: (_ message: String) -> Void = { [unowned self] message in
            toast.onNext(message)
        }
        postManagementModel.thumbDown(post: post, comment: comment, onError: onError)
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        postManagementModel.isThumbedDown(comment: comment)
    }

    func createComment(postId: String?, commentId: String?, comment: String) {
        let onError = { [unowned self] in
            toast.onNext("댓글 생성에 실패 하였습니다.")
        }
        postManagementModel.createComment(postId: postId, commentId: commentId, comment: comment, onError: onError)
    }

    func deletePost(postId: String?) {
        let onError = { [unowned self] in
            toast.onNext("포스트 삭제에 실패 하였습니다.")
        }
        postManagementModel.deletePost(postId: postId, onError: onError)
    }
}
