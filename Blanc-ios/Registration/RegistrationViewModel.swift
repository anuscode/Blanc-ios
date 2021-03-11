import Foundation
import RxSwift


class RegistrationViewModel {

    private class Repository {
        var user: UserDTO?
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let registrationModel: RegistrationModel

    private var repository: Repository = Repository()

    let user: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    let loading: PublishSubject = PublishSubject<Bool>()

    let toast: PublishSubject = PublishSubject<String>()

    let imagesClickable: PublishSubject = PublishSubject<Bool>()

    let next: PublishSubject = PublishSubject<Void>()

    init(registrationModel: RegistrationModel) {
        self.registrationModel = registrationModel
        subscribeRegistrationModel()
    }

    func update() {
        registrationModel.publish()
    }

    private func subscribeRegistrationModel() {
        registrationModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] user in
                self.user.onNext(user)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func updateUserProfile() {
        let onSuccess = {
            self.next.onNext(Void())
        }
        let onError = {
            self.toast.onNext("유저 프로필 업데이트 중 에러가 발생 하였습니다.")
        }
        registrationModel.updateUserProfile(onSuccess: onSuccess, onError: onError)
    }

    func uploadUserImage(index: Int?, file: UIImage) {
        let onSuccess = { [unowned self] in
            loading.onNext(false)
            imagesClickable.onNext(true)
        }
        let onError = { [unowned self] in
            loading.onNext(false)
            imagesClickable.onNext(true)
            toast.onNext("이미지 업로드에 실패 하였습니다.")
        }
        registrationModel.uploadUserImage(index: index, file: file, onSuccess: onSuccess, onError: onError)
    }

    func deleteUserImage(index: Int) {
        registrationModel.deleteUserImage(index: index)
    }

    func updateUserStatusPending() {
        let onSuccess = {
            self.loading.onNext(false)
            self.next.onNext(Void())
        }
        let onError = {
            self.loading.onNext(false)
            self.toast.onNext("심사 요청에 실패 하였습니다.")
        }
        registrationModel.updateUserStatusPending(onSuccess: onSuccess, onError: onError)
    }

    func unregister(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        registrationModel.unregister(onSuccess: onSuccess, onError: onError)
    }
}
