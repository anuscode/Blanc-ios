import Foundation

class PushSetting: NSObject, Codable {

    var all: Bool {
        get {
            let flags: Set<Bool?> = [
                poke,
                request,
                comment,
                highRate,
                match,
                favoriteComment,
                conversation,
                lookup
            ]
            return flags.count == 1 && flags.contains(true)
        }
        set(newValue) {
            poke = newValue
            request = newValue
            comment = newValue
            highRate = newValue
            match = newValue
            favoriteComment = newValue
            conversation = newValue
            lookup = newValue
        }
    }

    var poke: Bool?
    var request: Bool?
    var comment: Bool?
    var highRate: Bool?
    var match: Bool?
    var favoriteComment: Bool?
    var conversation: Bool?
    var lookup: Bool?
}


class SettingDTO: NSObject, Codable {

    var push: PushSetting?

    static func ==(lhs: SettingDTO, rhs: SettingDTO) -> Bool {
        lhs === rhs
    }
}
