import Foundation
import Moya


enum RequestProvider {

    // GET
    case listRequests(uid: String?)
    case getRequest(uid: String?, requestId: String?)
    // POST
    case createLikeRequest(idToken: String?, uid: String?, userId: String?, requestType: RequestType)
    // PUT
    case updateLikeRequest(uid: String?, requestId: String?, response: Response)

}


extension RequestProvider: TargetType {

    var baseURL: URL {
        URL(string: Constant.url)!
    }

    var path: String {
        switch self {
        case .listRequests(uid: _):
            return "requests"
        case .getRequest(uid: _, requestId: let requestId):
            return "requests/\(requestId ?? "")"
        case .createLikeRequest(idToken: _, uid: _, userId: let userId, requestType: let type):
            return "requests/user_to/\(userId ?? "")/type/\(type.rawValue)"
        case .updateLikeRequest(uid: _, requestId: let requestId, response: let response):
            return "requests/\(requestId ?? "")/response/\(response.rawValue)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .listRequests(uid: _):
            return .get
        case .getRequest(uid: _, requestId: _):
            return .get
        case .createLikeRequest(idToken: _, uid: _, userId: _, requestType: _):
            return .post
        case .updateLikeRequest(uid: _, requestId: _, response: _):
            return .put
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case .listRequests(uid: _):
            return .requestPlain
        case .getRequest(uid: _, requestId: _):
            return .requestPlain
        case .createLikeRequest(idToken: _, uid: _, userId: _, requestType: _):
            return .requestPlain
        case .updateLikeRequest(uid: _, requestId: _, response: _):
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        switch self {
        case .listRequests(uid: let uid):
            headers["uid"] = uid
            return headers
        case .getRequest(uid: let uid, requestId: _):
            headers["uid"] = uid
            return headers
        case .createLikeRequest(idToken: let idToken, uid: let uid, userId: _, requestType: _):
            headers["id-token"] = idToken
            headers["uid"] = uid
            return headers
        case .updateLikeRequest(uid: let uid, requestId: _, response: _):
            headers["uid"] = uid
            return headers
        }
    }
}
