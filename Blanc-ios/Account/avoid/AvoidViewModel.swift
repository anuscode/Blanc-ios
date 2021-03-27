import Foundation
import RxSwift

class AvoidViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    internal let contacts: ReplaySubject = ReplaySubject<[Contact]>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let dismiss: PublishSubject = PublishSubject<Void>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    private let avoidModel: AvoidModel

    init(avoidModel: AvoidModel) {
        self.avoidModel = avoidModel
        subscribeAvoidModel()
    }

    private func subscribeAvoidModel() {
        avoidModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] contacts in
                self.contacts.onNext(contacts)
            })
            .disposed(by: disposeBag)
    }

    func populate() {
        let onError = { [unowned self] in
            toast.onNext("연락처 정보를 가져오지 못했습니다.")
        }
        loading.onNext(true)
        avoidModel.populate(onError: onError)
        loading.onNext(false)
    }

    func updateUserContacts() {
        let onSuccess = { [unowned self] in
            toast.onNext("이제 연락처에 등록 된 사람은 서로 추천에서 제외 됩니다.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [unowned self] in
                dismiss.onNext(Void())
            }
            loading.onNext(false)
        }
        let onError = { [unowned self] in
            toast.onNext("서버와 교신 중 에러가 발생 하였습니다.")
        }
        loading.onNext(true)
        avoidModel
            .updateUserContacts()
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: {
                onSuccess()
            }, onError: { err in
                log.error(err)
                onError()
            })
            .disposed(by: disposeBag)
    }
}
