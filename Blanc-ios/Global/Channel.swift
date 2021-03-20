import Foundation
import RxSwift

class Channel {

    internal let user: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    internal let post: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    internal let conversation: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    internal let reportee: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    func next(value: UserDTO) {
        user.onNext(value)
    }

    func next(value: PostDTO) {
        post.onNext(value)
    }

    func next(value: ConversationDTO) {
        conversation.onNext(value)
    }
}
