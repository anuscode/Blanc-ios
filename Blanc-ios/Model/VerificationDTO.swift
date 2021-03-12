import Foundation


class VerificationDTO: Codable {

    enum Status: String, Codable {
        case SUCCEED_ISSUE = "SUCCEED_ISSUE",
             FAILED_ISSUE = "FAILED_ISSUE",
             INVALID_PHONE_NUMBER = "INVALID_PHONE_NUMBER",
             INVALID_SMS_CODE = "INVALID_SMS_CODE",
             EXPIRED_SMS_CODE = "EXPIRED_SMS_CODE",
             VERIFIED_SMS_CODE = "VERIFIED_SMS_CODE"
    }

    var status: Status?
    var phone: String?
    var expiredAt: Int?
    var smsCode: String?
    var smsToken: String?
}
