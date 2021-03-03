import Foundation
import RxSwift

class SendingModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[UserDTO]>.create(bufferSize: 1)

    private var session: Session

    private var channel: Channel

    private var userService: UserService

    private var users: [UserDTO] = []

    init(session: Session, channel: Channel, userService: UserService) {
        self.session = session
        self.channel = channel
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
        userService.listUsersIRatedHigh(uid: session.uid, userId: session.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] users in
                    self.users = users
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func channel(user: UserDTO?) {
        guard(user != nil) else {
            return
        }
        channel.next(value: user!)
    }

    func append(user: UserDTO?) {

        guard user != nil else {
            return
        }

        let isNotExist: Bool = users.firstIndex {
            $0.id == user?.id
        } == nil

        if (isNotExist) {
            users.insert(user!, at: 0)
            publish()
        }
    }
}
