import Foundation
import RxSwift
import FirebaseAuth

class PostSingleModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var post: PostDTO?

    private var session: Session

    private var postService: PostService

    init(session: Session, postService: PostService) {
        self.session = session
        self.postService = postService
        subscribeChannel()
    }

    deinit {
        log.info("deinit post single model")
    }

    func publish() {
        if let post = post {
            observable.onNext(post)
        }
    }

    func observe() -> Observable<PostDTO> {
        observable
    }

    func subscribeChannel() {
        Channel
            .post
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] post in
                self.post = post
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func thumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let comment = comment else {
            return
        }
        if let index = comment.thumbDownUserIds?.firstIndex(where: { $0 == session.id }) {
            comment.thumbDownUserIds?.remove(at: index)
        }
        if (comment.thumbUpUserIds?.contains(session.id ?? "") == true) {
            if let index = comment.thumbUpUserIds?.firstIndex(where: { $0 == session.id }) {
                comment.thumbUpUserIds?.remove(at: index)
                deleteThumbUp(post: post, comment: comment, onError: onError)
            }
        } else {
            if comment.thumbUpUserIds?.firstIndex(where: { $0 == session.id }) == nil {
                comment.thumbUpUserIds?.append(session.id ?? "")
                createThumbUp(post: post, comment: comment, onError: onError)
            }
        }
        publish()
    }

    private func createThumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = auth.uid,
              let postId = post?.id,
              let commentId = comment?.id else {
            onError("댓글 좋아요 생성에 실패 하였습니다.")
            return
        }
        postService
            .createThumbUp(
                uid: uid,
                postId: postId,
                commentId: commentId
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully created thumb up..")
            }, onError: { err in
                onError("댓글 좋아요 생성에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func deleteThumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = auth.uid,
              let postId = post?.id,
              let commentId = comment?.id else {
            onError("댓글 좋아요 삭제에 실패 하였습니다.")
            return
        }
        postService
            .deleteThumbUp(
                uid: uid,
                postId: postId,
                commentId: commentId
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully deleted thumb up..")
            }, onError: { err in
                onError("댓글 좋아요 삭제에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    func thumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let comment = comment else {
            return
        }
        if let index = comment.thumbUpUserIds?.firstIndex(where: { $0 == session.id }) {
            comment.thumbUpUserIds?.remove(at: index)
        }
        if (comment.thumbDownUserIds?.contains(session.id ?? "") == true) {
            if let index = comment.thumbDownUserIds?.firstIndex(where: { $0 == session.id }) {
                comment.thumbDownUserIds?.remove(at: index)
                deleteThumbDown(post: post, comment: comment, onError: onError)
            }
        } else {
            if comment.thumbDownUserIds?.firstIndex(where: { $0 == session.id }) == nil {
                comment.thumbDownUserIds?.append(session.id ?? "")
                createThumbDown(post: post, comment: comment, onError: onError)
            }
        }
        publish()
    }

    private func createThumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = auth.uid,
              let postId = post?.id,
              let commentId = comment?.id else {
            onError("댓글 싫어요 생성에 실패 하였습니다.")
            return
        }
        postService
            .createThumbDown(
                uid: uid,
                postId: postId,
                commentId: commentId
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully created thumb down..")
            }, onError: { err in
                onError("댓글 싫어요 생성에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func deleteThumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = auth.uid,
              let postId = post?.id,
              let commentId = comment?.id else {
            onError("댓글 싫어요 삭제에 실패 하였습니다.")
            return
        }
        postService
            .deleteThumbDown(
                uid: uid,
                postId: postId,
                commentId: commentId
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully deleted thumb down..")
            }, onError: { err in
                onError("댓글 싫어요 삭제에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        guard let comment = comment else {
            return false
        }
        return comment.thumbUpUserIds?.firstIndex(where: { $0 == session.id }) != nil
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        guard let comment = comment else {
            return false
        }
        return comment.thumbDownUserIds?.firstIndex(where: { $0 == session.id }) != nil
    }

    func createComment(postId: String?,
                       commentId: String?,
                       comment: String,
                       onError: @escaping (_ message: String) -> Void) {
        // comment id can be nil when a parent comment is not applicable.
        guard let uid = auth.uid,
              let postId = post?.id else {
            onError("댓글 생성에 실패 하였습니다.")
            return
        }
        postService
            .createComment(
                uid: uid,
                postId: postId,
                commentId: commentId,
                comment: comment
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] createdComment in
                log.info("Successfully created comment..")
                if let commentId = commentId {
                    if let index = post?.comments?.firstIndex(where: { $0.id == commentId }) {
                        post?.comments?[index].comments?.insert(createdComment, at: 0)
                    }
                } else {
                    post?.comments?.insert(createdComment, at: 0)
                }
                publish()
            }, onError: { err in
                onError("댓글 생성에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    func favorite(onError: @escaping (_ message: String) -> Void) {
        if (isCurrentUserFavoritePost()) {
            deleteFavorite(post, onError: onError)
        } else {
            createFavorite(post, onError: onError)
        }
    }

    private func createFavorite(_ post: PostDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = auth.uid,
              let userId = session.id,
              let postId = post?.id else {
            return
        }
        if (post?.favoriteUserIds?.firstIndex(of: userId) == nil) {
            post?.favoriteUserIds?.append(userId)
        }
        publish()
        postService
            .createFavorite(uid: uid, postId: postId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully created post favorite..")
            }, onError: { [unowned self]  err in
                log.error(err)
                onError("게시물 좋아요 도중 에러가 발생 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func deleteFavorite(_ post: PostDTO?,
                                onError: @escaping (_ message: String) -> Void) {
        guard let uid = auth.uid,
              let userId = session.id,
              let postId = post?.id else {
            return
        }
        if let index = post?.favoriteUserIds?.firstIndex(of: userId) {
            post?.favoriteUserIds?.remove(at: index)
        }
        publish()
        postService
            .deleteFavorite(uid: uid, postId: postId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully deleted post favorite..")
            }, onError: { err in
                log.error(err)
                onError("게시물 좋아요 도중 에러가 발생 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    func isCurrentUserFavoritePost() -> Bool {
        guard let userId = session.id else {
            return false
        }
        return post?.favoriteUserIds?.firstIndex(of: userId) != nil
    }
}
