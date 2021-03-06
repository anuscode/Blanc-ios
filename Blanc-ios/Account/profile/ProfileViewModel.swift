import Foundation
import RxSwift

class ProfileViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let profileModel: ProfileModel

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private var user: UserDTO?

    init(profileModel: ProfileModel) {
        self.profileModel = profileModel
        observeViewModel()
    }

    private func observeViewModel() {
        profileModel.observe()
                .subscribe(onNext: { user in
                    self.user = user
                    self.publish()
                    log.info(user)
                }, onError: { err in
                    log.error(err)
                }).disposed(by: disposeBag)
    }

    func publish() {
        guard (user != nil) else {
            return
        }
        observable.onNext(user!)
    }

    func observe() -> Observable<UserDTO> {
        observable.asObservable()
    }

    func update() {
        profileModel.update()
    }

    func updateUserProfile() -> Single<Void> {
        profileModel.updateUserProfile()
    }

    func uploadUserImage(index: Int?, file: UIImage) -> Single<ImageDTO> {
        profileModel.uploadUserImage(index: index, file: file)
    }

    func deleteUserImage(index: Int) {
        profileModel.deleteUserImage(index: index)
    }

    func updateUserStatusPending() -> Single<UserDTO> {
        profileModel.updateUserStatusPending()
    }
}
