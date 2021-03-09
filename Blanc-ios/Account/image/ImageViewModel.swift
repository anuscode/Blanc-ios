import FirebaseAuth
import Foundation
import RxSwift
import SwiftyBeaver

public enum Empty {
    case nickname
    case sex
    case birthedAt
    case height
    case bodyId
    case occupation
    case education
    case religionId
    case drinkId
    case smokingId
    case bloodId
    case deviceToken
    case location
    case introduction
    case joinedAt
    case lastLoginAt
    case job
    case area
    case phone
    case charmIds
    case idealTypeIds
    case interestIds
    case personalities
}

class ImageViewModel {

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
        observable
    }

    private func populate() {
        session
            .observe()
            .take(1)
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

    func uploadUserImage(index: Int?, file: UIImage) -> Single<ImageDTO> {
        userService
            .uploadUserImage(
                uid: auth.uid,
                userId: user?.id,
                index: index,
                file: file
            )
            .do(onSuccess: { [unowned self] image in
                let index = user?.userImagesTemp?.firstIndex(where: { $0.index == image.index })
                if (index != nil) {
                    user?.userImagesTemp?.remove(at: index!)
                }
                user?.userImagesTemp?.append(image)
                user?.userImagesTemp?.sort {
                    $0.index ?? 0 < $1.index ?? 0
                }
                user?.status = .OPENED
                publish()
            })
    }

    func deleteUserImage(index: Int) {
        userService
            .deleteUserImage(
                uid: auth.uid,
                userId: user?.id,
                index: index
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] _ in
                let index = user?.userImagesTemp?.firstIndex(where: { $0.index == index })
                if (index != nil) {
                    user?.userImagesTemp?.remove(at: index!)
                }
                user?.status = .OPENED
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func updateUserStatusPending() -> Single<UserDTO> {
        userService
            .updateUserStatusPending(uid: auth.uid, userId: session.user?.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onSuccess: { _ in
                self.session.user?.status = .PENDING
                self.session.publish()
                self.user?.status = .PENDING
                self.publish()
            })
    }
}
