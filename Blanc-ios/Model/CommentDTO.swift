import Foundation

class CommentDTO: Hashable, Codable {
    var _id: String? = ""
    var id: String? {
        get {
            _id
        }
        set {
            _id = newValue
        }
    }
    var commenter: UserDTO?
    var comment: String?
    var comments: [CommentDTO]?
    var createdAt: Int?
    var thumbUpUserIds: [String]?
    var thumbDownUserIds: [String]?
    var favorite: Bool?
    var isDeleted: Bool?
    var lv: Int?

    weak var post: PostDTO?

    private enum CodingKeys: CodingKey {
        case _id,
             commenter,
             comment,
             comments,
             createdAt,
             thumbUpUserIds,
             thumbDownUserIds,
             favorite,
             isDeleted,
             lv
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(commenter, forKey: .commenter)
        try container.encode(comment, forKey: .comment)
        try container.encode(comments, forKey: .comments)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(thumbUpUserIds, forKey: .thumbUpUserIds)
        try container.encode(thumbDownUserIds, forKey: .thumbDownUserIds)
        try container.encode(favorite, forKey: .favorite)
        try container.encode(isDeleted, forKey: .isDeleted)
        try container.encode(lv, forKey: .lv)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func ==(lhs: CommentDTO, rhs: CommentDTO) -> Bool {
        lhs === rhs
    }
}

extension CommentDTO {

    @discardableResult
    static func flatten(comments: [CommentDTO]?,
                        result: LinkedList<AnyHashable> = LinkedList(),
                        lv: Int = 1) -> LinkedList<AnyHashable> {
        comments?.forEach { comment in
            comment.lv = lv
            result.append(comment)
            if (comment.comments?.count ?? 0 > 0) {
                flatten(comments: comment.comments, result: result, lv: lv + 1)
            }
        }
        return result
    }
}

extension Array where Element == CommentDTO {
    @discardableResult
    func flatten(
        post: PostDTO?,
        result: LinkedList<AnyHashable> = LinkedList(),
        lv: Int = 1
    ) -> LinkedList<AnyHashable> {
        forEach { comment in
            comment.lv = lv
            comment.post = post
            result.append(comment)
            if let comments = comment.comments {
                comments.flatten(post: post, result: result, lv: lv + 1)
            }
        }
        return result
    }
}