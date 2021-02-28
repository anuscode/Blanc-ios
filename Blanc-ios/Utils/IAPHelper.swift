import Foundation
import StoreKit

final class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    static let shared = IAPManager()

    var products = [SKProduct]()

    private var lock = DispatchSemaphore(value: 1)

    private var onPurchased: ((SKPaymentTransaction) -> Void)?

    private var onFailed: (() -> Void)?

    enum Product: String, CaseIterable {
        case point2500 = "ios.com.ground.blanc.point.2500.won",
             point4900 = "ios.com.ground.blanc.point.4900.won",
             point11000 = "ios.com.ground.blanc.point.11000.won",
             point20000 = "ios.com.ground.blanc.point.20000.won",
             point36000 = "ios.com.ground.blanc.point.36000.won",
             point79000 = "ios.com.ground.blanc.point.79000.won"
    }

    public func fetchProducts() {
        let request = SKProductsRequest(
                productIdentifiers: Set(Product.allCases.compactMap({ $0.rawValue }))
        )
        request.delegate = self
        request.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
    }

    public func purchase(productId: String,
                         onPurchased: @escaping (SKPaymentTransaction) -> Void,
                         onFailed: @escaping () -> Void) {
        lock.wait()
        log.info("purchase begins..")
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        guard let storeKitProduct = products.first(where: { $0.productIdentifier == productId }) else {
            return
        }
        self.onPurchased = onPurchased
        self.onFailed = onFailed
        let paymentRequest = SKPayment(product: storeKitProduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(paymentRequest)
    }

    // Should be performed after purchase is called.
    public func finishTransaction(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
        SKPaymentQueue.default().remove(self)
        lock.signal()
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({ transaction in
            switch (transaction.transactionState) {
            case .purchased:
                purchase(transaction)
                onPurchased?(transaction)
                log.info("purchased")
            case .failed:
                fail(transaction)
                onFailed?()
                log.info("failed")
                break
            case .restored:
                restore(transaction)
                onPurchased?(transaction)
                log.info("restored")
                break
            case .deferred:
                log.info("deferred")
                break
            case .purchasing:
                log.info("purchasing")
                break
            @unknown default:
                fatalError()
            }
        })
    }

    private func purchase(_ transaction: SKPaymentTransaction) {
        log.info("complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
    }

    private func restore(_ transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {
            return
        }
        log.info("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
    }

    private func fail(_ transaction: SKPaymentTransaction) {
        log.info("fail...")

        SKPaymentQueue.default().remove(self)
        lock.signal()

        if let transactionError = transaction.error as NSError?,
           let localizedDescription = transaction.error?.localizedDescription,
           transactionError.code != SKError.paymentCancelled.rawValue {
            log.info("Transaction Error: \(localizedDescription)")
        }
    }

    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else {
            return
        }
        let notificationName = Notification.Name("IAPHelperPurchaseNotification")
        NotificationCenter.default.post(name: notificationName, object: identifier)
    }
}
