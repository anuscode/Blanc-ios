import FirebaseAuth
import Foundation
import RxSwift


class FavoriteUserListModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[UserDTO]>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var users: [UserDTO] = []

    private var session: Session

    private var channel: Channel

    private var userService: UserService

    private var postService: PostService

    init(session: Session, channel: Channel, userService: UserService, postService: PostService) {
        self.session = session
        self.channel = channel
        self.userService = userService
        self.postService = postService
        subscribeChannel()
    }

    private func publish() {
        observable.onNext(users)
    }

    func observe() -> Observable<[UserDTO]> {
        observable
    }

    private func subscribeChannel() {
        channel.observe(PostDTO.self)
                .take(1)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] post in
                    populate(post: post)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func populate(post: PostDTO?) {
        postService.listAllFavoriteUsers(uid: session.uid, postId: post?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] users in
                    self.users = users
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func channel(user: UserDTO?) {
        if (user == nil) {
            return
        }
        channel.next(value: user!)
    }
}
