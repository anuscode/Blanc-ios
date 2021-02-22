import FirebaseAuth
import Foundation
import RxSwift

class ImageModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var userDTO: UserDTO?

    private var session: Session

    private var userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        populate()
    }

    private func publish() {
        guard (userDTO != nil) else {
            return
        }
        observable.onNext(userDTO!)
    }

    func observe() -> Observable<UserDTO> {
        observable.asObservable()
    }

    private func populate() {
        session.observe()
                .take(1)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] user in
                    userDTO = user
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func uploadUserImage(index: Int?, file: UIImage) -> Single<ImageDTO> {
        userService.uploadUserImage(uid: auth.uid, userId: userDTO?.id, index: index, file: file)
                .do(onSuccess: { [self] imageDTO in
                    let index = userDTO?.userImagesTemp?.firstIndex(where: { $0.index == imageDTO.index })
                    if (index != nil) {
                        userDTO?.userImagesTemp?.remove(at: index!)
                    }
                    userDTO?.userImagesTemp?.append(imageDTO)
                    userDTO?.userImagesTemp?.sort {
                        $0.index ?? 0 < $1.index ?? 0
                    }
                    userDTO?.status = Status.OPENED
                    publish()
                })

    }

    func deleteUserImage(index: Int) {
        userService.deleteUserImage(uid: auth.uid, userId: userDTO?.id, index: index)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] _ in
                    let index = userDTO?.userImagesTemp?.firstIndex(where: { $0.index == index })
                    if (index != nil) {
                        userDTO?.userImagesTemp?.remove(at: index!)
                    }
                    userDTO?.status = Status.OPENED
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func updateUserStatusPending() -> Single<UserDTO> {
        userService.updateUserStatusPending(uid: auth.uid, userId: session.user?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .do(onSuccess: { [self] _ in
                    session.user?.status = Status.PENDING
                    session.publish()
                    userDTO?.status = Status.PENDING
                    publish()
                })
    }

}
