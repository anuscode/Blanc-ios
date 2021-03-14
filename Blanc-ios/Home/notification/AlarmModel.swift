import Foundation
import RxSwift

class AlarmModel {

    private let observable: ReplaySubject = ReplaySubject<[PushDTO]>.create(bufferSize: 1)

    private let disposeBag: DisposeBag = DisposeBag()

    private let session: Session

    private let userService: UserService

    private let postService: PostService

    private let alarmService: AlarmService

    private var pushes: [PushDTO] = []

    init(session: Session, userService: UserService, postService: PostService, alarmService: AlarmService) {
        self.session = session
        self.userService = userService
        self.postService = postService
        self.alarmService = alarmService
        populate()
        subscribeBroadcast()
        subscribeBackground()
    }

    deinit {
        log.info("deinit AlarmModel..")
    }

    func observe() -> Observable<[PushDTO]> {
        observable
    }

    private func publish() {
        observable.onNext(pushes)
    }

    private func populate() {
        alarmService
            .listAlarms(uid: session.uid)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { [unowned self] pushes in
                self.pushes = pushes.sorted(by: {
                    $0.createdAt ?? 0 > $1.createdAt ?? 0
                })
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
                pushes.insert(push, at: 0)
                publish()
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

    func getUser(userId: String, onSuccess: @escaping (_ user: UserDTO) -> Void, onError: @escaping () -> Void) -> Void {
        let parameters = ["id": userId]
        userService
            .getUser(parameters: parameters)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { user in
                onSuccess(user)
            }, onError: { err in
                onError()
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func getPost(postId: String, onSuccess: @escaping (_ post: PostDTO) -> Void, onError: @escaping () -> Void) -> Void {
        postService
            .getPost(postId: postId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { post in
                onSuccess(post)
            }, onError: { err in
                onError()
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func updateAllAlarmsAsRead() {
        // if it's all read, skip update.
        if pushes.first(where: { $0.isRead != true }) == nil {
            log.info("skipping.. because all alarms are marked as read.")
            return
        }
        alarmService
            .updateAllAlarmsAsRead(uid: session.uid)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: {
                self.pushes.forEach({ push in
                    push.isRead = true
                })
                self.publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}
