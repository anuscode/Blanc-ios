import Foundation
import RxSwift
import FirebaseAuth

class InAppPurchaseModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let session: Session

    private let paymentService: PaymentService

    init(session: Session, paymentService: PaymentService) {
        self.session = session
        self.paymentService = paymentService
    }

    func purchase(productId: String, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        IAPManager.shared.purchase(
                productId: productId,
                onPurchased: { [unowned self] transaction in

                    guard let uid = session.uid,
                          let userId = session.id,
                          let receiptURL = Bundle.main.appStoreReceiptURL,
                          let token = try? Data(contentsOf: receiptURL).base64EncodedString() else {
                        onError()
                        return
                    }

                    paymentService.purchase(
                                    currentUser: auth.currentUser!,
                                    uid: uid,
                                    userId: userId,
                                    token: token
                            )
                            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                            .flatMap({ payment in
                                session.refresh().map({ _ in payment })
                            })
                            .observeOn(MainScheduler.instance)
                            .subscribe(onSuccess: { payment in
                                if (payment.result != true) {
                                    onError()
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
                }
        )
    }
}
