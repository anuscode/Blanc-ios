import Foundation

enum PaymentResult: String, Codable {
    case DUPLICATE = "DUPLICATE",
         INVALID = "INVALID",
         PURCHASED = "PURCHASED"
}

class PaymentDTO: NSObject, Decodable {
    var result: PaymentResult?
}