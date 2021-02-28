import Foundation
import RxSwift

class AccountViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private let accountModel: AccountModel

    init(accountModel: AccountModel) {
        self.accountModel = accountModel
        subscribeAccountModel()
    }

    private func subscribeAccountModel() {
        accountModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { user in
                    self.observable.onNext(user)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func observe() -> Observable<UserDTO> {
        observable
    }
}
