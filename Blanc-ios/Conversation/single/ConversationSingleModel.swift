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
        log.info("deinit conversation single model..")
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
        channel
            .observe(ConversationDTO.self)
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
        conversationService
            .getConversation(uid: session.uid, conversationId: conversationId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onSuccess: { conversation in
                let partner = conversation.partner
                partner?.distance = partner?.distance(from: self.session.user, type: String.self)
            })
            .map { [unowned self] conversation -> ConversationDTO in
                conversation.messages = conversation.messages?.map { [unowned self] message -> MessageDTO in
                    message.isCurrentUserMessage = (message.userId == session.id && message.userId != nil)
                    return message
                }
                return conversation
            }
            .subscribe(onSuccess: { conversation in
                self.conversation = conversation
                self.conversation?.currentUser = self.session.user
                self.publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func subscribeBroadcast() {
        Broadcast
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onNext: { [unowned self] push in
                if (push.isMessage()) {
                    appendMessage(push: push)
                }
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] push in
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
        conversationService
            .updateConversationAvailable(
                currentUser: auth.currentUser!,
                uid: session.uid,
                conversationId: conversation?.id
            )
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
        conversationService
            .sendMessage(uid: session.uid, conversationId: conversation?.id, message: message)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { message in
                message.isCurrentUserMessage = true
                self.conversation?.messages?.append(message)
                self.publish()
                self.setReadAll()
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
        guard let message = conversation?.messages?.last else {
            return
        }
        guard let entity = MessageEntity.from(message: message) else {
            return
        }
        let exist: MessageEntity? = realm.objects(MessageEntity.self)
            .filter("conversationId = %@", message.conversationId ?? "").first
        if exist != nil {
            try! realm.write {
                self.realm.add(entity, update: .all)  // update
            }
        } else {
            try! realm.write {
                self.realm.add(entity)  // insert
            }
        }
    }
}
