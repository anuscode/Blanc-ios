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
        channel
            .observe(UserDTO.self)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { user in
                self.data.user = user
                self.publish()
                self.populateUserPosts(user: user)
                self.pushLookup(user: user)
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
            .subscribe(onSuccess: { posts in
                self.data.posts = posts
                self.publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func createRequest(_ user: UserDTO?,
                       onSuccess: @escaping (_ request: RequestDTO) -> Void,
                       onError: @escaping () -> Void
    ) {
        guard let uid = session.uid,
              let userId = user?.id,
              let currentUser = auth.currentUser else {
            return
        }
        requestService
            .createRequest(
                currentUser: currentUser,
                uid: uid,
                userId: userId,
                requestType: .FRIEND)
            .do(onSuccess: { request in
                onSuccess(request)
            })
            .flatMap { _ in
                self.session.refresh()
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { _ in
                self.publish()
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }

    func poke(_ user: UserDTO?, completion: @escaping (_ message: String) -> Void) {
        guard let uid = session.uid,
              let userId = user?.id else {
            return
        }
        userService
            .pushPoke(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { data in
                RealmService.setPokeHistory(uid: uid, userId: userId)
                completion("상대방 옆구리를 찔렀습니다.")
            }, onError: { err in
                log.error(err)
                completion("찔러보기 도중 에러가 발생 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    func rate(_ user: UserDTO?, _ score: Int, onSuccess: @escaping () -> Void, onError: @escaping (_ message: String) -> Void) {
        guard let uid = session.uid,
              let userId = user?.id else {
            return
        }
        userService
            .updateUserStarRatingScore(uid: uid, userId: userId, score: score)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { _ in
                log.info("Successfully rated score \(score) at user: \(userId)")
                self.session.user?.starRatingsIRated?.append(StarRating(userId: userId, score: score))
                self.session.publish()
                self.publish()
                onSuccess()
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
        guard let uid = session.uid,
              let userId = user?.id else {
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