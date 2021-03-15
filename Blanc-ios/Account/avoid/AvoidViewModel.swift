import Foundation
import RxSwift

class AvoidViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    internal let contacts: ReplaySubject = ReplaySubject<[Contact]>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let popToRootView: PublishSubject = PublishSubject<Void>()

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
        avoidModel.populate(onError: onError)
    }

    func updateUserContacts() {
        let onSuccess = { [unowned self] in
            toast.onNext("이제 연락처에 등록 된 사람은 서로 추천에서 제외 됩니다.")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [unowned self] in
                popToRootView.onNext(Void())
            }
        }
        let onError = { [unowned self] in
            toast.onNext("아는 사람 만나지 않기 등록 중 에러가 발생 하였습니다.")
        }
        avoidModel.updateUserContacts(onSuccess: onSuccess, onError: onError)
    }
}
