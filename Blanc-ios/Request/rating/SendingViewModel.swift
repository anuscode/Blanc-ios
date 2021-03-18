import Foundation
import RxSwift

class SendingViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[UserDTO]>.create(bufferSize: 1)

    private let sendingModel: SendingModel

    private var users: [UserDTO] = []

    init(sendingModel: SendingModel) {
        self.sendingModel = sendingModel
        subscribeSendingModel()
    }

    private func publish() {
        observable.onNext(users)
    }

    func observe() -> Observable<[UserDTO]> {
        observable
    }

    private func subscribeSendingModel() {
        sendingModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] users in
                self.users = users
                publish()
            })
            .disposed(by: disposeBag)
    }

    func channel(user: UserDTO?) {
        sendingModel.channel(user: user)
    }
}
