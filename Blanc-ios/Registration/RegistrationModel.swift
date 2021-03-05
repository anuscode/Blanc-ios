import FirebaseAuth
import Foundation
import RxSwift


class RegistrationModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private var session: Session

    private var userService: UserService

    private let auth: Auth = Auth.auth()

    private var user: UserDTO? {
        didSet {
            publish()
        }
    }

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        populate()
    }

    func publish() {
        if let user = user {
            observable.onNext(user)
        }
    }

    func observe() -> Observable<UserDTO> {
        observable
    }

    private func populate() {
        session
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { user in
                self.user = user
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func updateUserProfile(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        guard let user = user,
              let currentUser = auth.currentUser,
              let uid = auth.uid,
              let userId = user.id else {
            onError()
            return
        }
        userService
            .updateUserProfile(currentUser: currentUser, uid: uid, userId: userId, user: user)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                onSuccess()
                self.publish()
            }, onError: { err in
                onError()
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func uploadUserImage(index: Int?, file: UIImage, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        userService.uploadUserImage(uid: auth.uid, userId: user?.id, index: index, file: file)
            .do(onSuccess: { imageDTO in
                if let index = self.user?.userImagesTemp?.firstIndex(where: {
                    $0.index == imageDTO.index
                }) {
                    self.user?.userImagesTemp?.remove(at: index)
                }
                self.user?.userImagesTemp?.append(imageDTO)
                self.user?.userImagesTemp?.sort {
                    $0.index ?? 0 < $1.index ?? 0
                }
                self.user?.status = Status.OPENED
                self.publish()
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
            .subscribe(onSuccess: { _ in
                if let index = self.user?.userImagesTemp?.firstIndex(where: {
                    $0.index == index
                }) {
                    self.user?.userImagesTemp?.remove(at: index)
                }
                self.user?.status = Status.OPENED
                self.publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func updateUserStatusPending(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        userService.updateUserStatusPending(uid: auth.uid, userId: session.user?.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                self.session.user?.status = Status.PENDING
                self.session.publish()
                self.user?.status = Status.PENDING
                self.publish()
                onSuccess()
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }
}
