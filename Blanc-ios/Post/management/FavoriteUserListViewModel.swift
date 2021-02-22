import Foundation
import RxSwift

class FavoriteUserListViewModel {

    var users: [UserDTO] = []

    var favoriteUserListModel: FavoriteUserListModel

    init(favoriteUserListModel: FavoriteUserListModel) {
        self.favoriteUserListModel = favoriteUserListModel
    }

    func observe() -> Observable<[UserDTO]> {
        favoriteUserListModel.observe()
    }

    func channel(user: UserDTO?) {
        favoriteUserListModel.channel(user: user)
    }
}
