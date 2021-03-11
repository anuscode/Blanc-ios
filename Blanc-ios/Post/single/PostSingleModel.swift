import Foundation
import RxSwift
import FirebaseAuth

class PostSingleModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var post: PostDTO?

    private var session: Session

    private var channel: Channel

    private var postService: PostService

    init(session: Session, channel: Channel, postService: PostService) {
        self.session = session
        self.channel = channel
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
        channel
            .observe(PostDTO.self)
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
        postService
            .createThumbUp(
                uid: session.uid,
                postId: post?.id,
                commentId: comment?.id
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
        postService
            .deleteThumbUp(
                uid: session.uid,
                postId: post?.id,
                commentId: comment?.id
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
        postService
            .createThumbDown(
                uid: session.uid,
                postId: post?.id,
                commentId: comment?.id
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
        postService
            .deleteThumbDown(
                uid: session.uid,
                postId: post?.id,
                commentId: comment?.id
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

    func createComment(postId: String?, commentId: String?, comment: String, onError: @escaping (_ message: String) -> Void) {
        postService
            .createComment(
                uid: auth.uid,
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
        if ((post?.favoriteUserIds?.contains(session.id ?? "")) == true) {
            deleteFavorite(post, onError: onError)
        } else {
            createFavorite(post, onError: onError)
        }
    }

    private func createFavorite(_ post: PostDTO?, onError: @escaping (_ message: String) -> Void) {
        postService
            .createFavorite(uid: session.uid, postId: post?.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] _ in
                if (session.id == nil) {
                    return
                }
                if (post?.favoriteUserIds?.firstIndex(of: session.id!) == nil) {
                    post?.favoriteUserIds?.append(session.id!)
                }
                publish()
            }, onError: { [unowned self]  err in
                log.error(err)
                onError("게시물 좋아요 도중 에러가 발생 하였습니다.")
                publish()
            })
            .disposed(by: disposeBag)
    }

    private func deleteFavorite(_ post: PostDTO?, onError: @escaping (_ message: String) -> Void) {
        postService
            .deleteFavorite(uid: session.uid, postId: post?.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] _ in
                if (session.id == nil) {
                    return
                }
                if let index = post?.favoriteUserIds?.firstIndex(of: session.id!) {
                    post?.favoriteUserIds?.remove(at: index)
                }
                publish()
            }, onError: { [unowned self] err in
                log.info(err)
                onError("게시물 좋아요 도중 에러가 발생 하였습니다.")
                publish()
            })
            .disposed(by: disposeBag)
    }

    func isAuthorFavoriteComment(post: PostDTO?, comment: CommentDTO?) -> Bool {
        guard let post = post,
              let comment = comment else {
            return false
        }
        return comment.thumbUpUserIds?.firstIndex(where: { $0 == post.author?.id }) != nil
    }

    func isCurrentUserFavoritePost() -> Bool {
        post?.favoriteUserIds?.firstIndex(of: session.id!) != nil
    }
}
