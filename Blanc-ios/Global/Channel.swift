import Foundation
import RxSwift

class Channel {

    internal static let user: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    internal static let post: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    internal static let conversation: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    internal static let reportee: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    internal static let reportedPost: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    internal static func next(user: UserDTO) {
        Channel.user.onNext(user)
    }

    internal static func next(post: PostDTO) {
        Channel.post.onNext(post)
    }

    internal static func next(conversation: ConversationDTO) {
        Channel.conversation.onNext(conversation)
    }

    internal static func next(report: UserDTO) {
        Channel.reportee.onNext(report)
    }

    internal static func next(report: PostDTO) {
        Channel.reportedPost.onNext(report)
    }
}
