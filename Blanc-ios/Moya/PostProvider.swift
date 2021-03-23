import Foundation
import Moya


enum PostProvider {

    // GET
    case listPosts(uid: String?, lastId: String?)
    case getPost(postId: String?)
    case listAllFavoriteUsers(uid: String?, postId: String?)

    // POST
    case createPost(uid: String?, files: [UIImage], description: String?, enableComment: Bool)
    case createFavorite(uid: String?, postId: String?)
    case createComment(uid: String?, postId: String?, commentId: String?, comment: String)
    case createThumbUp(uid: String?, postId: String?, commentId: String?)
    case createThumbDown(uid: String?, postId: String?, commentId: String?)

    // DELETE
    case deletePost(uid: String?, postId: String?)
    case deleteFavorite(uid: String?, postId: String?)
    case deleteComment(uid: String?, postId: String?, commentId: String?)
    case deleteThumbUp(uid: String?, postId: String?, commentId: String?)
    case deleteThumbDown(uid: String?, postId: String?, commentId: String?)

}

extension PostProvider: TargetType {

    var baseURL: URL {
        URL(string: Constant.url)!
    }

    var path: String {
        switch self {
        case .listPosts(uid: _, lastId: _):
            return "posts"
        case .getPost(postId: let postId):
            return "posts/\(postId ?? "")"
        case .listAllFavoriteUsers(uid: _, postId: let postId):
            return "posts/\(postId ?? "")/favorite"
        case .createPost(uid: _, files: _, description: _, enableComment: _):
            return "posts"
        case .createFavorite(uid: _, postId: let postId):
            return "posts/\(postId ?? "")/favorite"
        case .createComment(uid: _, postId: let postId, commentId: _, comment: _):
            return "posts/\(postId ?? "")/comments"
        case .createThumbUp(uid: _, postId: let postId, commentId: let commentId):
            return "posts/\(postId ?? "")/comments/\(commentId ?? "")/thumb_up"
        case .createThumbDown(uid: _, postId: let postId, commentId: let commentId):
            return "posts/\(postId ?? "")/comments/\(commentId ?? "")/thumb_down"
        case .deletePost(uid: _, postId: let postId):
            return "posts/\(postId ?? "")"
        case .deleteFavorite(uid: _, postId: let postId):
            return "posts/\(postId ?? "")/favorite"
        case .deleteComment(uid: _, postId: let postId, commentId: let commentId):
            return "posts/\(postId ?? "")/comments/\(commentId ?? "")"
        case .deleteThumbUp(uid: _, postId: let postId, commentId: let commentId):
            return "posts/\(postId ?? "")/comments/\(commentId ?? "")/thumb_up"
        case .deleteThumbDown(uid: _, postId: let postId, commentId: let commentId):
            return "posts/\(postId ?? "")/comments/\(commentId ?? "")/thumb_down"
        }
    }

    var method: Moya.Method {
        switch self {
        case .listPosts(uid: _, lastId: _):
            return .get
        case .getPost(postId: _):
            return .get
        case .listAllFavoriteUsers(uid: _, postId: _):
            return .get
        case .createPost(uid: _, files: _, description: _, enableComment: _):
            return .post
        case .createFavorite(uid: _, postId: _):
            return .post
        case .createComment(uid: _, postId: _, commentId: _, comment: _):
            return .post
        case .createThumbUp(uid: _, postId: _, commentId: _):
            return .post
        case .createThumbDown(uid: _, postId: _, commentId: _):
            return .post
        case .deletePost(uid: _, postId: _):
            return .delete
        case .deleteFavorite(uid: _, postId: _):
            return .delete
        case .deleteComment(uid: _, postId: _, commentId: _):
            return .delete
        case .deleteThumbUp(uid: _, postId: _, commentId: _):
            return .delete
        case .deleteThumbDown(uid: _, postId: _, commentId: _):
            return .delete
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {

        case .listPosts(uid:_, lastId: let lastId):
            return .requestParameters(
                parameters: ["last_id": lastId ?? ""],
                encoding: URLEncoding.queryString
            )
        case .getPost(postId: _):
            return .requestPlain
        case .listAllFavoriteUsers(uid: _, postId: _):
            return .requestPlain
        case .createPost(uid: _, files: let files, description: let description, enableComment: let enableComment):
            let descriptionData = description?.data(using: String.Encoding.utf8) ?? Data()
            let enableCommentData = String(enableComment).data(using: String.Encoding.utf8) ?? Data()

            var formData: [Moya.MultipartFormData] = [
                Moya.MultipartFormData(provider: .data(descriptionData), name: "description"),
                Moya.MultipartFormData(provider: .data(enableCommentData), name: "enable_comment")
            ]

            files.enumerated().forEach { index, file in
                let imageData = file.jpegData(compressionQuality: 1)
                if (imageData != nil) {
                    formData.append(
                        Moya.MultipartFormData(
                            provider: .data(imageData!),
                            name: "post_image_\(index)",
                            fileName: "post_image_\(index).jpeg",
                            mimeType: "image/jpeg"
                        )
                    )
                }
            }

            return .uploadMultipart(formData)
        case .createFavorite(uid: _, postId: _):
            return .requestPlain

        case .createComment(uid: _, postId: _, commentId: let commentId, comment: let comment):
            return .requestParameters(parameters: [
                "comment_id": commentId ?? "", "comment": comment], encoding: URLEncoding.httpBody)

        case .createThumbUp(uid: _, postId: _, commentId: _):
            return .requestPlain
        case .createThumbDown(uid: _, postId: _, commentId: _):
            return .requestPlain
        case .deletePost(uid: _, postId: _):
            return .requestPlain
        case .deleteFavorite(uid: _, postId: _):
            return .requestPlain
        case .deleteComment(uid: _, postId: _, commentId: _):
            return .requestPlain
        case .deleteThumbUp(uid: _, postId: _, commentId: _):
            return .requestPlain
        case .deleteThumbDown(uid: _, postId: _, commentId: _):
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-type": "application/json"]
        switch self {

        case .listPosts(uid: let uid, lastId: _):
            headers["uid"] = uid
            return headers
        case .getPost(postId: _):
            return headers
        case .listAllFavoriteUsers(uid: let uid, postId: _):
            headers["uid"] = uid
            return headers
        case .createPost(uid: let uid, files: _, description: _, enableComment: _):
            headers["uid"] = uid
            return headers
        case .createFavorite(uid: let uid, postId: _):
            headers["uid"] = uid
            return headers
        case .createComment(uid: let uid, postId: _, commentId: _, comment: _):
            var _headers = ["Content-type": "application/x-www-form-urlencoded; charset=utf-8"]
            _headers["uid"] = uid
            return _headers
        case .createThumbUp(uid: let uid, postId: _, commentId: _):
            headers["uid"] = uid
            return headers
        case .createThumbDown(uid: let uid, postId: _, commentId: _):
            headers["uid"] = uid
            return headers
        case .deletePost(uid: let uid, postId: _):
            headers["uid"] = uid
            return headers
        case .deleteFavorite(uid: let uid, postId: _):
            headers["uid"] = uid
            return headers
        case .deleteComment(uid: let uid, postId: _, commentId: _):
            headers["uid"] = uid
            return headers
        case .deleteThumbUp(uid: let uid, postId: _, commentId: _):
            headers["uid"] = uid
            return headers
        case .deleteThumbDown(uid: let uid, postId: _, commentId: _):
            headers["uid"] = uid
            return headers
        }
    }
}
