import Foundation
import RxSwift

class PostViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[PostDTO]>.create(bufferSize: 1)

    private var posts: [PostDTO] = []

    private let postModel: PostModel

    private var session: Session

    init(postModel: PostModel, session: Session) {
        self.postModel = postModel
        self.session = session
        subscribePostModel()
    }

    func observe() -> Observable<[PostDTO]> {
        observable
    }

    private func publish() {
        observable.onNext(posts)
    }

    private func subscribePostModel() {
        postModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] posts in
                    self.posts = posts
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func populate() {
        postModel.populate()
    }

    func favorite(post: PostDTO?, onBefore: @escaping () -> Void, onError: @escaping () -> Void) {
        postModel.favorite(post: post, onBefore: onBefore, onError: onError)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        postModel.isCurrentUserFavoritePost(post)
    }
}
