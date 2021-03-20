import Foundation
import RxSwift

class ReceivedViewData {
    var requests: [RequestDTO] = []
    var users: [UserDTO] = []
}

class ReceivedViewModel {

    private class LastCounts {
        var requests: Int = 0
        var users: Int = 0
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<ReceivedViewData>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let reload: PublishSubject = PublishSubject<Void>()

    private var data: ReceivedViewData = ReceivedViewData()

    private var lastCounts: LastCounts = LastCounts()

    private let session: Session

    private let requestsModel: RequestsModel

    private let ratedModel: RatedModel

    private let conversationModel: ConversationModel

    private let nsLock: NSLock = NSLock()

    init(session: Session,
         requestsModel: RequestsModel,
         ratedModel: RatedModel,
         conversationModel: ConversationModel
    ) {
        self.session = session
        self.requestsModel = requestsModel
        self.ratedModel = ratedModel
        self.conversationModel = conversationModel
        subscribeRequestsModel()
        subscribeRatedModel()
    }

    private func publish() {
        nsLock.lock()
        observable.onNext(data)
        nsLock.unlock()
    }

    func observe() -> Observable<ReceivedViewData> {
        observable
    }

    private func subscribeRequestsModel() {
        requestsModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onNext: { [unowned self] requests in
                data.requests = requests
                publish()
            })
            .subscribe(onNext: { [unowned self] requests in
                if (lastCounts.requests > 0 && requests.count == 0) {
                    reload.onNext(Void())
                }
                lastCounts.requests = requests.count
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func subscribeRatedModel() {
        ratedModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onNext: { [unowned self] users in
                data.users = users
                publish()
            })
            .subscribe(onNext: { [unowned self] users in
                if (lastCounts.users > 0 && users.count == 0) {
                    reload.onNext(Void())
                }
                lastCounts.users = users.count
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func channel(user: UserDTO?) {
        guard let user = user else {
            return
        }
        Channel.next(value: user)
    }

    func accept(request: RequestDTO?) {
        // refresh conversation list if successfully done.
        let onSuccess = { [unowned self] in
            conversationModel.populate()
        }
        let onError = { [unowned self] in
            toast.onNext("친구신청 수락 도중 에러가 발생 하였습니다.")
        }
        requestsModel.accept(request: request, onSuccess: onSuccess, onError: onError)
    }

    func decline(request: RequestDTO?) {
        let onError = { [unowned self] in
            toast.onNext("친구신청 거절 도중 에러가 발생 하였습니다.")
        }
        requestsModel.decline(request: request, onError: onError)
    }
}
