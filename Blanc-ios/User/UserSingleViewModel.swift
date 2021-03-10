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

    deinit {
        log.info("deinit UserSingleViewModel..")
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
            .subscribe(onNext: { [unowned self] data in
                self.data = data
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func createRequest() {
        let onSuccess: (_ request: RequestDTO) -> Void = { [unowned self] request in
            // 아주 근소한 차이로 상대방이 먼저 요청을 보낸 경우 자동 수락 처리 됨.
            if (request.response == .ACCEPTED) {
                conversationModel.populate()
                requestsModel.populate()
            }
            // 홈 화면 유저 리스트 삭제.
            let user = data?.user
            homeModel.remove(user)
        }
        let onError: () -> Void = { [unowned self] in
            toast.onNext("친구신청 도중 에러가 발생 하였습니다.")
        }
        userSingleModel.createRequest(onSuccess: onSuccess, onError: onError)
    }

    func poke(onBegin: () -> Void) {
        if (!RealmService.isPokeAvailable(uid: session.uid, userId: data?.user?.id)) {
            toast.onNext("5분 이내에 같은 유저를 찌를 수 없습니다.")
            return
        }
        let onSuccess = { [unowned self] in
            toast.onNext("상대방 옆구리를 찔렀습니다.")
        }
        let onError = { [unowned self] in
            toast.onNext("찔러보기 도중 에러가 발생 하였습니다.")
        }
        onBegin()
        userSingleModel.poke(onSuccess: onSuccess, onError: onError)
    }

    func rate(_ score: Int) {
        let onSuccess = { [unowned self] in
            sendingModel.append(user: data?.user)
        }
        let onError = { [unowned self] in
            toast.onNext("별점주기 도중 에러가 발생 하였습니다.")
        }
        userSingleModel.rate(score, onSuccess: onSuccess, onError: onError)
    }
}
