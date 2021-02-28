//
// Created by Yongwoo Lee on 2020/12/13.
//

import Foundation
import Moya

enum VerificationProvider {
    case issueSmsCode(idToken: String?, uid: String?, phone: String?)
    case verifySmsCode(idToken: String?, uid: String?, phone: String?, smsCode: String?, expiredAt: Int?)
}

extension VerificationProvider: TargetType {

    var baseURL: URL {
        URL(string: Constant.url)!
    }

    var path: String {
        switch self {
        case .issueSmsCode(idToken: _, uid: _, phone: _):
            return "verifications/sms"
        case .verifySmsCode(idToken: _, uid: _, phone: _, smsCode: _, expiredAt: _):
            return "verifications/sms"
        }
    }

    var method: Moya.Method {
        switch self {
        case .issueSmsCode(idToken: _, uid: _, phone: _):
            return .post
        case .verifySmsCode(idToken: _, uid: _, phone: _, smsCode: _, expiredAt: _):
            return .put
        }
    }

    var sampleData: Data {
        Data()
    }

    var task: Task {
        switch self {
        case .issueSmsCode(idToken: _, uid: _, phone: let phone):
            return .requestCompositeParameters(
                    bodyParameters: [
                        "phone": phone!
                    ],
                    bodyEncoding: URLEncoding.httpBody,
                    urlParameters: [:])
        case .verifySmsCode(idToken: _, uid: _, phone: let phone, smsCode: let smsCode, expiredAt: let expiredAt):
            return .requestCompositeParameters(
                    bodyParameters: [
                        "phone": phone!,
                        "sms_code": smsCode!,
                        "expired_at": expiredAt!
                    ],
                    bodyEncoding: URLEncoding.httpBody,
                    urlParameters: [:])
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/x-www-form-urlencoded; charset=utf-8"]
        switch self {
        case .issueSmsCode(idToken: let idToken, uid: let uid, phone: _):
            headers["id-token"] = idToken
            headers["uid"] = uid
            return headers
        case .verifySmsCode(idToken: let idToken, uid: let uid, phone: _, smsCode: _, expiredAt: _):
            headers["id-token"] = idToken
            headers["uid"] = uid
            return headers
        }
    }
}
