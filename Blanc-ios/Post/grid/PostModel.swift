import Foundation
import RxSwift
import FirebaseAuth

class PostModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[PostDTO]>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var posts: [PostDTO] = []

    private var session: Session

    private var postService: PostService

    private var lastId: String? = nil

    init(session: Session, postService: PostService) {
        self.session = session
        self.postService = postService
        populate()
        subscribeSynchronize()
    }

    deinit {
        log.info("deinit post model..")
    }

    func publish() {
        observable.onNext(posts)
    }

    func observe() -> Observable<[PostDTO]> {
        observable
    }

    func populate() {
        let lastId = posts.last?.id ?? ""
        if (self.lastId == lastId) {
            log.info("Already reached last page.. canceling to load data.")
            return
        }
        self.lastId = lastId
        postService
            .listPosts(uid: session.uid, lastId: self.lastId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] posts in
                self.posts += posts
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func favorite(post: PostDTO?, onError: @escaping () -> Void) {
        if (isCurrentUserFavoritePost(post)) {
            deleteFavorite(post, onError: onError)
        } else {
            createFavorite(post, onError: onError)
        }
    }

    private func createFavorite(_ post: PostDTO?, onError: @escaping () -> Void) {
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
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    private func deleteFavorite(_ post: PostDTO?, onError: (() -> Void)?) {
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
                onError?()
            })
            .disposed(by: disposeBag)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        post?.favoriteUserIds?.firstIndex(of: session.id!) != nil
    }

    func subscribeSynchronize() {
        Synchronize
            .post
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] post in
                guard let index = posts.firstIndex(where: { $0.id == post.id }) else {
                    return
                }
                posts[index] = post
                publish()
            })
            .disposed(by: disposeBag)
    }
}
