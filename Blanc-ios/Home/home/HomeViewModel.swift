import Foundation
import RxSwift

class HomeViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<HomeUserData>.create(bufferSize: 1)

    private var data: HomeUserData = HomeUserData()

    private var channel: Channel

    private var session: Session

    private let homeModel: HomeModel

    private let requestsModel: RequestsModel

    private let conversationModel: ConversationModel

    private let sendingModel: SendingModel

    init(session: Session, channel: Channel, homeModel: HomeModel, sendingModel: SendingModel,
         requestsModel: RequestsModel, conversationModel: ConversationModel) {
        self.session = session
        self.channel = channel
        self.homeModel = homeModel
        self.sendingModel = sendingModel
        self.requestsModel = requestsModel
        self.conversationModel = conversationModel
        subscribeHomeModel()
    }

    func observe() -> Observable<HomeUserData> {
        observable
    }

    private func publish() {
        observable.onNext(data)
    }

    private func subscribeHomeModel() {
        homeModel.observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { data in
                self.data = data
                self.publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func request(_ user: UserDTO?, animationDone: Observable<Void>, onError: @escaping (_ message: String) -> Void) {

        let onComplete: (_ request: RequestDTO) -> Void = { request in
            // 일반적으로 친구 요청을 날리게 되면 새로운 리퀘스트를
            // 생성 해야 하지만 아주 간헐적으로 상대방이 아주 근소한
            // 차이로 요청을 먼저 보내면 자동으로 응답 처리가 된다.
            if (request.response == Response.ACCEPTED) {
                self.conversationModel.populate()
                self.requestsModel.populate()
            }
        }

        homeModel.request(user, animationDone: animationDone, onComplete: onComplete, onError: onError)
    }

    func poke(_ user: UserDTO?, onBegin: () -> Void, completion: @escaping (_ message: String) -> Void) {
        if (!RealmService.isPokeAvailable(uid: session.uid, userId: user?.id)) {
            completion("5분 이내에 같은 유저를 찌를 수 없습니다.")
            return
        }
        onBegin()
        homeModel.poke(user, completion: completion)
    }

    func rate(_ user: UserDTO?, score: Int, onError: @escaping (_ message: String) -> Void) {
        let onSuccess = {
            self.sendingModel.append(user: user)
        }
        homeModel.rate(user, score, onSuccess: onSuccess, onError: onError)
    }

    func getStarRatingIRated(_ user: UserDTO?) -> StarRating? {
        homeModel.getStarRatingIRated(user?.id)
    }

    func updateUserLastLoginAt() {
        homeModel.updateUserLastLoginAt()
    }

    func channel(user: UserDTO?) {
        if let user = user {
            channel.next(value: user)
        }
    }
}
