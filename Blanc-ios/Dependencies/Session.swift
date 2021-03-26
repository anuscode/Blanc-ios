import FirebaseAuth
import Foundation
import RxSwift
import SwinjectStoryboard


class Session {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let userService: UserService

    private let preferences: Preferences

    private let observable: ReplaySubject<UserDTO> = ReplaySubject.create(bufferSize: 1)

    internal var user: UserDTO?

    internal var id: String? {
        user?.id
    }

    internal var uid: String? {
        user?.uid
    }

    init(userService: UserService, preferences: Preferences) {
        self.userService = userService
        self.preferences = preferences
        subscribeBroadcast()
    }

    func observe() -> Observable<UserDTO> {
        observable.asObservable()
    }

    func publish() {
        if let user = user {
            observable.onNext(user)
        }
    }

    func generate() -> Single<Void> {
        let user = auth.currentUser
        let uid = auth.uid
        return userService
            .getSession(currentUser: user!, uid: uid)
            .do(onSuccess: { user in
                self.user = user
                self.user?.uid = uid
                self.publish()
            })
            .flatMap({ user -> Single<UserDTO> in
                let token = self.preferences.getDeviceToken()
                log.info("Token: \(token ?? "EMPTY")")
                if (token != nil && token != user.deviceToken) {
                    return self.userService.updateDeviceToken(uid: uid, deviceToken: token)
                } else {
                    return Single.just(UserDTO())
                }
            })
            .map({ _ in
                Void()
            })
    }

    func refresh() -> Single<UserDTO> {
        let currentUser = auth.currentUser!
        let uid = auth.uid
        return userService
            .getSession(
                currentUser: currentUser,
                uid: uid
            )
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(afterSuccess: { [unowned self] user in
                update(user)
            })
    }

    func update(_ user: UserDTO) {
        self.user = user
        publish()
    }

    @discardableResult
    public static func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        } catch {
            log.error("Failed to logout.")
            return false
        }
    }

    private func subscribeBroadcast() {
        Broadcast
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] push in
                if (push.isRequest()) {
                    user?.userIdsSentMeRequest?.append(push.userId!)
                    publish()
                }
                if (push.isMatched()) {
                    if let index = user?.userIdsISentRequest?.firstIndex(of: push.userId!) {
                        user?.userIdsISentRequest?.remove(at: index)
                    }
                    if let index = user?.userIdsSentMeRequest?.firstIndex(of: push.userId!) {
                        user?.userIdsSentMeRequest?.remove(at: index)
                    }
                    user?.userIdsMatched?.append(push.userId!)
                    publish()
                }
                if (push.isLogout()) {
                    log.info("detected login in another device..")
                    Session.signOut()
                    let window = UIApplication.shared.keyWindow
                    let storyboard = UIStoryboard(name: "LaunchAnimation", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LaunchPagerViewController")
                    vc.modalPresentationStyle = .fullScreen
                    window?.rootViewController?.dismiss(animated: false, completion: {
                        let window = UIApplication.shared.windows.first
                        window?.rootViewController?.present(vc, animated: false) {
                            vc.toast(message: "다른 디바이스에서 로그인이 감지되어 로그아웃 되었습니다.")
                            SwinjectStoryboard.defaultContainer.resetObjectScope(.mainScope)
                        }
                    })
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func relationship(with: UserDTO?) -> UserDTO.Relationship? {
        guard let target = with,
              let userId = with?.id else {
            return nil
        }
        let relationship = UserDTO.Relationship()
        relationship.isMatched = user?.userIdsMatched?.contains(userId) ?? false
        relationship.isUnmatched = user?.userIdsUnmatched?.contains(userId) ?? false
        relationship.isWhoISent = user?.userIdsISentRequest?.contains(userId) ?? false
        relationship.isWhoSentMe = user?.userIdsSentMeRequest?.contains(userId) ?? false
        relationship.starRating = user?.starRatingsIRated?.first(where: { $0.userId == userId })
        relationship.distance = user?.distance(from: target, type: String.self)
        return relationship
    }
}
