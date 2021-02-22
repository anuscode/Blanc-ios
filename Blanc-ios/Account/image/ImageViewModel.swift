import Foundation
import RxSwift

class ImageViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let imageModel: ImageModel

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private var userDTO: UserDTO?

    init(imageModel: ImageModel) {
        self.imageModel = imageModel
        subscribeImageViewModel()
    }

    private func subscribeImageViewModel() {
        imageModel.observe()
                .subscribe(onNext: { [self] userDTO in
                    self.userDTO = userDTO
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func publish() {
        guard (userDTO != nil) else {
            return
        }
        observable.onNext(userDTO!)
    }

    func observe() -> Observable<UserDTO> {
        observable
    }

    func uploadUserImage(index: Int?, file: UIImage) -> Single<ImageDTO> {
        imageModel.uploadUserImage(index: index, file: file)
    }

    func deleteUserImage(index: Int) {
        imageModel.deleteUserImage(index: index)
    }

    func updateUserStatusPending() -> Single<UserDTO> {
        imageModel.updateUserStatusPending()
    }

}
