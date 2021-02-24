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

    private var channel: Channel

    private var userService: UserService

    private var requestService: RequestService

    init(session: Session, channel: Channel, userService: UserService, requestService: RequestService) {
        self.session = session
        self.channel = channel
        self.userService = userService
        self.requestService = requestService
        subscribeChannel()
    }

    func publish() {
        observable.onNext(data)
    }

    func observe() -> Observable<UserSingleData> {
        observable
    }

    func subscribeChannel() {
        channel.observe(UserDTO.self)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] user in
                    data.user = user
                    publish()
                    populateUserPosts(user: user)
                    pushLookup(user: user)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func populateUserPosts(user: UserDTO?) {
        userService.listAllUserPosts(uid: auth.uid, userId: user?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] posts in
                    data.posts = posts
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func createRequest(_ user: UserDTO?,
                       onSuccess: @escaping (_ request: RequestDTO) -> Void,
                       onError: @escaping () -> Void
    ) {
        requestService.createRequest(
                        currentUser: auth.currentUser!,
                        uid: auth.uid,
                        userId: user?.id,
                        requestType: RequestType.FRIEND)
                .do(onSuccess: { request in
                    onSuccess(request)
                })
                .flatMap { [unowned self] _ in
                    session.refresh()
                }
                .subscribe(onSuccess: { [unowned self] _ in
                    publish()
                }, onError: { err in
                    log.error(err)
                    onError()
                })
                .disposed(by: disposeBag)
    }

    func poke(_ user: UserDTO?, completion: @escaping (_ message: String) -> Void) {
        userService.pushPoke(uid: auth.uid, userId: user?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] data in
                    RealmService.setPokeHistory(uid: session.uid, userId: user?.id)
                    completion("상대방 옆구리를 찔렀습니다.")
                }, onError: { err in
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
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] _ in
                    session.user?.starRatingsIRated?.append(StarRating(userId: user!.id!, score: score))
                    session.publish()
                    publish()
                    onSuccess()
                    log.info("Successfully rated score \(score) at user: \(user!.id ?? "??")")
                }, onError: { err in
                    onError("평가 도중 에러가 발생 하였습니다.")
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func getStarRatingIRated(_ user: UserDTO?) -> StarRating? {
        session.user?.starRatingsIRated?.first(where: { $0.userId == user?.id })
    }

    func pushLookup(user: UserDTO?) {
        userService.pushLookUp(uid: session.uid, userId: user?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: {
                    log.info("Successfully requested to push lookup..")
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}