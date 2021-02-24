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
        userService.listAllUserPosts(uid: session.uid, userId: session.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] posts in
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
        postService.createFavorite(uid: session.uid, postId: post?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] _ in
                    if (session.id == nil) {
                        return
                    }
                    if (post?.favoriteUserIds?.firstIndex(of: session.id!) == nil) {
                        post?.favoriteUserIds?.append(session.id!)
                    }
                    publish()
                }, onError: { [self] err in
                    log.info(err)
                    onError?()
                    publish()
                })
                .disposed(by: disposeBag)
    }

    private func deleteFavorite(_ post: PostDTO?, onError: (() -> Void)?) {
        postService.deleteFavorite(uid: session.uid, postId: post?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] _ in
                    if (session.id == nil) {
                        return
                    }
                    if let index = post?.favoriteUserIds?.firstIndex(of: session.id!) {
                        post?.favoriteUserIds?.remove(at: index)
                    }
                    publish()
                }, onError: { [self] err in
                    log.info(err)
                    onError?()
                    publish()
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
        postService.createThumbUp(uid: session.uid, postId: post?.id, commentId: comment?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] _ in
                    log.info("Successfully created thumb up..")
                }, onError: { err in
                    onError("댓글 좋아요 생성에 실패 하였습니다.")
                })
                .disposed(by: disposeBag)
    }

    private func deleteThumbUp(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        postService.deleteThumbUp(uid: session.uid, postId: post?.id, commentId: comment?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] _ in
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
        postService.createThumbDown(uid: session.uid, postId: post?.id, commentId: comment?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] _ in
                    log.info("Successfully created thumb down..")
                }, onError: { err in
                    onError("댓글 싫어요 생성에 실패 하였습니다.")
                })
                .disposed(by: disposeBag)
    }

    private func deleteThumbDown(post: PostDTO?, comment: CommentDTO?, onError: @escaping (_ message: String) -> Void) {
        postService.deleteThumbDown(uid: session.uid, postId: post?.id, commentId: comment?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] _ in
                    log.info("Successfully deleted thumb down..")
                }, onError: { err in
                    onError("댓글 싫어요 삭제에 실패 하였습니다.")
                })
                .disposed(by: disposeBag)
    }

    func isThumbedUp(comment: CommentDTO?) -> Bool {
        if (comment == nil) {
            return false
        }
        return comment!.thumbUpUserIds?.firstIndex(where: { $0 == session.id }) != nil
    }

    func isThumbedDown(comment: CommentDTO?) -> Bool {
        if (comment == nil) {
            return false
        }
        return comment!.thumbDownUserIds?.firstIndex(where: { $0 == session.id }) != nil
    }

    func isAuthorFavoriteComment(post: PostDTO?, comment: CommentDTO?) -> Bool {
        if (post == nil || comment == nil) {
            return false
        }
        return comment!.thumbUpUserIds?.firstIndex(where: { $0 == post?.author?.id }) != nil
    }

    func createComment(postId: String?, commentId: String?, comment: String, onError: @escaping (_ message: String?) -> Void) {

        let post = posts.first(where: { $0.id == postId })

        if (post == nil) {
            onError("코멘트 생성에 실패 하였습니다.")
            return
        }

        postService.createComment(uid: auth.uid, postId: postId, commentId: commentId, comment: comment)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] createdComment in
                    log.info("Successfully created comment..")
                    if (commentId != nil) {
                        if let index = post?.comments?.firstIndex(where: { $0.id == commentId }) {
                            post?.comments?[index].comments?.insert(createdComment, at: 0)
                        }
                    } else {
                        post?.comments?.insert(createdComment, at: 0)
                    }
                    publish()
                }, onError: { err in
                    onError("댓글 싫어요 삭제에 실패 하였습니다.")
                })
                .disposed(by: disposeBag)
    }

}
