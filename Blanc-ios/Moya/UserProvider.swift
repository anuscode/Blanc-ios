import Foundation
import Moya

enum UserProvider {

    // GET
    case getSession(idToken: String?, uid: String?)
    case getUser(userId: String?)
    case isRegistered(uid: String?)

    case listRecommendedUsers(uid: String?, userId: String?)
    case listCloseUsers(uid: String?, userId: String?)
    case listRealTimeAccessUsers(uid: String?, userId: String?)
    case listAllUserPosts(uid: String?, userId: String?)
    case listUsersRatedMeHigh(uid: String?, userId: String?)
    case listUsersIRatedHigh(uid: String?, userId: String?)
    case listUsersRatedMe(uid: String?, userId: String?)

    // POST
    case createUser(idToken: String?, uid: String?, phone: String?, smsCode: String?, smsToken: String?)
    case signInWithKakaoToken(idToken: String?)
    case pushPoke(uid: String?, userId: String?)
    case pushLookUp(uid: String?, userId: String?)
    case uploadUserImage(uid: String?, userId: String?, index: Int?, file: UIImage)
    // case uploadUserImage()

    // PUT
    case updateDeviceToken(uid: String?, deviceToken: String?)
    case updateUserStatusPending(uid: String?, userId: String?)
    case updateUserLocation(uid: String?, userId: String?, latitude: Double?, longitude: Double?, area: String?)
    case updateUserStarRatingScore(uid: String?, userId: String?, score: Int)
    case updateUserProfile(idToken: String?, uid: String?, userId: String?, userDTO: UserDTO)
    case updateUserLastLoginAt(uid: String?, userId: String?)
    case updateUserContacts(idToken: String?, uid: String?, userId: String?, phones: [String])

    // DELETE
    case deleteUserImage(uid: String?, userId: String?, index: Int)
}

extension UserProvider: TargetType {

    var baseURL: URL {
        URL(string: Constant.url)!
    }

    var path: String {
        switch self {

        case .getSession(idToken: _, uid: _):
            return "users/session"
        case .getUser(userId: let userId):
            return "users/\(userId ?? "")"
        case .isRegistered(uid: let uid):
            return "users/uid/\(uid ?? "")"
        case .listRecommendedUsers(uid: _, userId: let userId):
            return "users/\(userId ?? "")/recommendation"
        case .listCloseUsers(uid: _, userId: let userId):
            return "users/\(userId ?? "")/distance/5"
        case .listRealTimeAccessUsers(uid: _, userId: let userId):
            return "users/\(userId ?? "")/real_time"
        case .listAllUserPosts(uid: _, userId: let userId):
            return "users/\(userId ?? "")/posts"
        case .listUsersRatedMeHigh(uid: _, userId: let userId):
            return "users/\(userId ?? "")/rated_me_high"
        case .listUsersIRatedHigh(uid: _, userId: let userId):
            return "users/\(userId ?? "")/i_rated_high"
        case .listUsersRatedMe(uid: _, userId: let userId):  // TODO: fix later
            return "users/\(userId ?? "")/score"
        case .createUser(idToken: _, uid: _, phone: _, smsCode: _, smsToken: _):
            return "users"
        case .signInWithKakaoToken(idToken: _):
            return "users/kakao"
        case .pushPoke(uid: _, userId: let userId):
            return "users/\(userId ?? "")/push/poke"
        case .pushLookUp(uid: _, userId: let userId):
            return "users/\(userId ?? "")/push/lookup"
        case .uploadUserImage(uid: _, userId: let userId, index: let index, file:_):
            return "users/\(userId ?? "")/user_images/\(index!)"
        case .updateDeviceToken(uid: _, deviceToken: let deviceToken):
            return "users/device_token/\(deviceToken ?? "")"
        case .updateUserStatusPending(uid: _, userId: let userId):
            return "users/\(userId ?? "")/status/pending"
        case .updateUserLocation(uid: _, userId: let userId, latitude: _, longitude: _, area: _):
            return "users/\(userId ?? "")/location"
        case .updateUserStarRatingScore(uid: _, userId: let userId, score: let score):
            return "users/\(userId ?? "")/score/\(score)"
        case .updateUserProfile(idToken: _, uid: _, userId: let userId, userDTO: _):
            return "users/\(userId ?? "")/profile"
        case .updateUserLastLoginAt(uid: _, userId: let userId):
            return "users/\(userId ?? "")/last_login_at"
        case .updateUserContacts(idToken: _, uid: _, userId: let userId, phones: _):
            return "users/\(userId ?? "")/contacts"
        case .deleteUserImage(uid: _, userId: let userId, index: let index):
            return "users/\(userId ?? "")/user_images/\(index)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getSession(idToken: _, uid: _),
             .getUser(userId: _),
             .isRegistered(uid: _),
             .listRecommendedUsers(uid: _, userId: _),
             .listCloseUsers(uid: _, userId: _),
             .listRealTimeAccessUsers(uid: _, userId: _),
             .listAllUserPosts(uid: _, userId: _),
             .listUsersRatedMeHigh(uid: _, userId: _),
             .listUsersIRatedHigh(uid: _, userId: _),
             .listUsersRatedMe(uid: _, userId: _):
            return .get
        case .createUser(idToken: _, uid: _, phone: _, smsCode: _, smsToken: _),
             .signInWithKakaoToken(idToken: _),
             .pushPoke(uid: _, userId: _),
             .pushLookUp(uid: _, userId: _),
             .uploadUserImage(uid: _, userId: _, index: _, file: _):
            return .post
        case .updateUserStatusPending(uid: _, userId: _),
             .updateUserLocation(uid: _, userId: _, latitude: _, longitude: _, area: _),
             .updateUserStarRatingScore(uid: _, userId: _, score: _),
             .updateUserProfile(idToken: _, uid: _, userId: _, userDTO: _),
             .updateUserLastLoginAt(uid: _, userId: _),
             .updateUserContacts(idToken: _, uid: _, userId: _, phones: _),
             .updateDeviceToken(uid: _, deviceToken: _):
            return .put
        case .deleteUserImage(uid: _, userId: _, index: _):
            return .delete
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case .getSession(idToken: _, uid: _):
            return .requestPlain
        case .getUser(userId: _):
            return .requestPlain
        case .isRegistered(uid: _):
            return .requestPlain
        case .listRecommendedUsers(uid: _, userId: _):
            return .requestPlain
        case .listCloseUsers(uid: _, userId: _):
            return .requestPlain
        case .listRealTimeAccessUsers(uid: _, userId: _):
            return .requestPlain
        case .listAllUserPosts(uid: _, userId: _):
            return .requestPlain
        case .listUsersRatedMeHigh(uid: _, userId: _):
            return .requestPlain
        case .listUsersIRatedHigh(uid: _, userId: _):
            return .requestPlain
        case .listUsersRatedMe(uid: _, userId: _):
            return .requestPlain

            /** POST **/
        case .createUser(idToken: _, uid: _, phone: let phone, smsCode: let smsCode, smsToken: let smsToken):
            return .requestCompositeParameters(
                    bodyParameters: ["phone": phone!, "sms_code": smsCode!, "sms_token": smsToken!],
                    bodyEncoding: URLEncoding.httpBody,
                    urlParameters: [:])
        case .signInWithKakaoToken(idToken: _):
            return .requestPlain
        case .pushPoke(uid: _, userId: _):
            return .requestPlain
        case .pushLookUp(uid: _, userId: _):
            return .requestPlain
        case .uploadUserImage(uid: _, userId: _, index: _, file: let file):
            let imageData = file.jpegData(compressionQuality: 1.0)
            let formData = [
                Moya.MultipartFormData(provider: .data(imageData!), name: "user_image", fileName: "image.jpeg", mimeType: "image/jpeg")
            ]
            return .uploadMultipart(formData)

            /** PUT **/
        case .updateDeviceToken(uid: _, deviceToken: _):
            return .requestPlain
        case .updateUserStatusPending(uid: _, userId: _):
            return .requestPlain
        case .updateUserLocation(uid: _, userId: _, latitude: let latitude, longitude: let longitude, area: let area):
            return .requestParameters(
                    parameters: ["latitude": latitude ?? 0, "longitude": longitude ?? 0, "area": area ?? "알 수 없음"],
                    encoding: URLEncoding.queryString
            )
        case .updateUserStarRatingScore(uid: _, userId: _, score: _):
            return .requestPlain
        case .updateUserProfile(idToken: _, uid: _, userId: _, userDTO: let userDTO):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return .requestCustomJSONEncodable(userDTO, encoder: encoder)
        case .updateUserLastLoginAt(uid: _, userId: _):
            return .requestPlain
        case .updateUserContacts(idToken: _, uid: _, userId: _, phones: let phones):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            return .requestCustomJSONEncodable(phones, encoder: encoder)
            /** DELETE **/
        case .deleteUserImage(uid: _, userId: _, index: _):
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]
        switch self {
        case .getSession(idToken: let idToken, uid: let uid):
            headers["id-token"] = idToken
            headers["uid"] = uid
            return headers
        case .getUser(userId: _):
            return headers
        case .isRegistered(uid: let uid):
            headers["uid"] = uid
            return headers
        case .listRecommendedUsers(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .listCloseUsers(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .listRealTimeAccessUsers(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .listAllUserPosts(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .listUsersRatedMeHigh(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .listUsersIRatedHigh(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .listUsersRatedMe(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers

        case .createUser(idToken: let idToken, uid: let uid, phone: _, smsCode: _, smsToken: _):
            var _headers = ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"]
            _headers["id-token"] = idToken
            _headers["uid"] = uid
            return _headers

        case .signInWithKakaoToken(idToken: let idToken):
            headers["id-token"] = idToken
            return headers
        case .pushPoke(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .pushLookUp(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers

        case .uploadUserImage(uid: let uid, userId: _, index: _, file: _):
            headers["uid"] = uid
            return headers

        case .updateDeviceToken(uid: let uid, deviceToken: _):
            headers["uid"] = uid
            return headers
        case .updateUserStatusPending(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .updateUserLocation(uid: let uid, userId: _, latitude: _, longitude: _, area: _):
            headers["uid"] = uid
            return headers
        case .updateUserStarRatingScore(uid: let uid, userId: _, score: _):
            headers["uid"] = uid
            return headers
        case .updateUserProfile(idToken: let idToken, uid: let uid, userId: _, userDTO: _):
            headers["id-token"] = idToken
            headers["uid"] = uid
            return headers
        case .updateUserLastLoginAt(uid: let uid, userId: _):
            headers["uid"] = uid
            return headers
        case .updateUserContacts(idToken: let idToken, uid: let uid, userId: _, phones: _):
            headers["id-token"] = idToken
            headers["uid"] = uid
            return headers
        case .deleteUserImage(uid: let uid, userId: _, index: _):
            headers["uid"] = uid
            return headers
        }
    }
}
