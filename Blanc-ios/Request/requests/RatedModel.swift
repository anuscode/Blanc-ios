import Foundation
import RxSwift

class RatedModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[UserDTO]>.create(bufferSize: 1)

    private var session: Session

    private var userService: UserService

    private var users: [UserDTO] = []

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        populate()
    }

    func observe() -> Observable<[UserDTO]> {
        observable
    }

    private func publish() {
        observable.onNext(users)
    }

    private func populate() {
        userService.listUsersRatedMeHigh(uid: session.uid, userId: session.id)
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

    private func subscribeBroadcast() {
        Broadcast.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { push in
                    if (push.isStarRating()) {
                        self.appendUser(userId: push.userId)
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func appendUser(userId: String?) {
        userService.getUser(userId: userId)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { user in
                    self.users.insert(user, at: 0)
                    self.publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}
