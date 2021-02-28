import Foundation

class InAppPurchaseViewModel {

    private let inAppPurchaseModel: InAppPurchaseModel

    init(inAppPurchaseModel: InAppPurchaseModel) {
        self.inAppPurchaseModel = inAppPurchaseModel
    }

    func purchase(productId: String, onSuccess: @escaping () -> Void, onError: @escaping () -> Void) {
        inAppPurchaseModel.purchase(productId: productId, onSuccess: onSuccess, onError: onError)
    }
}
