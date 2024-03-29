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
        subscribeBroadcast()
        subscribeBackground()
    }

    func observe() -> Observable<[UserDTO]> {
        observable
    }

    private func publish() {
        observable.onNext(users)
    }

    private func populate() {
        userService
            .listUsersRatedMeHigh(uid: session.uid, userId: session.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onNext: { [unowned self] users in
                // loop to calculate and set a distance from current user.
                users.forEach({ user in
                    user.relationship = session.relationship(with: user)
                })
            })
            .subscribe(onSuccess: { [unowned self] users in
                self.users = users
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func subscribeBroadcast() {
        Broadcast
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] push in
                if (push.isStarRating()) {
                    appendUser(userId: push.userId)
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func subscribeBackground() {
        Background
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] push in
                populate()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func appendUser(userId: String?) {
        guard let userId = userId else {
            return
        }
        let parameters = ["id": userId ?? ""]
        userService
            .getUser(parameters: parameters)
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
