import Foundation
import RxRealm
import RxSwift
import RealmSwift

class ConversationModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<[ConversationDTO]>.create(bufferSize: 1)

    private var session: Session

    private var channel: Channel

    private var conversationService: ConversationService

    private var conversations: [ConversationDTO] = []

    private let realm = try! Realm()

    init(session: Session, channel: Channel, conversationService: ConversationService) {
        self.session = session
        self.channel = channel
        self.conversationService = conversationService
        populate()
        subscribeBroadcast()
        subscribeBackground()
    }

    deinit {
        log.info("deinit ConversationModel..")
    }

    func observe() -> Observable<[ConversationDTO]> {
        observable.map { [unowned self] conversations in
            conversations.map { [unowned self] conversation -> ConversationDTO in
                conversation.currentUser = session.user
                return conversation
            }
        }
    }

    private func publish() {
        DispatchQueue.main.async { [unowned self] in
            selectLastReadMessages()
                    .do(onNext: { dictionary in
                        conversations.forEach { conversation in
                            let conversationId = conversation.id ?? ""
                            let count = (conversation.messages?.count ?? 0)
                            if let messageId = dictionary[conversationId] {
                                let index = conversation.messages?.firstIndex {
                                    $0.id == messageId
                                } ?? -1
                                conversation.unreadMessageCount = count - (index + 1)
                            } else {
                                conversation.unreadMessageCount = count
                            }
                        }
                    })
                    .subscribe(onSuccess: { _ in
                        observable.onNext(conversations)
                    })
                    .disposed(by: disposeBag)
        }
    }

    func populate() {
        conversationService.listUserConversations(uid: session.uid)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] conversations in
                    // ordered by desc
                    self.conversations = conversations.sorted(by: {
                        $0.createdAt ?? 0 > $1.createdAt ?? 0
                    })
                    publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func subscribeBroadcast() {
        Broadcast.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] push in
                    if (push.isMatched()) {
                        // insert a new conversation
                        insertConversation(conversationId: push.conversationId)
                    }

                    if (push.isOpened()) {
                        // update a conversation.available to true
                        openConversation(conversationId: push.conversationId)
                    }

                    if (push.isMessage()) {
                        appendMessage(push: push)
                    }

                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func subscribeBackground() {
        Background.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { push in
                    self.populate()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    /**
     Returns last read messages as dict
     An example returning structure is like below
     {
       "conversationId1": "messageId1",
       "conversationId2": "messageId2"
     }
     - Returns: conversation and message id as Dict[String: String]
     **/
    private func selectLastReadMessages() -> Single<[String: String]> {
        let messages = realm.objects(MessageEntity.self)
        return Observable.array(from: messages)
                .take(1)
                .map { collection -> [String: String] in
                    let result = collection.reduce(into: [String: String]()) { dict, message in
                        let conversationId = message.conversationId
                        let messageId = message.messageId
                        dict.updateValue(messageId, forKey: conversationId)
                    }
                    return result
                }
                .asSingle()
    }

    private func insertConversation(conversationId: String?) {
        conversationService.getConversation(uid: session.uid, conversationId: conversationId)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { conversation in
                    self.conversations.insert(conversation, at: 0)
                    self.publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func appendMessage(push: PushDTO) {
        let message = MessageDTO.from(push: push)

        guard (message.id.isNotEmpty()) else {
            return
        }

        guard (message.conversationId.isNotEmpty()) else {
            return
        }

        let conversation = conversations.first(where: { $0.id == message.conversationId })
        conversation?.messages?.append(message)
        publish()
    }

    private func openConversation(conversationId: String?) {
        if let conversation = conversations.first(where: { $0.id == conversationId }) {
            conversation.available = true
            publish()
        } else {
            populate()
        }
    }

    func leaveConversation(conversationId: String?) {
        conversationService.leaveConversation(uid: session.uid, conversationId: conversationId, userId: session.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: {
                    if let index = self.conversations.firstIndex(where: { $0.id == conversationId }) {
                        self.conversations.remove(at: index)
                    }
                    self.publish()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    func channel(user: UserDTO?) {
        guard(user != nil) else {
            return
        }
        channel.next(value: user!)
    }

    func channel(conversation: ConversationDTO?) {
        guard(conversation != nil) else {
            return
        }
        channel.next(value: conversation!)
    }

    func sync(conversation: ConversationDTO) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = conversation
        }
        publish()
    }
}
