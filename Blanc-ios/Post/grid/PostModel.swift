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
            .do(onNext: { [unowned self] posts in
                posts.forEach({ post in
                    let author = post.author
                    author?.relationship = session.relationship(with: author)
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

    func favorite(post: PostDTO?, onError: @escaping () -> Void) {
        if ((post?.favoriteUserIds?.contains(session.id ?? "")) == true) {
            deleteFavorite(post, onError: onError)
        } else {
            createFavorite(post, onError: onError)
        }
    }

    private func createFavorite(_ post: PostDTO?, onError: @escaping () -> Void) {
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
            }, onError: { [unowned self] err in
                log.error(err)
                onError()
                publish()
            })
            .disposed(by: disposeBag)
    }

    private func deleteFavorite(_ post: PostDTO?, onError: (() -> Void)?) {
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
                onError?()
                publish()
            })
            .disposed(by: disposeBag)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        post?.favoriteUserIds?.firstIndex(of: session.id!) != nil
    }

    func sync(post: PostDTO?) {
        guard let post = post,
              let index = posts.firstIndex(where: { $0.id == post.id }) else {
            return
        }
        posts[index] = post
        publish()
    }
}
