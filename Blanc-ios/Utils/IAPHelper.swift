import Foundation
import StoreKit

final class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    static let shared = IAPManager()

    internal var products = [SKProduct]()

    internal var lock = DispatchSemaphore(value: 1)

    private var onPurchased: ((SKPaymentTransaction) -> Void)?

    private var onRestored: ((SKPaymentTransaction) -> Void)?

    private var onFailed: (() -> Void)?

    private var onCanceled: (() -> Void)?

    enum Product: String, CaseIterable {
        case point2500 = "ios.com.ground.blanc.point.2500.won",
             point4900 = "ios.com.ground.blanc.point.4900.won",
             point11000 = "ios.com.ground.blanc.point.11000.won",
             point20000 = "ios.com.ground.blanc.point.20000.won",
             point36000 = "ios.com.ground.blanc.point.36000.won",
             point79000 = "ios.com.ground.blanc.point.79000.won"
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
    }

    public func fetchProducts() {
        let request = SKProductsRequest(
            productIdentifiers: Set(Product.allCases.compactMap({ $0.rawValue }))
        )
        request.delegate = self
        request.start()
    }

    public func startPurchase(productId: String,
                              onPurchased: @escaping (SKPaymentTransaction) -> Void,
                              onRestored: @escaping (SKPaymentTransaction) -> Void,
                              onFailed: @escaping () -> Void,
                              onCanceled: @escaping () -> Void) {
        lock.wait()
        log.info("beginning purchase process..")
        guard SKPaymentQueue.canMakePayments() else {
            log.info("unavailable for purchasing process.. terminating it..")
            return
        }
        guard let storeKitProduct = products.first(where: { $0.productIdentifier == productId }) else {
            return
        }
        self.onPurchased = onPurchased
        self.onRestored = onRestored
        self.onFailed = onFailed
        self.onCanceled = onCanceled
        let paymentRequest = SKPayment(product: storeKitProduct)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(paymentRequest)
    }

    // Should be performed after purchase is called.
    public func finishPurchase(transaction: SKPaymentTransaction?) {
        if let transaction = transaction {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        SKPaymentQueue.default().remove(self)
        lock.signal()
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({ transaction in
            switch (transaction.transactionState) {
            case .purchased: purchase(transaction)
            case .failed: fail(transaction)
            case .restored: restore(transaction)
            case .deferred: log.info("deferred..")
            case .purchasing: log.info("purchasing..")
            @unknown default: fatalError()
            }
        })
    }

    private func purchase(_ transaction: SKPaymentTransaction) {
        let productIdentifier = transaction.payment.productIdentifier
        log.info("completed...\(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        onPurchased?(transaction)
    }

    private func restore(_ transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else {
            return
        }
        log.info("restored... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        onPurchased?(transaction)
    }

    private func fail(_ transaction: SKPaymentTransaction) {
        log.info("failed...")
        if let transactionError = transaction.error as? SKError,
           transactionError.code != .paymentCancelled {
            let localizedDescription = transaction.error?.localizedDescription ?? "unknown error.."
            log.info("Transaction Error: \(localizedDescription)")
            onFailed?()
        } else {
            onCanceled?()
        }
        SKPaymentQueue.default().remove(self)
        lock.signal()
    }

    private func deliverPurchaseNotificationFor(identifier: String) {
        let notificationName = Notification.Name("IAPHelperPurchaseNotification")
        NotificationCenter.default.post(name: notificationName, object: identifier)
    }
}
