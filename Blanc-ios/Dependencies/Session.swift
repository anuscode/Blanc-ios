import FirebaseAuth
import Foundation
import RxSwift


class Session {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let userService: UserService

    private let preferences: Preferences

    private let observable: ReplaySubject<UserDTO> = ReplaySubject.create(bufferSize: 1)

    var user: UserDTO?

    var id: String? {
        user?._id ?? nil
    }

    var uid: String? {
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
        guard (user != nil) else {
            return
        }
        observable.onNext(user!)
    }

    func generate() -> Single<Void> {
        let user = auth.currentUser
        let uid = auth.uid
        return userService.getSession(currentUser: user!, uid: uid)
                .do(onSuccess: { [self] user in
                    self.user = user
                    self.user?.uid = uid
                    publish()
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
        userService.getSession(currentUser: auth.currentUser!, uid: auth.uid)
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .do(afterSuccess: { [self] user in
                    update(user)
                })
    }

    func update(_ userDTO: UserDTO) {
        user = userDTO
        publish()
    }

    public func signOut() {
        do {
            try auth.signOut()
        } catch {
            log.error("Failed to logout.")
        }
    }

    private func subscribeBroadcast() {
        Broadcast.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { push in
                    if (push.isRequest()) {
                        self.user?.userIdsSentMeRequest?.append(push.userId!)
                    }
                    if (push.isMatched()) {
                        if let index = self.user?.userIdsISentRequest?.firstIndex(of: push.userId!) {
                            self.user?.userIdsISentRequest?.remove(at: index)
                        }
                        if let index = self.user?.userIdsSentMeRequest?.firstIndex(of: push.userId!) {
                            self.user?.userIdsSentMeRequest?.remove(at: index)
                        }
                        self.user?.userIdsMatched?.append(push.userId!)
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}
