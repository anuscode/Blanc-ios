import Foundation


enum ResourceType: String, Codable {
    case image = "IMAGE", video = "VIDEO"
}

class Resource: Codable {
    var type: ResourceType?
    var url: String?
}

class PostDTO: Postable, Codable {

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

    static func ==(lhs: PostDTO, rhs: PostDTO) -> Bool {
        lhs === rhs
    }
}

extension PostDTO {
    func isTextOnly() -> Bool {
        resources?.count ?? 0 == 0
    }

    func isDescriptionEmpty() -> Bool {
        description.isEmpty()
    }
}

extension PostDTO {
    @discardableResult
    static func flatten(posts: [PostDTO], result: LinkedList<Postable> = LinkedList()) -> LinkedList<Postable> {
        posts.forEach { post in
            result.append(post)
            post.comments?.flatten(post: post, result: result)
        }
        return result
    }
}

extension Array where Element == PostDTO {
    @discardableResult
    func flatten(result: LinkedList<Postable> = LinkedList()) -> LinkedList<Postable> {
        forEach { post in
            result.append(post)
            post.comments?.flatten(post: post, result: result)
        }
        return result
    }
}