import Foundation

protocol PostBodyDelegate: class {
    func favorite(post: PostDTO?)
    func presentSinglePostView(post: PostDTO?)
    func isCurrentUserFavoritePost(_ post: PostDTO?) -> Bool
}

