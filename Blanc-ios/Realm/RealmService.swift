import Foundation
import RealmSwift

class RealmService {

    private static let realm = try! Realm()

    static func isPokeAvailable(uid: String?, userId: String?) -> Bool {
        if (uid == nil || userId == nil) {
            return false
        }
        let pokeHistory = getPokeHistory(uid: uid, userId: userId)
        if (pokeHistory == nil) {
            return true
        }
        return pokeHistory!.availableAt <= Int(NSDate().timeIntervalSince1970)
    }

    static func getPokeHistory(uid: String?, userId: String?) -> PokeHistory? {
        if (uid == nil || userId == nil) {
            return nil
        }
        let pokeHistory: PokeHistory? = realm.objects(PokeHistory.self).filter(
                "uid = %@ AND userId = %@", uid, userId).first
        return pokeHistory
    }

    static func setPokeHistory(uid: String?, userId: String?, availableAt: Int? = nil) {
        DispatchQueue.main.async {
            if (uid == nil || userId == nil) {
                return
            }
            let pokeHistory = getPokeHistory(uid: uid, userId: userId)
            let availableAt: Int! = availableAt != nil ? availableAt : (Int(NSDate().timeIntervalSince1970) + 60 * 10)
            // insert
            if (pokeHistory == nil) {
                let create = PokeHistory()
                create.setup(uid: uid!, userId: userId!, availableAt: availableAt)
                try! realm.write {
                    realm.add(create)
                }
                return
            }
            // update
            try! realm.write {
                pokeHistory!.availableAt = availableAt
            }
        }
    }
}
