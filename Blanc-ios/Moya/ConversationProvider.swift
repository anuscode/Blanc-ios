import Moya

enum ConversationProvider {
    // GET
    case getConversation(uid: String?, conversationId: String?)
    case listUserConversations(uid: String?)
    // POST
    case sendMessage(uid: String?, conversationId: String?, message: String?)
    // PUT
    case updateConversationAvailable(idToken: String?, uid: String?, conversationId: String?, available: Bool)
    // DELETE
    case leaveConversation(uid: String?, conversationId: String?, userId: String?)
}


extension ConversationProvider: TargetType {
    var baseURL: URL {
        URL(string: Constant.url)!
    }

    var path: String {
        switch self {
        case .getConversation(uid: _, conversationId: let conversationId):
            return "conversations/\(conversationId ?? "")"
        case .listUserConversations(uid: _):
            return "conversations"
        case .sendMessage(uid: _, conversationId: let conversationId, message: let message):
            return "conversations/\(conversationId ?? "")/messages/\(message ?? "")"
        case .updateConversationAvailable(idToken: _, uid: _, conversationId: let conversationId, available: let available):
            return "conversations/\(conversationId ?? "")/available/\(available)"
        case .leaveConversation(uid: _, conversationId: let conversationId, userId: let userId):
            return "conversations/\(conversationId ?? "")/user_id/\(userId ?? "")"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getConversation(uid: _, conversationId: _):
            return .get
        case .listUserConversations(uid: _):
            return .get
        case .sendMessage(uid: _, conversationId: _, message: _):
            return .post
        case .updateConversationAvailable(idToken: _, uid: _, conversationId: _, available: _):
            return .put
        case .leaveConversation(uid: _, conversationId: _, userId: _):
            return .delete
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case .getConversation(uid: _, conversationId: _):
            return .requestPlain
        case .listUserConversations(uid: _):
            return .requestPlain
        case .sendMessage(uid: _, conversationId: _, message: _):
            return .requestPlain
        case .updateConversationAvailable(idToken: _, uid: _, conversationId: _, available: _):
            return .requestPlain
        case .leaveConversation(uid: _, conversationId: _, userId: _):
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-type": "application/json"]
        switch self {
        case .getConversation(uid: let uid, conversationId: _):
            headers["uid"] = uid
            return headers
        case .listUserConversations(uid: let uid):
            headers["uid"] = uid
            return headers
        case .sendMessage(uid: let uid, conversationId: _, message: _):
            headers["uid"] = uid
            return headers
        case .updateConversationAvailable(idToken: let idToken, uid: let uid, conversationId: _, available: _):
            headers["id-token"] = idToken
            headers["uid"] = uid
            return headers
        case .leaveConversation(uid: let uid, conversationId: _, userId: _):
            headers["uid"] = uid
            return headers
        }
    }
}