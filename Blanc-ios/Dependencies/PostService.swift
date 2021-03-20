import Foundation
import Moya
import RxSwift
import Firebase
import RxFirebase


class PostService {
    let provider = MoyaProvider<PostProvider>(plugins: [
        // NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
    ])

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    // GET
    func listPosts(uid: String?, lastId: String?) -> Single<[PostDTO]> {
        provider.rx
            .request(.listPosts(uid: uid, lastId: lastId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map([PostDTO].self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func getPost(postId: String?) -> Single<PostDTO> {
        provider.rx
            .request(.getPost(postId: postId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map(PostDTO.self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listAllFavoriteUsers(uid: String?, postId: String?) -> Single<[UserDTO]> {
        provider.rx
            .request(.listAllFavoriteUsers(uid: uid, postId: postId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map([UserDTO].self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    // POST
    func createPost(uid: String?, files: [UIImage], description: String?, enableComment: Bool) -> Single<Void> {
        provider.rx
            .request(.createPost(uid: uid, files: files, description: description, enableComment: enableComment))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in
                Void()
            })
    }

    func createFavorite(uid: String?, postId: String?) -> Single<Void> {
        provider.rx
            .request(.createFavorite(uid: uid, postId: postId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map { _ in
                Void()
            }
    }

    func createComment(uid: String?, postId: String?, commentId: String?, comment: String) -> Single<CommentDTO> {
        provider.rx
            .request(.createComment(uid: uid, postId: postId, commentId: commentId, comment: comment))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map(CommentDTO.self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func createThumbUp(uid: String?, postId: String?, commentId: String?) -> Single<Void> {
        provider.rx
            .request(.createThumbUp(uid: uid, postId: postId, commentId: commentId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map { _ in
                Void()
            }
    }

    func createThumbDown(uid: String?, postId: String?, commentId: String?) -> Single<Void> {
        provider.rx
            .request(.createThumbDown(uid: uid, postId: postId, commentId: commentId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map { _ in
                Void()
            }
    }

    // DELETE
    func deletePost(uid: String?, postId: String?) -> Single<PostDTO> {
        provider.rx
            .request(.deletePost(uid: uid, postId: postId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map(PostDTO.self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func deleteFavorite(uid: String?, postId: String?) -> Single<Void> {
        provider.rx
            .request(.deleteFavorite(uid: uid, postId: postId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in Void() })
    }

    func deleteComment(uid: String?, postId: String?, commentId: String?) -> Single<Void> {
        provider.rx
            .request(.deleteComment(uid: uid, postId: postId, commentId: commentId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in Void() })
    }

    func deleteThumbUp(uid: String?, postId: String?, commentId: String?) -> Single<Void> {
        provider.rx
            .request(.deleteThumbUp(uid: uid, postId: postId, commentId: commentId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in Void() })
    }

    func deleteThumbDown(uid: String?, postId: String?, commentId: String?) -> Single<Void> {
        provider.rx
            .request(.deleteThumbDown(uid: uid, postId: postId, commentId: commentId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in Void() })
    }
}
