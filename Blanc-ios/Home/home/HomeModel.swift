import Foundation
import RxSwift
import FirebaseAuth
import CoreLocation

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

    private var manager: CLLocationManager = CLLocationManager()

    init(session: Session, userService: UserService, requestService: RequestService) {
        self.session = session
        self.userService = userService
        self.requestService = requestService
        start()
    }

    deinit {
        log.info("deinit HomeModel..")
    }

    func publish() {
        observable.onNext(data)
    }

    func observe() -> Observable<HomeUserData> {
        observable
    }

    private func start() {
        if (manager.authorizationStatus == .notDetermined) {
            subscribeLocationAuthorizationChanges()
            requestLocationAuthorization()
        } else {
            populate()
        }
    }

    private func populate() {
        updateUserLocation()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap({ [unowned self] it -> Single<[UserDTO]> in
                listRecommendedUsers()
            })
            .do(afterSuccess: { [unowned self] users in
                // loop to calculate and set a distance from current user.
                users.forEach({ $0.relationship = session.relationship(with: $0) })
                data.recommendedUsers = users
            })
            .flatMap({ [unowned self] it -> Single<[UserDTO]> in
                listCloseUsers()
            })
            .do(afterSuccess: { [unowned self] users in
                // loop to calculate and set a distance from current user.
                users.forEach({ $0.relationship = session.relationship(with: $0) })
                data.closeUsers = users
            })
            .flatMap({ [unowned self] it -> Single<[UserDTO]> in
                listRealTimeAccessUsers()
            })
            .do(afterSuccess: { [unowned self] users in
                // loop to calculate and set a distance from current user.
                users.forEach({ $0.relationship = session.relationship(with: $0) })
                data.realTimeUsers = users
            })
            .subscribe(onSuccess: { [unowned self] _ in
                subscribeSession()
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func listRecommendedUsers() -> Single<[UserDTO]> {
        userService
            .listRecommendedUsers(uid: auth.uid, userId: session.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    private func listCloseUsers() -> Single<[UserDTO]> {
        userService
            .listCloseUsers(uid: auth.uid, userId: session.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    private func listRealTimeAccessUsers() -> Single<[UserDTO]> {
        userService
            .listRealTimeAccessUsers(uid: auth.uid, userId: session.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    private func updateUserLocation() -> Single<Location> {
        let uid: String? = auth.uid
        let userId: String? = session.id
        var coord: Coordinate?
        var addr: String = "알 수 없음"
        let unknown: String = "알 수 없음"
        return manager.rx
            .location
            .subscribeOn(MainScheduler.instance)
            .do(onNext: { location in
                coord = Coordinate(location)
            })
            .observeOn(MainScheduler.instance)
            .flatMap({ [unowned self] location -> Observable<String> in
                if (manager.authorizationStatus.rawValue <= 2) {
                    return Observable.of(unknown)
                }
                guard let location = location else {
                    return Observable.just(unknown)
                }
                return manager.rx
                    .placemark(with: location)
                    .map({ placemark in
                        placemark.locality ?? unknown
                    })
                    .catchErrorJustReturn(unknown)
            })
            .do(onNext: { locality in
                addr = locality
            })
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap({ [unowned self]  _ -> Single<Location> in
                userService.updateUserLocation(
                    uid: uid,
                    userId: userId,
                    latitude: coord?.latitude ?? 0,
                    longitude: coord?.longitude ?? 0,
                    area: addr
                )
            })
            .do(onNext: { [unowned self] location in
                session.user?.location = location
                session.user?.area = addr
                session.publish()
            })
            .take(1)
            .asSingle()
    }

    private func subscribeSession() {
        session
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .skip(1)
            .subscribe(onNext: { [unowned self] _ in
                var updateIndexes1: [Int] = []
                data.recommendedUsers.enumerated().forEach { (index, item) in
                    let old = item.relationship
                    let new = session.relationship(with: item)
                    if (new?.isDifferent(old) == true) {
                        item.relationship = new
                        updateIndexes1.append(index)
                    }
                }
                updateIndexes1.forEach({ data.recommendedUsers.diffable($0) })

                var updateIndexes2: [Int] = []
                data.realTimeUsers.enumerated().forEach { (index, item) in
                    let old = item.relationship
                    let new = session.relationship(with: item)
                    if (new?.isDifferent(old) == true) {
                        item.relationship = new
                        updateIndexes2.append(index)
                    }
                }
                updateIndexes2.forEach({ data.realTimeUsers.diffable($0) })

                var updateIndexes3: [Int] = []
                data.closeUsers.enumerated().forEach { (index, item) in
                    let old = item.relationship
                    let new = session.relationship(with: item)
                    if (new?.isDifferent(old) == true) {
                        item.relationship = new
                        updateIndexes3.append(index)
                    }
                }
                updateIndexes3.forEach({ data.closeUsers.diffable($0) })

                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func requestLocationAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    private func subscribeLocationAuthorizationChanges() {
        manager.rx
            .didChangeAuthorization
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _, status in
                log.info("didChangeAuthorization called..")
                switch status {
                case .denied, .notDetermined, .restricted:
                    log.info("status denied detected.. requesting authorization..")
                    manager.requestAlwaysAuthorization()
                default:
                    log.info("Currently the location authorization is well granted..")
                }
                populate()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func request(_ user: UserDTO?,
                 animationDone: Observable<Void>,
                 onComplete: @escaping (_ request: RequestDTO) -> Void,
                 onError: @escaping () -> Void) {
        guard let user = user,
              let currentUser = auth.currentUser,
              let uid = auth.uid,
              let userId = user.id else {
            return
        }
        requestService
            .createRequest(
                currentUser: currentUser,
                uid: uid,
                userId: userId,
                requestType: .FRIEND
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onSuccess: { request in
                onComplete(request)
            })
            .flatMap({ _ in
                animationDone.asSingle()
            })
            .do(onNext: { [unowned self] _ in
                remove(user)
            })
            .flatMap({ [unowned self] _ in
                session.refresh()
            })
            .subscribe(onSuccess: { _ in
                log.info("successfully requested..")
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    func poke(_ user: UserDTO?,
              onComplete: @escaping () -> Void,
              onError: @escaping () -> Void) {
        guard let user = user,
              let uid = auth.uid,
              let userId = user.id else {
            return
        }
        userService
            .pushPoke(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { data in
                RealmService.setPokeHistory(uid: uid, userId: userId)
                onComplete()
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    func rate(_ user: UserDTO?,
              _ score: Int,
              onSuccess: @escaping () -> Void,
              onError: @escaping () -> Void) {
        guard let uid = auth.uid,
              let user = user,
              let userId = user.id else {
            return
        }
        userService
            .updateUserStarRatingScore(uid: uid, userId: userId, score: score)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] _ in
                let starRating = StarRating(userId: userId, score: score)
                session.user?.starRatingsIRated?.append(starRating)
                user.relationship = session.relationship(with: user)
                onSuccess()
                log.info("Successfully rated score \(score) with user: \(userId)")
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    func update(user: UserDTO?) {
        update(userId: user?.id)
    }

    func update(userId: String?) {
        guard let userId = userId else {
            return
        }
        if let index = data.recommendedUsers.firstIndex(where: { $0.id == userId }) {
            let user = data.recommendedUsers[index]
            user.relationship = session.relationship(with: user)
        }
        if let index = data.closeUsers.firstIndex(where: { $0.id == userId }) {
            let user = data.closeUsers[index]
            user.relationship = session.relationship(with: user)
        }
        if let index = data.realTimeUsers.firstIndex(where: { $0.id == userId }) {
            let user = data.realTimeUsers[index]
            user.relationship = session.relationship(with: user)
        }
        publish()
    }

    func remove(_ user: UserDTO?) {
        guard let user = user,
              let userId = user.id else {
            return
        }
        if let index = data.recommendedUsers.firstIndex(where: { $0.id == userId }) {
            data.recommendedUsers.remove(at: index)
        }
        if let index = data.closeUsers.firstIndex(where: { $0.id == userId }) {
            data.closeUsers.remove(at: index)
        }
        if let index = data.realTimeUsers.firstIndex(where: { $0.id == userId }) {
            data.realTimeUsers.remove(at: index)
        }
        publish()
    }

    func updateUserLastLoginAt() {
        let current = Int(NSDate().timeIntervalSince1970)
        let lastLoginAt = session.user?.lastLoginAt ?? 0
        let delta = current - lastLoginAt
        if (delta < 120) {
            return
        }
        userService
            .updateUserLastLoginAt(uid: auth.uid, userId: session.id)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] _ in
                session.user?.lastLoginAt = Int(NSDate().timeIntervalSince1970)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}
