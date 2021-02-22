import Foundation
import RxSwift


class UserSingleViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<UserSingleData>.create(bufferSize: 1)

    private var data: UserSingleData? = nil

    private var session: Session

    private var homeModel: HomeModel

    private var userSingleModel: UserSingleModel

    private var sendingModel: SendingModel

    private var requestsModel: RequestsModel

    private var conversationModel: ConversationModel

    init(session: Session, homeModel: HomeModel, userSingleModel: UserSingleModel,
         sendingModel: SendingModel, requestsModel: RequestsModel, conversationModel: ConversationModel) {
        self.session = session
        self.homeModel = homeModel
        self.userSingleModel = userSingleModel
        self.sendingModel = sendingModel
        self.requestsModel = requestsModel
        self.conversationModel = conversationModel
        subscribeUserModel()
    }

    private func publish() {
        if (data == nil) {
            return
        }
        observable.onNext(data!)
    }

    func observe() -> Observable<UserSingleData> {
        observable
    }

    func subscribeUserModel() {
        userSingleModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] data in
                    self.data = data
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func request(_ user: UserDTO?, onError: @escaping () -> Void) {
        let onSuccess: (_ request: RequestDTO) -> Void = { [unowned self] request in
            // 1. 일반적으로 친구 요청을 날리게 되면 새로운 리퀘스트를
            // 생성 해야 하지만 아주 간헐적으로 상대방이 아주 근소한
            // 차이로 요청을 먼저 보내면 자동으로 응답 처리가 된다.
            if (request.response == Response.ACCEPTED) {
                conversationModel.populate()
                requestsModel.populate()
            }
            // 2. 홈 화면 유저 리스트 삭제.
            homeModel.remove(user)
        }

        userSingleModel.request(user, onSuccess: onSuccess, onError: onError)
    }

    func poke(_ user: UserDTO?, onBegin: () -> Void, completion: @escaping (_ message: String) -> Void) {
        if (!RealmService.isPokeAvailable(uid: session.uid, userId: user?.id)) {
            completion("5분 이내에 같은 유저를 찌를 수 없습니다.")
            return
        }
        onBegin()
        userSingleModel.poke(user, completion: completion)
    }

    func rate(_ user: UserDTO?, _ score: Int, onError: @escaping (_ message: String) -> Void) {
        let onSuccess = {
            self.sendingModel.append(user: user)
        }
        userSingleModel.rate(user, score, onSuccess: onSuccess, onError: onError)
    }

    func getStarRatingIRated(_ user: UserDTO?) -> StarRating? {
        userSingleModel.getStarRatingIRated(user)
    }

    func isWhoSentMe() -> Bool {
        if (data == nil || data?.user == nil || data?.user?.id == nil) {
            return false
        }
        return session.user?.userIdsSentMeRequest?.contains(data!.user!.id!) ?? false
    }

    func isWhoISent() -> Bool {
        if (data == nil || data?.user == nil || data?.user?.id == nil) {
            return false
        }
        return session.user?.userIdsISentRequest?.contains(data!.user!.id!) ?? false
    }

    func isWhoMatched() -> Bool {
        if (data == nil || data?.user == nil || data?.user?.id == nil) {
            return false
        }
        return session.user?.userIdsMatched?.contains(data!.user!.id!) ?? false
    }
}
