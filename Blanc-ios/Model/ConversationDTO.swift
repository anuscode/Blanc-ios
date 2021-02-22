import Foundation

enum Category: String, Codable {
    case message = "MESSAGE",
         voice = "VOICE",
         image = "IMAGE",
         video = "VIDEO",
         system = "SYSTEM"
}

class MessageDTO: NSObject, Codable {
    var id: String?
    var conversationId: String?
    var userId: String?
    var category: Category?
    var url: String?
    var message: String?
    var createdAt: Int?

    var isCurrentUserMessage: Bool? = false

    static func ==(lhs: MessageDTO, rhs: MessageDTO) -> Bool {
        lhs.id == rhs.id
    }
}

extension MessageDTO {
    static func from(push: PushDTO) -> MessageDTO {
        let message = MessageDTO()
        message.id = push.messageId
        message.conversationId = push.conversationId
        message.userId = push.userId
        // message.category = push.category
        message.url = push.url
        message.message = push.message
        message.createdAt = push.createdAt
        return message
    }
}

class ConversationDTO: NSObject, Codable {
    var _id: String?
    var id: String? {
        get {
            _id
        }
        set(newValue) {
            _id = newValue
        }
    }
    var title: String?
    var createdAt: Int?
    var participants: [UserDTO]?
    var participantsMapper: [UserDTO]?
    var messages: [MessageDTO]?
    var available: Bool?

    /** Not included in server model. **/
    var unreadMessageCount: Int? = 0
    var isShimmer: Bool? = false
    var currentUser: UserDTO?

    static func ==(lhs: ConversationDTO, rhs: ConversationDTO) -> Bool {
        lhs.id == rhs.id
    }
}

extension ConversationDTO {
    var partner: UserDTO? {
        get {
            if (currentUser == nil) {
                return nil
            }
            return participantsMapper?.first {
                $0.id != currentUser?.id
            }
        }
    }
}