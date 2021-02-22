import Foundation

class AccountViewModel {

    private let accountModel: AccountModel

    init(accountModel: AccountModel) {
        self.accountModel = accountModel
    }

    func session() -> Session {
        accountModel.session
    }

}
