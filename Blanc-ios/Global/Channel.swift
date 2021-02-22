import Foundation
import RxSwift

class Channel {

    private let user: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    private let post: ReplaySubject = ReplaySubject<PostDTO>.create(bufferSize: 1)

    private let conversation: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    func observe(_: UserDTO.Type) -> Observable<UserDTO> {
        user.take(1)
    }

    func observe(_: PostDTO.Type) -> Observable<PostDTO> {
        post.take(1)
    }

    func observe(_: ConversationDTO.Type) -> Observable<ConversationDTO> {
        conversation.take(1)
    }

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
