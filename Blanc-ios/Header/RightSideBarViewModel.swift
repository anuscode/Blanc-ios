import Foundation
import RxSwift

class RightSideBarData {
    var point: Float = 0.0
    var hasUnreadPushes: Bool = true
}

class RightSideBarViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let session: Session

    private let alarmModel: AlarmModel

    private let observable: ReplaySubject = ReplaySubject<RightSideBarData>.create(bufferSize: 1)

    private var data: RightSideBarData = RightSideBarData()

    init(session: Session, alarmModel: AlarmModel) {
        self.session = session
        self.alarmModel = alarmModel
        subscribeSession()
        subscribeAlarmModel()
    }

    func observe() -> Observable<RightSideBarData> {
        observable
    }

    private func publish() {
        observable.onNext(data)
    }

    private func subscribeSession() {
        session.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] user in
                    data.point = user.point ?? 0.0
                    publish()
                }, onError: { err in
                    log.error(err)
                }).disposed(by: disposeBag)
    }

    private func subscribeAlarmModel() {
        alarmModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] pushes in
                    data.hasUnreadPushes = pushes.filter {
                        $0.isRead != true
                    }.count > 0
                    publish()
                }, onError: { err in
                    log.error(err)
                }).disposed(by: disposeBag)
    }
}
