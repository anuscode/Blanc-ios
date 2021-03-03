import Foundation
import RxSwift

class RequestsModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[RequestDTO]>.create(bufferSize: 1)

    private var session: Session

    private var requestService: RequestService

    private var requests: [RequestDTO] = []

    init(session: Session, requestService: RequestService) {
        self.session = session
        self.requestService = requestService
        populate()
        subscribeBroadcast()
        subscribeBackground()
    }

    func observe() -> Observable<[RequestDTO]> {
        observable
    }

    private func publish() {
        observable.onNext(requests)
    }

    func populate() {
        requestService.listRequests(uid: session.uid)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] requests in
                    self.requests = requests
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func subscribeBroadcast() {
        Broadcast.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { push in
                    if (push.isRequest()) {
                        self.insertRequest(requestId: push.requestId)
                    }
                    if (push.isMatched()) {
                        if let request = self.requests.first(where: { $0.id == push.requestId }) {
                            let index = self.requests.firstIndex(of: request)
                            self.requests.remove(at: index!)
                        }

                        if let requestId = push.requestId {
                            self.session.user?.userIdsMatched?.append(requestId)
                        }
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func subscribeBackground() {
        Background.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { push in
                    self.populate()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func insertRequest(requestId: String?) {
        requestService.getRequest(uid: session.uid, requestId: requestId)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { request in
                    self.requests.insert(request, at: 0)
                    if let userId = request.userFrom?.id {
                        self.session.user?.userIdsSentMeRequest?.append(userId)
                    }
                    self.publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func accept(request: RequestDTO?, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        requestService.updateRequest(uid: session.uid, requestId: request?.id, response: Response.ACCEPTED)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap({ _ -> Single<UserDTO> in self.session.refresh() })
                .subscribe(onSuccess: { _ in
                    if let index = self.requests.firstIndex(of: request!) {
                        self.requests.remove(at: index)
                        self.publish()
                    }
                    onSuccess() // refresh conversations.
                }, onError: { err in
                    onError()
                })
                .disposed(by: disposeBag)
    }

    func decline(request: RequestDTO?, onError: @escaping () -> Void) {
        requestService.updateRequest(uid: session.uid, requestId: request?.id, response: Response.DECLINED)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] in
                    let index = requests.firstIndex(of: request!)
                    if (index != nil) {
                        requests.remove(at: index!)
                        publish()
                    }
                }, onError: { err in
                    onError()
                })
                .disposed(by: disposeBag)
    }
}
