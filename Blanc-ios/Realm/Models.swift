import Foundation
import RealmSwift

class PokeHistory: Object {
    @objc dynamic var uid = ""
    @objc dynamic var userId = ""
    @objc dynamic var availableAt = 0
    @objc dynamic var primaryKey = ""

    override static func primaryKey() -> String? {
        "primaryKey"
    }

    func setup(uid: String, userId: String, availableAt: Int) {
        self.uid = uid
        self.userId = userId
        self.availableAt = availableAt
        self.primaryKey = "\(uid)\(userId)"
    }
}


