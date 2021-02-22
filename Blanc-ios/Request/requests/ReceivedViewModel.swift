import Foundation
import RxSwift

class ReceivedViewData {
    var requests: [RequestDTO] = []
    var users: [UserDTO] = []
}

class ReceivedViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<ReceivedViewData>.create(bufferSize: 1)

    private let session: Session

    private let channel: Channel

    private let requestsModel: RequestsModel

    private let ratedModel: RatedModel

    private let conversationModel: ConversationModel

    private var data: ReceivedViewData = ReceivedViewData()

    private let nsLock: NSLock = NSLock()

    init(session: Session, channel: Channel, requestsModel: RequestsModel, ratedModel: RatedModel, conversationModel: ConversationModel) {
        self.session = session
        self.channel = channel
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
        requestsModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] requests in
                    data.requests = requests
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func subscribeRatedModel() {
        ratedModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] users in
                    // loop to calculate and set a distance from current user.
                    users.distance(session)
                    data.users = users
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func channel(user: UserDTO?) {
        guard (user != nil) else {
            return
        }
        channel.next(value: user!)
    }

    func accept(request: RequestDTO?, onError: @escaping () -> Void) {
        // refresh conversation list if successfully done.
        let onSuccess = {
            self.conversationModel.populate()
        }
        requestsModel.accept(request: request, onSuccess: onSuccess, onError: onError)
    }

    func decline(request: RequestDTO?, onError: @escaping () -> Void) {
        requestsModel.decline(request: request, onError: onError)
    }
}
