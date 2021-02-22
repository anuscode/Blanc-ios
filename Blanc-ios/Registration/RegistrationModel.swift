import FirebaseAuth
import Foundation
import RxSwift


class RegistrationModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private var user: UserDTO?

    private var session: Session

    private var userService: UserService

    private let auth: Auth = Auth.auth()

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        subscribeSession()
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

    private func subscribeSession() {
        session.observe()
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
        guard user != nil else {
            onError()
            return
        }
        userService.updateUserProfile(currentUser: auth.currentUser!, uid: auth.uid, userId: user!.id, user: user!)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { _ in
                    onSuccess()
                }, onError: { err in
                    onError()
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func uploadUserImage(index: Int?, file: UIImage, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        userService.uploadUserImage(uid: auth.uid, userId: user?.id, index: index, file: file)
                .do(onSuccess: { [self] imageDTO in
                    let index = user?.userImagesTemp?.firstIndex(where: {
                        $0.index == imageDTO.index
                    })
                    if (index != nil) {
                        user?.userImagesTemp?.remove(at: index!)
                    }
                    user?.userImagesTemp?.append(imageDTO)
                    user?.userImagesTemp?.sort {
                        $0.index ?? 0 < $1.index ?? 0
                    }
                    user?.status = Status.OPENED
                    publish()
                })
                .subscribe(onSuccess: { _ in
                    onSuccess()
                }, onError: { err in
                    onError()
                    log.error(err)
                }).disposed(by: disposeBag)
    }

    func deleteUserImage(index: Int) {
        userService.deleteUserImage(uid: auth.uid, userId: user?.id, index: index)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] _ in
                    let index = user?.userImagesTemp?.firstIndex(where: {
                        $0.index == index
                    })
                    if (index != nil) {
                        user?.userImagesTemp?.remove(at: index!)
                    }
                    user?.status = Status.OPENED
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func updateUserStatusPending(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        userService.updateUserStatusPending(uid: auth.uid, userId: session.user?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [self] _ in
                    session.user?.status = Status.PENDING
                    session.publish()
                    user?.status = Status.PENDING
                    publish()
                    onSuccess()
                }, onError: { err in
                    log.error(err)
                    onError()
                })
                .disposed(by: disposeBag)
    }
}
