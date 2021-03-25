import Foundation
import RxSwift

class Synchronize {

    internal static let user: PublishSubject = PublishSubject<UserDTO>()

    internal static let post: PublishSubject = PublishSubject<PostDTO>()

    internal static let conversation: PublishSubject = PublishSubject<ConversationDTO>()

    internal static func next(user: UserDTO) {
        do {
            let encoded = try JSONEncoder().encode(user)
            let decoded = try JSONDecoder().decode(UserDTO.self, from: encoded)
            Synchronize.user.onNext(decoded)
        } catch {
            log.error(error)
        }
    }

    internal static func next(post: PostDTO) {
        do {
            let encoded = try JSONEncoder().encode(post)
            let decoded = try JSONDecoder().decode(PostDTO.self, from: encoded)
            Synchronize.post.onNext(decoded)
        } catch {
            log.error(error)
        }
    }

    internal static func next(conversation: ConversationDTO) {
        do {
            let encoded = try JSONEncoder().encode(conversation)
            let decoded = try JSONDecoder().decode(ConversationDTO.self, from: encoded)
            Synchronize.conversation.onNext(decoded)
        } catch {
            log.error(error)
        }
    }
}
