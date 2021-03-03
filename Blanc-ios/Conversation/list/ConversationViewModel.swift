import Foundation
import RxSwift

class ConversationViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[ConversationDTO]>.create(bufferSize: 1)

    private let conversationModel: ConversationModel

    private var conversations: [ConversationDTO] = []

    init(conversationModel: ConversationModel) {
        self.conversationModel = conversationModel
        subscribeConversationModel()
    }

    private func publish() {
        observable.onNext(conversations)
    }

    func observe() -> Observable<[ConversationDTO]> {
        observable
    }

    private func subscribeConversationModel() {
        conversationModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] conversations in
                    self.conversations = conversations
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func leaveConversation(conversationId: String?) {
        conversationModel.leaveConversation(conversationId: conversationId)
    }

    func channel(user: UserDTO?) {
        conversationModel.channel(user: user)
    }

    func channel(conversation: ConversationDTO?) {
        conversationModel.channel(conversation: conversation)
    }
}
