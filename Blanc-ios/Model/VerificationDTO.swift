//
// Created by Yongwoo Lee on 2020/12/13.
//

import Foundation

class VerificationDTO: Codable {
    var phone: String?
    var issued: Bool?
    var expiredAt: Int?
    var verified: Bool?
    var smsCode: String?
    var smsToken: String?
    var reason: String?
}
