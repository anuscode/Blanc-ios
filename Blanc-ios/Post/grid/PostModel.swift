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

        postService.listPosts(lastId: self.lastId)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .do(onNext: { posts in
                    posts.forEach({ post in
                        post.author?.distance = (post as PostDTO).author?.distance(
                                from: self.session.user, type: String.self)
                    })
                })
                .subscribe(onSuccess: { [unowned self] posts in
                    self.posts += posts
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func favorite(post: PostDTO?, onBefore: @escaping () -> Void, onError: @escaping () -> Void) {
        if ((post?.favoriteUserIds?.contains(session.id ?? "")) == true) {
            deleteFavorite(post, onError: onError)
        } else {
            onBefore()
            createFavorite(post, onError: onError)
        }
    }

    private func createFavorite(_ post: PostDTO?, onError: @escaping () -> Void) {
        postService.createFavorite(uid: session.uid, postId: post?.id)
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
                }, onError: { [unowned self] err in
                    log.error(err)
                    onError()
                    publish()
                })
                .disposed(by: disposeBag)
    }

    private func deleteFavorite(_ post: PostDTO?, onError: (() -> Void)?) {
        postService.deleteFavorite(uid: session.uid, postId: post?.id)
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
                    onError?()
                    publish()
                })
                .disposed(by: disposeBag)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        post?.favoriteUserIds?.firstIndex(of: session.id!) != nil
    }

    func sync(post: PostDTO?) {
        guard post != nil else {
            return
        }
        let index = posts.firstIndex {
            $0.id == post?.id
        }

        if (index != nil) {
            posts[index!] = post!
            publish()
        }
    }
}
