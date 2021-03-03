import Foundation
import RxSwift

class PushSettingViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let pushSettingModel: PushSettingModel

    private let observable: ReplaySubject = ReplaySubject<PushSetting>.create(bufferSize: 1)

    private var pushSetting: PushSetting?

    init(pushSettingModel: PushSettingModel) {
        self.pushSettingModel = pushSettingModel
        subscribePushSettingModel()
    }

    private func publish() {
        if (pushSetting == nil) {
            return
        }
        observable.onNext(pushSetting!)
    }

    func observe() -> Observable<PushSetting> {
        observable
    }

    private func subscribePushSettingModel() {
        pushSettingModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] pushSetting in
                    self.pushSetting = pushSetting
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func update(_ attribute: PushSettingAttribute, onError: @escaping () -> Void) {
        pushSettingModel.update(attribute, onError: onError)
    }
}
