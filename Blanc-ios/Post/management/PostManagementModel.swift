import Foundation
import RxSwift
import FirebaseAuth

class PostManagementModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[PostDTO]>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var posts: [PostDTO] = []

    private var session: Session

    private var userService: UserService

    private var postService: PostService

    init(session: Session, userService: UserService, postService: PostService) {
        self.session = session
        self.userService = userService
        self.postService = postService
        populate()
    }

    func publish() {
        observable.onNext(posts)
    }

    func observe() -> Observable<[PostDTO]> {
        observable
    }

    private func populate() {
        userService
            .listAllUserPosts(uid: session.uid, userId: session.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] posts in
                self.posts = posts
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func favorite(post: PostDTO?, onError: (() -> Void)?) {
        if ((post?.favoriteUserIds?.contains(session.id ?? "")) == true) {
            deleteFavorite(post, onError: onError)
        } else {
            createFavorite(post, onError: onError)
        }
    }

    private func createFavorite(_ post: PostDTO?, onError: (() -> Void)?) {
        postService
            .createFavorite(uid: session.uid, postId: post?.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] _ in
                guard let userId = session.id else {
                    return
                }
                if (post?.favoriteUserIds?.firstIndex(of: userId) == nil) {
                    post?.favoriteUserIds?.append(userId)
                }
                publish()
            }, onError: { err in
                log.info(err)
                onError?()
                self.publish()
            })
            .disposed(by: disposeBag)
    }

    private func deleteFavorite(_ post: PostDTO?, onError: (() -> Void)?) {
        guard let uid = session.uid,
              let postId = post?.id else {
            return
        }
        postService
            .deleteFavorite(uid: uid, postId: postId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] _ in
                guard let userId = session.id else {
                    return
                }
                if let index = post?.favoriteUserIds?.firstIndex(of: userId) {
                    post?.favoriteUserIds?.remove(at: index)
                }
                publish()
            }, onError: { err in
                log.info(err)
                onError?()
                self.publish()
            })
            .disposed(by: disposeBag)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        post?.favoriteUserIds?.firstIndex(of: session.id!) != nil
    }

    // MARK - HANDLE COMMENT

    func thumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        if (comment == nil) {
            return
        }

        if let index = comment!.thumbDownUserIds?.firstIndex(where: { $0 == session.id }) {
            comment!.thumbDownUserIds?.remove(at: index)
        }

        if (comment!.thumbUpUserIds?.contains(session.id ?? "") == true) {
            if let index = comment!.thumbUpUserIds?.firstIndex(where: { $0 == session.id }) {
                comment!.thumbUpUserIds?.remove(at: index)
                deleteThumbUp(post: post, comment: comment, onError: onError)
            }
        } else {
            if comment!.thumbUpUserIds?.firstIndex(where: { $0 == session.id }) == nil {
                comment!.thumbUpUserIds?.append(session.id ?? "")
                createThumbUp(post: post, comment: comment, onError: onError)
            }
        }

        publish()
    }

    private func createThumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = session.uid,
              let postId = post?.id,
              let commentId = comment?.id else {
            return
        }
        postService
            .createThumbUp(uid: uid, postId: postId, commentId: commentId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { _ in
                log.info("Successfully created thumb up..")
            }, onError: { err in
                onError("댓글 좋아요 생성에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func deleteThumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = session.uid,
              let postId = post?.id,
              let commentId = comment?.id else {
            return
        }
        postService
            .deleteThumbUp(uid: uid, postId: postId, commentId: commentId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { _ in
                log.info("Successfully deleted thumb up..")
            }, onError: { err in
                onError("댓글 좋아요 삭제에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    func thumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        if (comment == nil) {
            return
        }

        if let index = comment!.thumbUpUserIds?.firstIndex(where: { $0 == session.id }) {
            comment!.thumbUpUserIds?.remove(at: index)
        }

        if (comment!.thumbDownUserIds?.contains(session.id ?? "") == true) {
            if let index = comment!.thumbDownUserIds?.firstIndex(where: { $0 == session.id }) {
                comment!.thumbDownUserIds?.remove(at: index)
                deleteThumbDown(post: post, comment: comment, onError: onError)
            }
        } else {
            if comment!.thumbDownUserIds?.firstIndex(where: { $0 == session.id }) == nil {
                comment!.thumbDownUserIds?.append(session.id ?? "")
                createThumbDown(post: post, comment: comment, onError: onError)
            }
        }
        publish()
    }

    private func createThumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = session.uid,
              let postId = post?.id,
              let commentId = comment?.id else {
            return
        }
        postService
            .createThumbDown(uid: uid, postId: postId, commentId: commentId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { _ in
                log.info("Successfully created thumb down..")
            }, onError: { err in
                onError("댓글 싫어요 생성에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func deleteThumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        guard let uid = session.uid,
              let postId = post?.id,
              let commentId = comment?.id else {
            return
        }
        postService
            .deleteThumbDown(uid: uid, postId: postId, commentId: commentId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
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

    func isAuthorFavoriteComment(post: PostDTO?, comment: CommentDTO?) -> Bool {
        guard let post = post,
              let comment = comment else {
            return false
        }
        return comment.thumbUpUserIds?.firstIndex(where: { $0 == post.author?.id }) != nil
    }

    func createComment(postId: String?,
                       commentId: String?,
                       comment: String,
                       onError: @escaping (_ message: String?) -> Void) {
        guard let uid = auth.uid,
              let post = posts.first(where: { $0.id == postId }) else {
            onError("코멘트 생성에 실패 하였습니다.")
            return
        }
        postService
            .createComment(uid: uid, postId: postId, commentId: commentId, comment: comment)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] createdComment in
                if let commentId = commentId {
                    if let index = post.comments?.firstIndex(where: { $0.id == commentId }) {
                        post.comments?[index].comments?.insert(createdComment, at: 0)
                    }
                } else {
                    post.comments?.insert(createdComment, at: 0)
                }
                publish()
                log.info("Successfully created comment..")
            }, onError: { err in
                onError("댓글 생성에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    func deletePost(postId: String?, onError: @escaping () -> Void) {
        postService
            .deletePost(uid: session.uid, postId: postId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { _ in
                if let index = self.posts.firstIndex(where: { $0.id == postId }) {
                    self.posts.remove(at: index)
                    self.publish()
                }
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }
}
