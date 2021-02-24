import Foundation
import RxSwift
import FirebaseAuth
import RealmSwift

class ConversationSingleModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    private var conversation: ConversationDTO?

    private var session: Session

    private let channel: Channel

    private let conversationService: ConversationService

    private let auth: Auth = Auth.auth()

    private let realm = try! Realm()

    init(session: Session, channel: Channel, conversationService: ConversationService) {
        self.session = session
        self.channel = channel
        self.conversationService = conversationService
        populate()
        subscribeBroadcast()
    }

    deinit {
        log.info("deinit ConversationSingleModel..")
    }

    func observe() -> Observable<ConversationDTO> {
        observable
    }

    private func publish() {
        if (conversation != nil) {
            observable.onNext(conversation!)
        }
    }

    private func populate() {
        channel.observe(ConversationDTO.self)
                .take(1)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [unowned self] conversation in
                    getConversation(conversationId: conversation.id)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func getConversation(conversationId: String?) {
        conversationService.getConversation(uid: session.uid, conversationId: conversationId)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .do(onSuccess: { conversation in
                    let partner = conversation.partner
                    partner?.distance = partner?.distance(from: self.session.user, type: String.self)
                })
                .map { [unowned self] conversation -> ConversationDTO in
                    conversation.messages = conversation.messages?.map { [self] message -> MessageDTO in
                        message.isCurrentUserMessage = (message.userId == session.id && message.userId != nil)
                        return message
                    }
                    return conversation
                }
                .subscribe(onSuccess: { [unowned self] conversation in
                    self.conversation = conversation
                    self.conversation?.currentUser = session.user
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
                    if (push.isMessage()) {
                        appendMessage(push: push)
                    }
                    setReadAll()
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

        conversation?.messages?.append(message)
        publish()
    }

    func updateConversationAvailable(
            conversation: ConversationDTO?, onCompleted: @escaping () -> Void, onError: @escaping () -> Void) {
        conversationService.updateConversationAvailable(
                        currentUser: auth.currentUser!, uid: session.uid, conversationId: conversation?.id)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap({ _ in self.session.refresh() })
                .subscribe(onSuccess: { _ in
                    self.conversation?.available = true
                    self.publish()
                    onCompleted()
                }, onError: { err in
                    onError()
                })
                .disposed(by: disposeBag)
    }

    func sendMessage(message: String, onError: @escaping () -> Void) {
        conversationService.sendMessage(uid: session.uid, conversationId: conversation?.id, message: message)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onSuccess: { [unowned self] message in
                    message.isCurrentUserMessage = true
                    conversation?.messages?.append(message)
                    publish()
                    setReadAll()
                }, onError: { err in
                    onError()
                })
                .disposed(by: disposeBag)
    }

    func channel(user: UserDTO?) {
        if (user != nil) {
            channel.next(value: user!)
        }
    }

    func getSession() -> Session {
        session
    }

    func setReadAll() {
        let message = conversation?.messages?.last
        guard message != nil else {
            return
        }
        DispatchQueue.main.async { [unowned self] in
            if let entity = MessageEntity.from(message: message!) {
                let exist: MessageEntity? = realm.objects(MessageEntity.self)
                        .filter("conversationId = %@", message!.conversationId ?? "").first
                if exist != nil {
                    try! realm.write {
                        realm.add(entity, update: .all)  // update
                    }
                } else {
                    try! realm.write {
                        realm.add(entity)  // insert
                    }
                }
            }
        }
    }
}
