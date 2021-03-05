import Foundation
import RxSwift


class RegistrationViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let registrationModel: RegistrationModel

    let user: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    init(registrationModel: RegistrationModel) {
        self.registrationModel = registrationModel
        subscribeRegistrationModel()
    }

    func update() {
        registrationModel.publish()
    }

    func observe() -> Observable<UserDTO> {
        user
    }

    private func subscribeRegistrationModel() {
        registrationModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { user in
                self.user.onNext(user)
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
