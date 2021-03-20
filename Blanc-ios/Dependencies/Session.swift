import FirebaseAuth
import Foundation
import RxSwift


class Session {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let userService: UserService

    private let preferences: Preferences

    private let observable: ReplaySubject<UserDTO> = ReplaySubject.create(bufferSize: 1)

    internal var user: UserDTO?

    internal var id: String? {
        user?._id ?? nil
    }

    internal var uid: String? {
        user?.uid ?? nil
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
        guard let user = user else {
            return
        }
        observable.onNext(user)
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
            .map({ _ in Void() })
    }

    func refresh() -> Single<UserDTO> {
        userService
            .getSession(currentUser: auth.currentUser!, uid: auth.uid)
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(afterSuccess: update)
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
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] push in
                if (push.isRequest()) {
                    user?.userIdsSentMeRequest?.append(push.userId!)
                }
                if (push.isMatched()) {
                    if let index = user?.userIdsISentRequest?.firstIndex(of: push.userId!) {
                        user?.userIdsISentRequest?.remove(at: index)
                    }
                    if let index = user?.userIdsSentMeRequest?.firstIndex(of: push.userId!) {
                        user?.userIdsSentMeRequest?.remove(at: index)
                    }
                    user?.userIdsMatched?.append(push.userId!)
                }
                if (push.isLogout()) {
                    log.info("detected login in another device..")
                    Session.signOut()
                    let window = UIApplication.shared.keyWindow
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "InitPagerViewController")
                    vc.modalPresentationStyle = .fullScreen
                    DispatchQueue.main.async {
                        window?.rootViewController?.dismiss(animated: false, completion: {
                            let window = UIApplication.shared.windows.first
                            window?.rootViewController?.present(vc, animated: false, completion: {
                                vc.toast(message: "다른 디바이스에서 로그인이 감지되어 로그아웃 되었습니다.")
                            })
                        })
                    }
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func relationship(with: UserDTO?) -> Relationship? {
        guard let userId = with?.id else {
            return nil
        }
        let relationship = Relationship()
        relationship.isMatched = user?.userIdsMatched?.contains(userId) ?? false
        relationship.isUnmatched = user?.userIdsUnmatched?.contains(userId) ?? false
        relationship.isWhoISent = user?.userIdsISentRequest?.contains(userId) ?? false
        relationship.isWhoSentMe = user?.userIdsSentMeRequest?.contains(userId) ?? false
        relationship.starRating = user?.starRatingsIRated?.first(where: { $0.userId == userId })
        return relationship
    }
}
