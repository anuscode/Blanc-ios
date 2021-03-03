import Foundation
import RxSwift

class PendingViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let pendingModel: PendingModel

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private var userDTO: UserDTO?

    init(pendingModel: PendingModel) {
        self.pendingModel = pendingModel
        observeViewModel()
    }

    private func observeViewModel() {
        pendingModel.observe()
                .subscribe(onNext: { [unowned self] userDTO in
                    self.userDTO = userDTO
                    publish()
                    log.info(userDTO)
                }, onError: { err in
                    log.error(err)
                }).disposed(by: disposeBag)
    }

    func publish() {
        guard (userDTO != nil) else {
            return
        }
        observable.onNext(userDTO!)
    }

    func observe() -> Observable<UserDTO> {
        observable.asObservable()
    }

    func update() {
        pendingModel.update()
    }

    func updateUserProfile() -> Single<Void> {
        return pendingModel.updateUserProfile()
    }

    func uploadUserImage(index: Int?, file: UIImage) -> Single<ImageDTO> {
        return pendingModel.uploadUserImage(index: index, file: file)
    }

    func deleteUserImage(index: Int) {
        pendingModel.deleteUserImage(index: index)
    }

    func updateUserStatusPending() -> Single<UserDTO> {
        pendingModel.updateUserStatusPending()
    }

    func getNextEmpty() -> Empty? {
        return pendingModel.nextEmpty()
    }

}
