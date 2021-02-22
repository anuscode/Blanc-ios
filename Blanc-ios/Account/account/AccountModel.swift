import Foundation

class AccountModel {

    var session: Session

    private let userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
    }
}
