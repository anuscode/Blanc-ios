import Foundation

class RaterDTO: NSObject, Codable {
    var score: Float?
    var user: UserDTO?
    var ratedAt: Int?
}
