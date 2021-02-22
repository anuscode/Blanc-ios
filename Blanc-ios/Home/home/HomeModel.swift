import Foundation
import RxSwift
import FirebaseAuth


class HomeUserData {
    var recommendedUsers: [UserDTO] = []
    var realTimeUsers: [UserDTO] = []
    var closeUsers: [UserDTO] = []
}

class HomeModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<HomeUserData>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private let data: HomeUserData = HomeUserData()

    private var session: Session

    private var userService: UserService

    private var requestService: RequestService

    init(session: Session, userService: UserService, requestService: RequestService) {
        self.session = session
        self.userService = userService
        self.requestService = requestService
        populate()
    }

    func publish() {
        observable.onNext(data)
    }

    func observe() -> Observable<HomeUserData> {
        observable
    }

    private func populate() {
        Single.just(Void())
                .flatMap { [self] it -> Single<[UserDTO]> in
                    listRecommendedUsers()
                }
                .do(afterSuccess: { [self] users in
                    // loop to calculate and set a distance from current user.
                    users.distance(session)
                    data.recommendedUsers = users
                })
                .flatMap { [self] it -> Single<[UserDTO]> in
                    listCloseUsers()
                }
                .do(afterSuccess: { [self] users in
                    // loop to calculate and set a distance from current user.
                    users.distance(session)
                    data.closeUsers = users
                })
                .flatMap { [self] it -> Single<[UserDTO]> in
                    listRealTimeAccessUsers()
                }
                .do(afterSuccess: { [self] users in
                    // loop to calculate and set a distance from current user.
                    users.distance(session)
                    data.realTimeUsers = users
                })
                .subscribe(onSuccess: { [self] _ in
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func listRecommendedUsers() -> Single<[UserDTO]> {
        userService.listRecommendedUsers(uid: auth.uid, userId: session.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
    }

    private func listCloseUsers() -> Single<[UserDTO]> {
        userService.listCloseUsers(uid: auth.uid, userId: session.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
    }

    private func listRealTimeAccessUsers() -> Single<[UserDTO]> {
        userService.listRealTimeAccessUsers(uid: auth.uid, userId: session.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
    }

    func request(_ user: UserDTO?,
                 animationDone: Observable<Void>,
                 onComplete: @escaping (_ request: RequestDTO) -> Void,
                 onError: @escaping (_ message: String) -> Void) {
        guard (user != nil) else {
            return
        }
        let index1 = data.recommendedUsers.firstIndex(of: user!)
        let index2 = data.closeUsers.firstIndex(of: user!)
        let index3 = data.realTimeUsers.firstIndex(of: user!)
        let set = Set<Int?>([index1, index2, index3])
        guard (set.count != 1) else {
            return
        }

        requestService.createLikeRequest(
                        currentUser: auth.currentUser!,
                        uid: auth.uid,
                        userId: user?.id,
                        requestType: RequestType.FRIEND)
                .do(onSuccess: { [unowned self] request in
                    onComplete(request)
                })
                .flatMap { [self] _ in
                    session.refresh()
                }
                .subscribe(onSuccess: { [self] _ in
                    animationDone.subscribe({ _ in
                        remove(user)
                    }).disposed(by: disposeBag)
                }, onError: { err in
                    log.error(err)
                    onError("친구신청 도중 에러가 발생 하였습니다.")
                }).disposed(by: disposeBag)
    }

    func poke(_ user: UserDTO?, completion: @escaping (_ message: String) -> Void) {
        userService.pushPoke(uid: auth.uid, userId: user?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [self] data in
                    DispatchQueue.main.async {
                        RealmService.setPokeHistory(uid: session.uid, userId: user?.id)
                    }
                    completion("상대방 옆구리를 찔렀습니다.")
                }, onError: { [self] err in
                    log.error(err)
                    completion("찔러보기 도중 에러가 발생 하였습니다.")
                })
                .disposed(by: disposeBag)
    }

    func rate(_ user: UserDTO?, _ score: Int, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        if (user == nil || user?.id == nil) {
            return
        }
        userService.updateUserStarRatingScore(uid: auth.uid, userId: user!.id, score: score)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { _ in
                    self.session.user?.starRatingsIRated?.append(StarRating(userId: user!.id!, score: score))
                    self.session.publish()
                    self.publish()
                    onSuccess()
                    log.info("Successfully rated score \(score) at user: \(user!.id ?? "??")")
                }, onError: { err in
                    log.error(err)
                    onError("평가 도중 에러가 발생 하였습니다.")
                })
                .disposed(by: disposeBag)
    }

    func getStarRatingIRated(_ userId: String?) -> StarRating? {
        session.user?.starRatingsIRated?.first(where: { $0.userId == userId })
    }

    func remove(_ user: UserDTO?) {
        if (user == nil || user?.id == nil) {
            return
        }
        if let index = data.recommendedUsers.firstIndex(where: { $0.id == user!.id! }) {
            data.recommendedUsers.remove(at: index)
        }
        if let index = data.closeUsers.firstIndex(where: { $0.id == user!.id! }) {
            data.closeUsers.remove(at: index)
        }
        if let index = data.realTimeUsers.firstIndex(where: { $0.id == user!.id! }) {
            data.realTimeUsers.remove(at: index)
        }
        publish()
    }

    func updateUserLastLoginAt() {

        let current = Int(NSDate().timeIntervalSince1970)
        let lastLoginAt = session.user?.lastLoginAt ?? 0
        let delta = current - lastLoginAt
        if (delta < 150) {
            return
        }

        userService.updateUserLastLoginAt(uid: auth.uid, userId: session.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { _ in
                    self.session.user?.lastLoginAt = Int(NSDate().timeIntervalSince1970)
                    print(Int(NSDate().timeIntervalSince1970))
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}
