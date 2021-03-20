import Foundation
import RxSwift

class SendingModel {

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
        userService
            .listUsersIRatedHigh(uid: session.uid, userId: session.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onNext: { [unowned self] users in
                users.distance(session)
            })
            .subscribe(onSuccess: { [unowned self] users in
                self.users = users
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func append(user: UserDTO?) {
        guard let user = user else {
            return
        }
        if (users.firstIndex(where: { $0.id == user.id }) == nil) {
            users.insert(user, at: 0)
            publish()
        }
    }
}
