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
        requestService
            .listRequests(uid: session.uid)
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
        Broadcast
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] push in
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
        Background
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] push in
                self.populate()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func insertRequest(requestId: String?) {
        guard let requestId = requestId else {
            log.error("requestId is required value but not found..")
            return
        }
        requestService
            .getRequest(uid: session.uid, requestId: requestId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { request in
                if let userId = request.userFrom?.id {
                    self.session.user?.userIdsSentMeRequest?.append(userId)
                    self.session.publish()
                }
                self.requests.insert(request, at: 0)
                self.publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func accept(request: RequestDTO?, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        guard let uid = session.uid,
              let requestId = request?.id else {
            return
        }

        requestService
            .updateRequest(uid: uid, requestId: requestId, response: .ACCEPTED)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onNext: { _ in
                if let userId = request?.userFrom?.id {
                    self.session.user?.userIdsMatched?.append(userId)
                    self.session.publish()
                }
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { _ in
                if let index = self.requests.firstIndex(where: { $0.id == requestId }) {
                    self.requests.remove(at: index)
                }
                self.publish()
                onSuccess()
            }, onError: { err in
                onError()
            })
            .disposed(by: disposeBag)
    }

    func decline(request: RequestDTO?, onError: @escaping () -> Void) {
        guard let uid = session.uid,
              let requestId = request?.id else {
            return
        }
        requestService
            .updateRequest(uid: uid, requestId: requestId, response: .DECLINED)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onNext: { _ in
                if let userId = request?.userFrom?.id {
                    self.session.user?.userIdsUnmatched?.append(userId)
                    self.session.publish()
                }
            })
            .subscribe(onSuccess: { _ in
                if let index = self.requests.firstIndex(where: { $0.id == requestId }) {
                    self.requests.remove(at: index)
                }
                self.publish()
            }, onError: { err in
                onError()
            })
            .disposed(by: disposeBag)
    }
}
