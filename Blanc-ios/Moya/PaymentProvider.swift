import Moya

enum PaymentProvider {
    case purchase(idToken: String, uid: String, userId: String, token: String)
}


extension PaymentProvider: TargetType {

    var baseURL: URL {
        URL(string: Constant.url)!
    }

    var path: String {
        switch self {
        case .purchase(idToken: _, uid: _, userId: let userId, token: _):
            return "/payments/users/\(userId)/platform/ios"
        }
    }

    var method: Moya.Method {
        switch self {
        case .purchase(idToken: _, uid: _, userId: _, token: _):
            return .post
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case .purchase(idToken: _, uid: _, userId: _, token: let token):
            return .requestCompositeParameters(
                    bodyParameters: ["token": token],
                    bodyEncoding: URLEncoding.httpBody,
                    urlParameters: [:])
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"]
        switch self {
        case .purchase(idToken: let idToken, uid: let uid, userId: _, token: _):
            headers["id-token"] = idToken
            headers["uid"] = uid
            return headers
        }
    }
}
