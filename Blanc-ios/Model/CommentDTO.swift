import Foundation

class CommentDTO: Postable, Codable {
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
    var lv: Int?

    static func ==(lhs: CommentDTO, rhs: CommentDTO) -> Bool {
        lhs === rhs
    }
}

extension CommentDTO {

    @discardableResult
    static func flatten(comments: [CommentDTO]?,
                        result: LinkedList<Postable> = LinkedList(),
                        lv: Int = 1) -> LinkedList<Postable> {
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