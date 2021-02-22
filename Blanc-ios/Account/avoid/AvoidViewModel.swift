import Foundation
import RxSwift

class AvoidViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[Contact]>.create(bufferSize: 1)

    private var contacts: [Contact] = []

    private let avoidModel: AvoidModel

    init(avoidModel: AvoidModel) {
        self.avoidModel = avoidModel
        subscribeAvoidModel()
    }

    func observe() -> Observable<[Contact]> {
        observable
    }

    private func publish() {
        observable.onNext(contacts)
    }

    private func subscribeAvoidModel() {
        avoidModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] contacts in
                    self.contacts = contacts
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func populate(onError: @escaping () -> Void) {
        avoidModel.populate(onError: onError)
    }

    func updateUserContacts(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        avoidModel.updateUserContacts(onSuccess: onSuccess, onError: onError)
    }

}
