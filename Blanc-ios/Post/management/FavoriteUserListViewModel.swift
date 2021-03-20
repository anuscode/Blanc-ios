import Foundation
import RxSwift

class FavoriteUserListViewModel {

    private var users: [UserDTO] = []

    private var favoriteUserListModel: FavoriteUserListModel

    init(favoriteUserListModel: FavoriteUserListModel) {
        self.favoriteUserListModel = favoriteUserListModel
    }

    func observe() -> Observable<[UserDTO]> {
        favoriteUserListModel.observe()
    }
}
