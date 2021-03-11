import Foundation
import RxSwift
import RxDataSources
import FirebaseAuth

class InAppPurchaseModel {

    private class Repository {
        let products: [Product] = [
            Product(productId: "ios.com.ground.blanc.point.2500.won", title: "포인트 10", discount: "할인 없음 😔", price: "₩2,500"),
            Product(productId: "ios.com.ground.blanc.point.4900.won", title: "포인트 20", discount: "약 2% 할인", price: "₩4,900"),
            Product(productId: "ios.com.ground.blanc.point.11000.won", title: "포인트 50", discount: "약 8.3% 할인", price: "₩11,000", tag: "할인율 대비 가격이 문안 합니다. 👍"),
            Product(productId: "ios.com.ground.blanc.point.20000.won", title: "포인트 100", discount: "약 16.6% 할인", price: "₩20,000", tag: "보통 이 상품이 가장 적절 합니다. 😃"),
            Product(productId: "ios.com.ground.blanc.point.36000.won", title: "포인트 200", discount: "약 25% 할인", price: "₩36,000"),
            Product(productId: "ios.com.ground.blanc.point.79000.won", title: "포인트 500", discount: "약 37% 할인", price: "₩79,000")
        ]
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let session: Session

    private let paymentService: PaymentService

    internal let products: ReplaySubject = ReplaySubject<[Product]>.create(bufferSize: 1)

    private let repository: Repository = Repository()

    init(session: Session, paymentService: PaymentService) {
        self.session = session
        self.paymentService = paymentService
        populate()
    }

    deinit {
        log.info("deinit in app purchase model..")
    }

    private func populate() {
        products.onNext(repository.products)
    }

    func purchase(indexPath: IndexPath, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        let product = repository.products[indexPath.row]
        let productId = product.productId

        guard let currentUser = auth.currentUser,
              let uid = session.uid,
              let userId = session.id else {
            return
        }

        IAPManager.shared.purchase(
            productId: productId,
            onPurchased: { [unowned self] transaction in

                guard let receiptURL = Bundle.main.appStoreReceiptURL,
                      let token = try? Data(contentsOf: receiptURL).base64EncodedString() else {
                    onError()
                    return
                }
                paymentService.purchase(
                        currentUser: currentUser,
                        uid: uid,
                        userId: userId,
                        token: token
                    )
                    .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                    .flatMap({ [unowned self] payment in
                        session.refresh().map({ _ in payment })
                    })
                    .observeOn(MainScheduler.instance)
                    .subscribe(onSuccess: { payment in
                        if (payment.result != true) {
                            return
                        }
                        IAPManager.shared.finishTransaction(transaction: transaction)
                        onSuccess()
                    }, onError: { err in
                        log.error(err)
                        onError()
                    })
                    .disposed(by: disposeBag)
            },
            onFailed: {
                onError()
                IAPManager.shared.lock.signal()
            }
        )
    }
}
