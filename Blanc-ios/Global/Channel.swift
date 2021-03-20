import Foundation
import RxSwift

class Channel {

    internal static let user: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    internal static let post: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    internal static let conversation: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    internal static let reportee: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    internal static func next(value: UserDTO) {
        Channel.user.onNext(value)
    }

    internal static func next(value: PostDTO) {
        Channel.post.onNext(value)
    }

    internal static func next(value: ConversationDTO) {
        Channel.conversation.onNext(value)
    }
}
