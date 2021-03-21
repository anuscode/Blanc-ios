import FirebaseAuth
import Foundation
import RxSwift

class ProfileModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var user: UserDTO?

    private var session: Session

    private var userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        populate()
    }

    func publish() {
        guard let user = user else {
            return
        }
        observable.onNext(user)
    }

    func update() {
        publish()
    }

    func observe() -> Observable<UserDTO> {
        observable.asObservable()
    }

    private func populate() {
        session
            .observe()
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] user in
                self.user = user
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func updateUserProfile() -> Single<Void> {
        let currentUser = auth.currentUser!
        let uid = auth.uid
        let userId = user?.id
        return userService
            .updateUserProfile(
                currentUser: currentUser,
                uid: uid,
                userId: userId,
                user: user!
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onSuccess: { [unowned self] response in
                if let user = user {
                    session.update(user)
                    publish()
                }
            })
            .map({ _ in
                Void()
            })
    }

    func uploadUserImage(index: Int?, file: UIImage) -> Single<ImageDTO> {
        let uid = auth.uid
        let userId = user?.id
        return userService
            .uploadUserImage(
                uid: uid,
                userId: userId,
                index: index,
                file: file
            )
            .do(onSuccess: { [unowned self] imageDTO in
                let index = user?.userImagesTemp?.firstIndex(where: { $0.index == imageDTO.index })
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

    }

    func deleteUserImage(index: Int) {
        let uid = auth.uid
        let userId = user?.id
        return userService
            .deleteUserImage(uid: uid, userId: userId, index: index)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] _ in
                let index = user?.userImagesTemp?.firstIndex(where: { $0.index == index })
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

    func updateUserStatusPending() -> Single<UserDTO> {
        let uid = auth.uid
        let userId = session.user?.id
        return userService
            .updateUserStatusPending(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onSuccess: { [unowned self] _ in
                session.user?.status = Status.PENDING
                session.publish()
                user?.status = Status.PENDING
                publish()
            })
    }
}
