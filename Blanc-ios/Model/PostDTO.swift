import Foundation

class Resource: Codable {

    enum ResourceType: String, Codable {
        case image = "IMAGE", video = "VIDEO"
    }

    var type: ResourceType?
    var url: String?
}

class PostDTO: Hashable, Codable {

    var uuid: UUID? = UUID()

    var _id: String? = ""
    var id: String? {
        get {
            _id
        }
        set {
            _id = newValue
        }
    }
    var author: UserDTO?
    var title: String?
    var description: String?
    var resources: [Resource]?
    var favoriteUserIds: [String]?
    var favoriteUsers: [UserDTO]?
    var createdAt: Int?
    var favorite: Bool?
    var favoriteCount: Int?
    var comments: [CommentDTO]?
    var enableComment: Bool?
    var isDeleted: Bool?

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid?.uuidString)
    }

    static func ==(lhs: PostDTO, rhs: PostDTO) -> Bool {
        lhs === rhs
    }
}

extension PostDTO {
    func isTextOnly() -> Bool {
        resources?.count ?? 0 == 0
    }
}

extension PostDTO {
    @discardableResult
    static func flatten(posts: [PostDTO], result: LinkedList<AnyHashable> = LinkedList()) -> LinkedList<AnyHashable> {
        posts.forEach { post in
            result.append(post)
            post.comments?.flatten(post: post, result: result)
        }
        return result
    }
}

extension Array where Element == PostDTO {
    @discardableResult
    func flatten(result: LinkedList<AnyHashable> = LinkedList()) -> LinkedList<AnyHashable> {
        forEach { post in
            result.append(post)
            post.comments?.flatten(post: post, result: result)
        }
        return result
    }
}