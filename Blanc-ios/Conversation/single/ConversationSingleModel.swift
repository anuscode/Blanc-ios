import Foundation
import RxSwift
import FirebaseAuth
import RealmSwift

class ConversationSingleModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    private let realm = try! Realm()

    private let observable: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    private var conversation: ConversationDTO?

    private var session: Session

    private let conversationService: ConversationService

    private let conversationModel: ConversationModel

    init(session: Session, conversationService: ConversationService, conversationModel: ConversationModel) {
        self.session = session
        self.conversationService = conversationService
        self.conversationModel = conversationModel
        populate()
        subscribeBroadcast()
        subscribeBackground()
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
                    guard let conversationId = push.conversationId else {
                        return
                    }
                    if (conversation?.id == conversationId) {
                        conversation?.available = true
                        publish()
                    }
                }
                if (push.isLeft()) {
                    guard let conversationId = push.conversationId,
                          let userId = push.userId else {
                        return
                    }
                    if (conversation?.id == conversationId) {
                        if let index = conversation?.participants?.firstIndex(where: { $0.id == userId }) {
                            conversation?.participants?.remove(at: index)
                            publish()
                        }
                    }
                }
            })
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] _ in
                setReadAll()
            })
            .disposed(by: disposeBag)
    }

    private func subscribeBackground() {
        Background
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] push in
                populate()
            })
            .disposed(by: disposeBag)
    }

    private func appendMessage(push: PushDTO) {
        let message = MessageDTO.from(push: push)
        guard let _ = message.conversationId,
              let messageId = message.id else {
            return
        }
        let index = conversation?.messages?.firstIndex(where: { $0.id == messageId })
        if (index == nil) {
            conversation?.messages?.append(message)
        }
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

    func leaveConversation() -> Single<Void> {
        guard let uid = auth.uid,
              let conversationId = conversation?.id,
              let userId = session.id else {
            return Single<Void>.just(Void())
        }
        return conversationService
            .leaveConversation(
                uid: uid,
                conversationId: conversationId,
                userId: userId
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onNext: { [unowned self] _ in
                conversationModel.remove(conversationId: conversationId)
            })
    }
}
