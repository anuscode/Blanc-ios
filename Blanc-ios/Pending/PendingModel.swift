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

class PendingModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var userDTO: UserDTO?

    var session: Session

    var userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        populate()
    }

    func publish() {
        guard (userDTO != nil) else {
            return
        }
        observable.onNext(userDTO!)
    }

    func update() {
        publish()
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

    func updateUserProfile() -> Single<Void> {
        userService.updateUserProfile(currentUser: auth.currentUser!, uid: auth.uid, userId: userDTO?.id, user: userDTO!)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .do(onSuccess: { [self] response in
                    guard userDTO != nil else {
                        return
                    }
                    session.update(userDTO!)
                    publish()
                })
                .map { _ in
                    Void()
                }
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
                }, onError: { [self] err in
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

    func isModified() -> Bool {
        false
    }

    func nextEmpty() -> Empty? {
        if userDTO?.nickname == nil || userDTO?.nickname?.isEmpty ?? true {
            return Empty.nickname
        }
        if userDTO?.sex == nil {
            return Empty.sex
        }
        if userDTO?.birthedAt == nil || userDTO?.birthedAt == 0 {
            return Empty.birthedAt
        }
        if userDTO?.height == nil || userDTO?.height == 0 {
            return Empty.height
        }
        if userDTO?.bodyId == nil {
            return Empty.bodyId
        }
        if userDTO?.occupation == nil || userDTO?.occupation?.isEmpty ?? true {
            return Empty.occupation
        }
        if userDTO?.education == nil || userDTO?.education?.isEmpty ?? true {
            return Empty.education
        }
        if userDTO?.religionId == nil {
            return Empty.religionId
        }
        if userDTO?.drinkId == nil {
            return Empty.drinkId
        }
        if userDTO?.smokingId == nil {
            return Empty.smokingId
        }
        if userDTO?.bloodId == nil {
            return Empty.bloodId
        }
        if userDTO?.introduction == nil {
            return Empty.introduction
        }
        if userDTO?.charmIds == nil || userDTO?.charmIds?.count == 0 {
            return Empty.charmIds
        }
        if userDTO?.idealTypeIds == nil || userDTO?.idealTypeIds?.count == 0 {
            return Empty.idealTypeIds
        }
        if userDTO?.interestIds == nil || userDTO?.interestIds?.count == 0 {
            return Empty.interestIds
        }
        return nil
    }
}
