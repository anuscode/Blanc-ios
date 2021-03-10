import Foundation
import RxSwift
import RealmSwift

class ConversationSingleViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    private weak var conversation: ConversationDTO?

    private let conversationSingleModel: ConversationSingleModel

    private let conversationModel: ConversationModel

    init(conversationSingleModel: ConversationSingleModel, conversationModel: ConversationModel) {
        self.conversationSingleModel = conversationSingleModel
        self.conversationModel = conversationModel
        subscribeConversationModel()
    }

    deinit {
        log.info("deinit ConversationSingleViewModel..")
    }

    private func publish() {
        if (conversation != nil) {
            observable.onNext(conversation!)
        }
    }

    func observe() -> Observable<ConversationDTO> {
        observable
    }

    private func subscribeConversationModel() {
        conversationSingleModel
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] conversation in
                self.conversation = conversation
                publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    func updateConversationAvailable(
        conversation: ConversationDTO?, onCompleted: @escaping () -> Void, onError: @escaping () -> Void) {
        conversationSingleModel.updateConversationAvailable(
            conversation: conversation, onCompleted: onCompleted, onError: onError)
    }

    func sendMessage(message: String, onError: @escaping () -> Void) {
        conversationSingleModel.sendMessage(message: message, onError: onError)
    }

    func channel(user: UserDTO?) {
        conversationSingleModel.channel(user: user)
    }

    func getSession() -> Session {
        conversationSingleModel.getSession()
    }

    func sync() {
        conversationSingleModel.setReadAll()
        if let conversation = conversation {
            conversationModel.sync(conversation: conversation)
        }
    }
}