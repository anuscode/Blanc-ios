import Foundation

class Postable: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func ==(lhs: Postable, rhs: Postable) -> Bool {
        lhs === rhs
    }
}
