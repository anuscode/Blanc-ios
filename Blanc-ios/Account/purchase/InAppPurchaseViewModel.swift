import Foundation
import RxDataSources
import RxSwift

class InAppPurchaseViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let inAppPurchaseModel: InAppPurchaseModel

    internal let products: ReplaySubject = ReplaySubject<[Product]>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    init(inAppPurchaseModel: InAppPurchaseModel) {
        self.inAppPurchaseModel = inAppPurchaseModel
        subscribeInAppPurchaseModel()
    }

    deinit {
        log.info("deinit in app purchase view model..")
    }

    private func subscribeInAppPurchaseModel() {
        inAppPurchaseModel
            .products
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] products in
                self.products.onNext(products)
            })
            .disposed(by: disposeBag)
    }

    func purchase(indexPath: IndexPath) {
        let onSuccess = { [unowned self] in
            toast.onNext("정상적으로 결제 되었습니다.")
            loading.onNext(false)
        }
        let onError = { [unowned self] in
            toast.onNext("결제 프로세스가 종료 되었습니다.")
            loading.onNext(false)
        }
        loading.onNext(true)
        inAppPurchaseModel.purchase(indexPath: indexPath, onSuccess: onSuccess, onError: onError)
    }
}
