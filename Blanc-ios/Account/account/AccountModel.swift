import Foundation
import RxSwift

class AccountModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private var session: Session

    private let userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        subscribeSession()
    }

    func observe() -> Observable<UserDTO> {
        observable
    }

    private func subscribeSession() {
        session.observe()
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { user in
                    self.observable.onNext(user)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}
