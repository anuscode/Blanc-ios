import Foundation
import RxSwift
import FirebaseAuth


class UserSingleData {
    var user: UserDTO?
    var posts: [PostDTO]?
}

class UserSingleModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserSingleData>.create(bufferSize: 1)

    private let auth: Auth = Auth.auth()

    private var data: UserSingleData = UserSingleData()

    private var session: Session

    private var userService: UserService

    private var requestService: RequestService

    init(session: Session, userService: UserService, requestService: RequestService) {
        self.session = session
        self.userService = userService
        self.requestService = requestService
        subscribeChannel()
    }

    deinit {
        log.info("deinit UserSingleModel..")
    }

    func publish() {
        observable.onNext(data)
    }

    func observe() -> Observable<UserSingleData> {
        observable
    }

    func subscribeChannel() {
        Channel
            .user
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { [unowned self]  user in
                user.relationship = session.relationship(with: user)
            })
            .subscribe(onNext: { [unowned self] user in
                data.user = user
                publish()
                populateUserPosts(user: user)
                pushLookup()
                subscribeSession()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func populateUserPosts(user: UserDTO?) {
        guard let uid = session.uid,
              let userId = user?.id else {
            return
        }
        userService
            .listAllUserPosts(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .delay(.seconds(0.5), scheduler: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self]  posts in
                data.posts = posts
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func subscribeSession() {
        session
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .skip(1)
            .subscribe(onNext: { [unowned self] _ in
                log.info("subscribe session in user single model..")
                if let user = data.user {
                    user.relationship = session.relationship(with: user)
                    publish()
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)

    }

    func createRequest(onSuccess: @escaping (_ request: RequestDTO) -> Void,
                       onError: @escaping () -> Void
    ) {
        guard let uid = session.uid,
              let user = data.user,
              let userId = user.id,
              let currentUser = auth.currentUser else {
            onError()
            return
        }
        requestService
            .createRequest(
                currentUser: currentUser,
                uid: uid,
                userId: userId,
                requestType: .FRIEND
            )
            .do(onSuccess: onSuccess)
            .flatMap({ _ in self.session.refresh() })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self]  _ in
                user.relationship = session.relationship(with: user)
                publish()
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    func poke(onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        guard let uid = session.uid,
              let user = data.user,
              let userId = user.id else {
            return
        }
        userService
            .pushPoke(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { data in
                RealmService.setPokeHistory(uid: uid, userId: userId)
                onSuccess()
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    func rate(_ score: Int, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        guard let uid = session.uid,
              let user = data.user,
              let userId = user.id else {
            onError()
            return
        }
        userService
            .updateUserStarRatingScore(uid: uid, userId: userId, score: score)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] _ in
                log.info("Successfully rated score \(score) at user: \(userId)")

                let starRating = StarRating(userId: userId, score: score)
                session.user?.starRatingsIRated?.append(starRating)
                session.publish()

                let relationship = session.relationship(with: user)
                user.relationship = relationship
                publish()

                onSuccess()
            }, onError: { err in
                onError()
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func pushLookup() {
        guard let uid = session.uid,
              let user = data.user,
              let userId = user.id else {
            return
        }
        userService
            .pushLookUp(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: {
                log.info("Successfully requested to push lookup..")
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}