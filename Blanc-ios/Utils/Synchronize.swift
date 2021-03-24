import Foundation
import RxSwift

class Synchronize {

    internal static let user: PublishSubject = PublishSubject<UserDTO>()

    internal static let post: PublishSubject = PublishSubject<PostDTO>()

    internal static let conversation: PublishSubject = PublishSubject<ConversationDTO>()

    internal static func next(user: UserDTO) {
        Synchronize.user.onNext(user)
    }

    internal static func next(post: PostDTO) {
        Synchronize.post.onNext(post)
    }

    internal static func next(conversation: ConversationDTO) {
        Synchronize.conversation.onNext(conversation)
    }
}
