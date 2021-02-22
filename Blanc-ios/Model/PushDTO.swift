import Foundation

var foregroundNotifications: [PushType] = [
    PushType.POKE, PushType.REQUEST, PushType.COMMENT, PushType.FAVORITE, PushType.MATCHED,
    PushType.THUMB_UP, PushType.OPENED, PushType.LOG_OUT, PushType.APPROVAL, PushType.LOOK_UP,
    PushType.STAR_RATING
]

enum PushType: String, Codable {
    case LOG_OUT = "LOG_OUT",
         APPROVAL = "APPROVAL",
         CONVERSATION = "CONVERSATION",
         POKE = "POKE",
         REQUEST = "REQUEST",
         COMMENT = "COMMENT",
         FAVORITE = "FAVORITE",
         MATCHED = "MATCHED",
         THUMB_UP = "THUMB_UP",
         OPENED = "OPENED",
         LOOK_UP = "LOOK_UP",
         STAR_RATING = "STAR_RATING"
}


class PushDTO: NSObject, Decodable {
    var pushId: String?
    var userId: String?
    var url: String?
    var postId: String?
    var commentId: String?
    var requestId: String?
    var conversationId: String?
    var messageId: String?

    var pushType: PushType?
    var nickName: String?
    var imageUrl: String?
    var message: String?
    var createdAt: Int?
    var isRead: Bool?

    enum CodingKeys: String, CodingKey {
        case pushId, userId, url, postId, commentId, requestId, conversationId, messageId,
             pushType, nickName, imageUrl, message, createdAt, isRead
    }

    static func ==(lhs: PushDTO, rhs: PushDTO) -> Bool {
        lhs.pushId == rhs.pushId
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            pushId = try values.decode(String?.self, forKey: .pushId)
        } catch {
            pushId = nil
        }

        do {
            userId = try values.decode(String?.self, forKey: .userId)
        } catch {
            userId = nil
        }

        do {
            url = try values.decode(String?.self, forKey: .url)
        } catch {
            url = nil
        }

        do {
            postId = try values.decode(String?.self, forKey: .postId)
        } catch {
            postId = nil
        }

        do {
            commentId = try values.decode(String?.self, forKey: .commentId)
        } catch {
            commentId = nil
        }

        do {
            requestId = try values.decode(String?.self, forKey: .requestId)
        } catch {
            requestId = nil
        }

        do {
            conversationId = try values.decode(String?.self, forKey: .conversationId)
        } catch {
            conversationId = nil
        }

        do {
            messageId = try values.decode(String?.self, forKey: .messageId)
        } catch {
            messageId = nil
        }

        do {
            pushType = try values.decode(PushType?.self, forKey: .pushType)
        } catch {
            pushType = nil
        }

        do {
            nickName = try values.decode(String?.self, forKey: .nickName)
        } catch {
            nickName = nil
        }

        do {
            imageUrl = try values.decode(String?.self, forKey: .imageUrl)
        } catch {
            imageUrl = nil
        }

        do {
            message = try values.decode(String?.self, forKey: .message)
        } catch {
            message = nil
        }

        do {
            createdAt = Int(try values.decode(String.self, forKey: .createdAt))
        } catch {
            createdAt = nil
        }

        do {
            let boolString = try values.decode(String.self, forKey: .isRead)
            isRead = (boolString == "true" || boolString == "True") ? true : false
        } catch {
            isRead = false
        }
    }

    static func decode(_ userInfo: [AnyHashable: Any]) throws -> PushDTO {
        let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let push = try decoder.decode(PushDTO.self, from: data)
        return push
    }
}

//Just in case you want to encode the House struct
extension PushDTO: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pushId, forKey: .pushId)
        try container.encode(userId, forKey: .userId)
        try container.encode(postId, forKey: .postId)
        try container.encode(commentId, forKey: .commentId)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(conversationId, forKey: .conversationId)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(pushType, forKey: .pushType)
        try container.encode(nickName, forKey: .nickName)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(message, forKey: .message)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(isRead, forKey: .isRead)
    }
}

extension PushDTO {

    func isApproval() -> Bool {
        pushType == PushType.APPROVAL
    }

    func isPoke() -> Bool {
        pushType == PushType.POKE && userId.isNotEmpty()
    }

    func isLookUp() -> Bool {
        pushType == PushType.LOOK_UP && userId.isNotEmpty()
    }

    /**
     Push when someone requests to me
     1. appends a request in the RequestsModel
     ----------------------------------------------------------
     2. appends a userId to userIdsSentMeRequest in the Session
     - Returns: Whether it's a request push message or not.
     **/
    func isRequest() -> Bool {
        pushType == PushType.REQUEST && requestId.isNotEmpty()
    }

    func isFavorite() -> Bool {
        pushType == PushType.FAVORITE && postId.isNotEmpty()
    }

    func isComment() -> Bool {
        pushType == PushType.COMMENT && postId.isNotEmpty()
    }

    func isThumbUp() -> Bool {
        pushType == PushType.THUMB_UP && postId.isNotEmpty()
    }

    /**
     Push when someone rates me score 4 or 5.
     1. appends an user in the RatedModel
     - Returns: Whether it's high rating push message or not.
     **/
    func isStarRating() -> Bool {
        pushType == PushType.STAR_RATING && userId.isNotEmpty()
    }

    /**
     Push when someone accepts my request.
     1. removes an existing request in the RatedModel.
     ----------------------------------------------------
     2. appends an conversation in the ConversationModel.
     ----------------------------------------------------
     3. removes userId from userIdsISentRequest && userIdsSentMeRequest in the Session
     4. adds to userIdsMatched in the Session
     ---------------------------------------------------------------------------------
     - Returns: Whether it's matched push message or not.
     **/
    func isMatched() -> Bool {
        pushType == PushType.MATCHED && conversationId.isNotEmpty()
    }

    /**
     Push when someone opened a conversation room.
     1. appends an conversation in the ConversationModel.
     - Returns: Whether it's matched push message or not.
     **/
    func isOpened() -> Bool {
        pushType == PushType.OPENED && conversationId.isNotEmpty()
    }

    func isMessage() -> Bool {
        pushType == PushType.CONVERSATION && conversationId.isNotEmpty() && messageId.isNotEmpty()
    }

    func isLogout() -> Bool {
        pushType == PushType.LOG_OUT
    }
}
