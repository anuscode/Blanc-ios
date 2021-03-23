import Foundation
import RxSwift

enum Reload {
    case recommendedUsers, closeUsers, realtimeUsers
}

class HomeViewModel {

    private class Repository {
        var data: HomeUserData = HomeUserData()
    }

    private class LastCounts {
        var recommendedUsers: Int = 0
        var closeUsers: Int = 0
        var realtimeUsers: Int = 0
    }

    private let disposeBag: DisposeBag = DisposeBag()

    internal let data: ReplaySubject = ReplaySubject<HomeUserData>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    private var repository: Repository = Repository()

    private var session: Session

    private let homeModel: HomeModel

    private let requestsModel: RequestsModel

    private let conversationModel: ConversationModel

    private let sendingModel: SendingModel

    init(session: Session,
         homeModel: HomeModel,
         sendingModel: SendingModel,
         requestsModel: RequestsModel,
         conversationModel: ConversationModel) {
        self.session = session
        self.homeModel = homeModel
        self.sendingModel = sendingModel
        self.requestsModel = requestsModel
        self.conversationModel = conversationModel
        subscribeHomeModel()
    }

    private func subscribeHomeModel() {
        homeModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] data in
                repository.data = data
                self.data.onNext(data)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)

        homeModel
            .observe()
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .delay(.milliseconds(700), scheduler: SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] _ in
                loading.onNext(false)
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func request(_ user: UserDTO?, animationDone: Observable<Void>) {
        let onComplete: (_ request: RequestDTO) -> Void = { [unowned self] request in
            // 일반적으로 친구 요청을 날리게 되면 새로운 리퀘스트를
            // 생성 해야 하지만 아주 간헐적으로 상대방이 아주 근소한
            // 차이로 요청을 먼저 보내면 자동으로 응답 처리가 된다.
            if (request.response == .ACCEPTED) {
                conversationModel.populate()
                requestsModel.populate()
            }
        }
        let onError: () -> Void = { [unowned self] in
            toast.onNext("친구신청 도중 에러가 발생 하였습니다.")
        }
        homeModel.request(user, animationDone: animationDone, onComplete: onComplete, onError: onError)
    }

    func poke(_ user: UserDTO?, onBegin: () -> Void) {
        if (!RealmService.isPokeAvailable(uid: session.uid, userId: user?.id)) {
            toast.onNext("5분 이내에 같은 유저를 찌를 수 없습니다.")
            return
        }
        let onCompletion = { [unowned self] in
            toast.onNext("상대방의 옆구리를 찔렀습니다.")
        }
        let onError = { [unowned self] in
            toast.onNext("에러가 발생 하였습니다.")
        }
        onBegin()
        homeModel.poke(user, onComplete: onCompletion, onError: onError)
    }

    func rate(_ user: UserDTO?, score: Int) {
        let onSuccess = { [unowned self] in
            sendingModel.append(user: user)
        }
        let onError = { [unowned self] in
            toast.onNext("평가 도중 에러가 발생 하였습니다.")
        }
        homeModel.rate(user, score, onSuccess: onSuccess, onError: onError)
    }

    func updateUserLastLoginAt() {
        homeModel.updateUserLastLoginAt()
    }
}
