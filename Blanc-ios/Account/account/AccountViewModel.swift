import Foundation
import RxSwift

class AccountViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    let currentUser: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private weak var session: Session?

    init(session: Session) {
        self.session = session
        populate()
    }

    private func populate() {
        session?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] user in
                currentUser.onNext(user)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}
