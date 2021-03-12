import Foundation
import RxDataSources
import RxSwift
import FirebaseAuth
import StoreKit

class InAppPurchaseViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let inAppPurchaseModel: InAppPurchaseModel

    private let session: Session

    private let paymentService: PaymentService

    internal let products: ReplaySubject = ReplaySubject<[Product]>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    init(session: Session, paymentService: PaymentService, inAppPurchaseModel: InAppPurchaseModel) {
        self.session = session
        self.paymentService = paymentService
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
        let product = inAppPurchaseModel.getProduct(by: indexPath)
        let productId = product.productId

        guard let currentUser = auth.currentUser,
              let uid = session.uid,
              let userId = session.id else {
            return
        }
        let onPurchased: (SKPaymentTransaction) -> Void = { [unowned self] transaction in
            guard let receiptURL = Bundle.main.appStoreReceiptURL,
                  FileManager.default.fileExists(atPath: receiptURL.path),
                  let token = try? Data(contentsOf: receiptURL, options: .alwaysMapped).base64EncodedString(options: []) else {
                IAPManager.shared.finishPurchase(transaction: nil)
                toast.onNext("애플 결제 정보를 확인 할 수 없습니다.")
                return
            }

            log.info("token: \(token)")
            paymentService.purchase(currentUser: currentUser, uid: uid, userId: userId, token: token)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap({ [unowned self] payment in
                    session.refresh().map({ _ in payment })
                })
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { payment in
                    let result = payment.result
                    switch result {
                    case .DUPLICATE:
                        IAPManager.shared.finishPurchase(transaction: transaction)
                        toast.onNext("구매 결과가 정상적으로 반영 되었습니다.")
                    case .INVALID:
                        IAPManager.shared.finishPurchase(transaction: nil)
                        toast.onNext("유효하지 않은 구매 정보 입니다.")
                    case .PURCHASED:
                        IAPManager.shared.finishPurchase(transaction: transaction)
                        toast.onNext("구매 결과가 정상적으로 반영 되었습니다.")
                    case .none:
                        IAPManager.shared.finishPurchase(transaction: nil)
                        toast.onNext("정상적이지 않은 값이 전달 되었습니다. 걱정 마시고 개발팀에 문의 주세요.")
                    }
                    loading.onNext(false)
                }, onError: { err in
                    log.error(err)
                    IAPManager.shared.finishPurchase(transaction: nil)
                    toast.onNext("서버와의 교신에 실패 하였습니다. 이미 결제가 진행 된 경우 걱정 마시고 개발팀에 문의 주세요.")
                    loading.onNext(false)
                })
                .disposed(by: disposeBag)
        }

        let onFailed = { [unowned self] in
            // IAPManager.shared.finishPurchase(transaction: nil)
            loading.onNext(false)
            toast.onNext("애플 인앱 결제를 완료하지 못했습니다.")
        }

        let onCanceled = { [unowned self] in
            // IAPManager.shared.finishPurchase(transaction: nil)
            loading.onNext(false)
        }

        loading.onNext(true)
        IAPManager.shared.startPurchase(
            productId: productId,
            onPurchased: onPurchased,
            onRestored: onPurchased,
            onFailed: onFailed,
            onCanceled: onCanceled
        )
    }
}
