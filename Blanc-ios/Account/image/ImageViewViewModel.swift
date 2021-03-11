import Foundation
import RxSwift

class ImageViewViewModel {

    class Repository {
        var user: UserDTO?
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let pendingModel: ImageViewModel

    let user: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    let loading: PublishSubject = PublishSubject<Bool>()

    let toast: PublishSubject = PublishSubject<String>()

    let imagesClickable: PublishSubject = PublishSubject<Bool>()

    private var repository: Repository = Repository()

    init(pendingModel: ImageViewModel) {
        self.pendingModel = pendingModel
        observeViewModel()
    }

    private func observeViewModel() {
        pendingModel
            .observe()
            .subscribe(onNext: { [unowned self] user in
                repository.user = user
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func publish() {
        guard let data = repository.user else {
            return
        }
        user.onNext(data)
    }

    func uploadUserImage(index: Int?, file: UIImage) {
        imagesClickable.onNext(false)
        pendingModel
            .uploadUserImage(index: index, file: file)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                self.imagesClickable.onNext(true)
                self.loading.onNext(false)
            }, onError: { err in
                self.toast.onNext("이미지 업로드에 실패 하였습니다.")
                self.imagesClickable.onNext(true)
                self.loading.onNext(false)
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func deleteUserImage(index: Int) {
        if ((repository.user?.getTempImageUrl(index: index).isEmpty ?? true)) {
            toast.onNext("등록 된 이미지가 없습니다.")
            return
        }
        pendingModel.deleteUserImage(index: index)
    }

    func updateUserStatusPending(onSuccess: @escaping () -> Void) {

        if ((repository.user?.userImagesTemp?.count ?? 0) < 2) {
            toast.onNext("사진은 2장 이상 필요합니다.")
            return
        }

        let mainImageUrl = repository.user?.getTempImageUrl(index: 0)
        if (mainImageUrl?.isEmpty ?? true) {
            toast.onNext("메인 이미지는 필수 사항입니다.")
            return
        }

        loading.onNext(true)
        pendingModel
            .updateUserStatusPending()
            .do(onNext: { _ in
                self.loading.onNext(false)
                self.toast.onNext("심사 요청을 하였습니다.")
            })
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { _ in
                onSuccess()
            }, onError: { err in
                self.toast.onNext("심사요청 도중 에러가 발생 하였습니다.")
                self.loading.onNext(false)
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}
