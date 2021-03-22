import Foundation

class Diffable: Hashable {
    func hash(into hasher: inout Hasher) {
        print("hash")
        hasher.combine(ObjectIdentifier(self))
    }

    static func ==(lhs: Diffable, rhs: Diffable) -> Bool {
        return lhs === rhs
    }
}
