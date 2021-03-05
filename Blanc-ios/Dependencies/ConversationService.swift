import Foundation
import Moya
import RxSwift
import Firebase
import RxFirebase


class ConversationService {

    let provider = MoyaProvider<ConversationProvider>(plugins: [
        //NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))
    ])

    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    // GET
    func getConversation(uid: String?, conversationId: String?) -> Single<ConversationDTO> {
        provider.rx
            .request(.getConversation(uid: uid, conversationId: conversationId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map(ConversationDTO.self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    func listUserConversations(uid: String?) -> Single<[ConversationDTO]> {
        provider.rx
            .request(.listUserConversations(uid: uid))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map([ConversationDTO].self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    // POST
    func sendMessage(uid: String?, conversationId: String?, message: String?) -> Single<MessageDTO> {
        provider.rx
            .request(.sendMessage(uid: uid, conversationId: conversationId, message: message))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .map(MessageDTO.self, using: decoder)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
    }

    // PUT
    func updateConversationAvailable(currentUser: User,
                                     uid: String?,
                                     conversationId: String?) -> Single<Void> {
        currentUser.rx
            .getIDTokenResult()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap { [unowned self] result in
                provider.rx.request(.updateConversationAvailable(
                        idToken: result.token,
                        uid: uid,
                        conversationId: conversationId,
                        available: true))
                    .debug()
                    .filterSuccessfulStatusAndRedirectCodes()
                    .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                    .map({ _ in Void() })
            }
            .asSingle()
    }

    // DELETE
    func leaveConversation(uid: String?, conversationId: String?, userId: String?) -> Single<Void> {
        provider.rx
            .request(.leaveConversation(uid: uid, conversationId: conversationId, userId: userId))
            .debug()
            .filterSuccessfulStatusAndRedirectCodes()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .map({ _ in Void() })
    }
}
