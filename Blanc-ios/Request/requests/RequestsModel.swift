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
            .do(onNext: { [unowned self] requests in
                // loop to calculate and set a distance from current user.
                let users = requests.map({ $0.userFrom }).filter({ $0 != nil }) as! [UserDTO]
                users.distance(session)
            })
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
                    insertRequest(requestId: push.requestId)
                }
                if (push.isMatched()) {
                    if let request = requests.first(where: { $0.id == push.requestId }) {
                        let index = requests.firstIndex(of: request)
                        requests.remove(at: index!)
                    }
                    if let requestId = push.requestId {
                        session.user?.userIdsMatched?.append(requestId)
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
                populate()
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
            .subscribe(onSuccess: { [unowned self] request in
                if let userId = request.userFrom?.id {
                    session.user?.userIdsSentMeRequest?.append(userId)
                    session.publish()
                }
                requests.insert(request, at: 0)
                publish()
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
            .do(onNext: { [unowned self] _ in
                if let userId = request?.userFrom?.id {
                    session.user?.userIdsMatched?.append(userId)
                    session.publish()
                }
            })
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] _ in
                if let index = requests.firstIndex(where: { $0.id == requestId }) {
                    requests.remove(at: index)
                }
                publish()
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
            .do(onNext: { [unowned self] _ in
                if let userId = request?.userFrom?.id {
                    session.user?.userIdsUnmatched?.append(userId)
                    session.publish()
                }
            })
            .subscribe(onSuccess: { [unowned self] _ in
                if let index = requests.firstIndex(where: { $0.id == requestId }) {
                    requests.remove(at: index)
                }
                publish()
            }, onError: { err in
                onError()
            })
            .disposed(by: disposeBag)
    }
}
