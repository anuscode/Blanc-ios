import Foundation

enum RequestType: Int, Codable {
    case FRIEND = 10
}

enum Response: Int, Codable {
    case DECLINED = 0, ACCEPTED = 1
}

class RequestDTO: NSObject, Codable {
    var _id: String?
    var id: String? {
        get {
            _id
        }
        set {
            _id = newValue
        }
    }
    var requestedAt: Int?
    var requestType: RequestType?
    var response: Response?
    var respondedAt: Int?
    var userFrom: UserDTO?
    var userTo: UserDTO?

    static func ==(lhs: RequestDTO, rhs: RequestDTO) -> Bool {
        lhs.id == rhs.id
    }
}
