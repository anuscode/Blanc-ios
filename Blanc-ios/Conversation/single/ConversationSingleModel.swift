import Foundation
import RxSwift
import FirebaseAuth
import RealmSwift

class ConversationSingleModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    private var conversation: ConversationDTO?

    private var session: Session

    private let conversationService: ConversationService

    private let auth: Auth = Auth.auth()

    private let realm = try! Realm()

    init(session: Session, conversationService: ConversationService) {
        self.session = session
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
        if let conversation = conversation {
            observable.onNext(conversation)
        }
    }

    private func populate() {
        Channel
            .conversation
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] conversation in
                getConversation(conversationId: conversation.id)
            })
            .disposed(by: disposeBag)
    }

    private func getConversation(conversationId: String?) {
        guard let uid = session.uid,
              let conversationId = conversationId else {
            return
        }
        conversationService
            .getConversation(uid: uid, conversationId: conversationId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onSuccess: { [unowned self] conversation in
                conversation.currentUser = session.user
                let partner = conversation.partner
                partner?.relationship = session.relationship(with: partner)
            })
            .do(onSuccess: { [unowned self] conversation in
                conversation.messages?.forEach { message in
                    message.isCurrentUserMessage = message.userId == session.id
                }
            })
            .subscribe(onSuccess: { [unowned self] conversation in
                self.conversation = conversation
                publish()
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
                    publish()
                }
                if (push.isOpened()) {
                    let conversationId = push.conversationId
                    if (conversation?.id == conversationId) {
                        conversation?.available = true
                        publish()
                    }
                }
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] _ in
                setReadAll()
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
    }

    func updateConversationAvailable(
        conversation: ConversationDTO?,
        onCompleted: @escaping () -> Void,
        onError: @escaping () -> Void
    ) {
        let currentUser = auth.currentUser!
        let uid = session.uid
        let conversationId = conversation?.id
        conversationService
            .updateConversationAvailable(
                currentUser: currentUser,
                uid: uid,
                conversationId: conversationId
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap({ [unowned self] _ in
                session.refresh()
            })
            .subscribe(onSuccess: { [unowned self] _ in
                self.conversation?.available = true
                publish()
                onCompleted()
            }, onError: { err in
                onError()
            })
            .disposed(by: disposeBag)
    }

    func sendMessage(message: String, onError: @escaping () -> Void) {
        let uid = session.uid
        let conversationId = conversation?.id
        conversationService
            .sendMessage(
                uid: uid,
                conversationId: conversationId,
                message: message
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
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
