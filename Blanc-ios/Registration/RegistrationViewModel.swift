import Foundation
import RxSwift


class RegistrationViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private let registrationModel: RegistrationModel

    private var user: UserDTO?

    init(registrationModel: RegistrationModel) {
        self.registrationModel = registrationModel
        subscribeRegistrationModel()
    }

    private func publish() {
        if (user == nil) {
            return
        }
        observable.onNext(user!)
    }

    func observe() -> Observable<UserDTO> {
        observable
    }

    private func subscribeRegistrationModel() {
        registrationModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { user in
                    self.user = user
                    self.publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func updateUserProfile(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        registrationModel.updateUserProfile(onSuccess: onSuccess, onError: onError)
    }

    func uploadUserImage(index: Int?, file: UIImage, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        registrationModel.uploadUserImage(index: index, file: file, onSuccess: onSuccess, onError: onError)
    }

    func deleteUserImage(index: Int) {
        registrationModel.deleteUserImage(index: index)
    }

    func updateUserStatusPending(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        registrationModel.updateUserStatusPending(onSuccess: onSuccess, onError: onError)
    }

}
