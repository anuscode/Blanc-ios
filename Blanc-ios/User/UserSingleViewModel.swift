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

    let loading: PublishSubject = PublishSubject<Bool>()

    let toast: PublishSubject = PublishSubject<String>()

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
        if let data = data {
            observable.onNext(data)
        }
    }

    func observe() -> Observable<UserSingleData> {
        observable
    }

    func subscribeUserModel() {
        userSingleModel
            .observe()
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

    func createRequest(onError: @escaping () -> Void) {
        let onSuccess: (_ request: RequestDTO) -> Void = { request in
            // 아주 근소한 차이로 상대방이 먼저 요청을 보낸 경우 자동 수락 처리 됨.
            if (request.response == .ACCEPTED) {
                self.conversationModel.populate()
                self.requestsModel.populate()
            }
            // 홈 화면 유저 리스트 삭제.
            let user = self.data?.user
            self.homeModel.remove(user)
        }
        userSingleModel.createRequest(onSuccess: onSuccess, onError: onError)
    }

    func poke(onBegin: () -> Void, completion: @escaping (_ message: String) -> Void) {
        if (!RealmService.isPokeAvailable(uid: session.uid, userId: data?.user?.id)) {
            completion("5분 이내에 같은 유저를 찌를 수 없습니다.")
            return
        }
        onBegin()
        userSingleModel.poke(completion: completion)
    }

    func rate(_ score: Int, onError: @escaping () -> Void) {
        let onSuccess = {
            self.sendingModel.append(user: self.data?.user)
        }
        userSingleModel.rate(score, onSuccess: onSuccess, onError: onError)
    }
}
