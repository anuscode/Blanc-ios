import Foundation
import RxSwift

class PostViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[PostDTO]>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    private var posts: [PostDTO] = []

    private let postModel: PostModel

    private var session: Session

    init(postModel: PostModel, session: Session) {
        self.postModel = postModel
        self.session = session
        subscribePostModel()
    }

    deinit {
        log.info("deinit post view model..")
    }

    func observe() -> Observable<[PostDTO]> {
        observable
    }

    private func publish() {
        observable.onNext(posts)
    }

    private func subscribePostModel() {
        postModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] posts in
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

    func favorite(post: PostDTO?) {
        let onError = { [unowned self] in
            toast.onNext("좋아요 업데이트 도중 에러가 발생 하였습니다.")
        }
        postModel.favorite(post: post, onError: onError)
    }

    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool {
        postModel.isCurrentUserFavoritePost(post)
    }
}
