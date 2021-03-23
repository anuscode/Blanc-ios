import Foundation
import RxSwift

class AlarmViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let alarmModel: AlarmModel

    private let observable: ReplaySubject = ReplaySubject<[PushDTO]>.create(bufferSize: 1)

    private var pushes: [PushDTO] = []

    init(alarmModel: AlarmModel) {
        self.alarmModel = alarmModel
        subscribeAlarmModel()
    }

    func observe() -> Observable<[PushDTO]> {
        observable
    }

    private func publish() {
        observable.onNext(pushes)
    }

    private func subscribeAlarmModel() {
        alarmModel
            .observe()
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] pushes in
                self.pushes = pushes
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func getUser(userId: String, onSuccess: @escaping (_ user: UserDTO) -> Void, onError: @escaping () -> Void) {
        alarmModel.getUser(userId: userId, onSuccess: onSuccess, onError: onError)
    }

    func getPost(postId: String, onSuccess: @escaping (_ post: PostDTO) -> Void, onError: @escaping () -> Void) {
        alarmModel.getPost(postId: postId, onSuccess: onSuccess, onError: onError)
    }

    func updateAllAlarmsAsRead() {
        alarmModel.updateAllAlarmsAsRead()
    }
}
