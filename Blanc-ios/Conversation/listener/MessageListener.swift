import Foundation
import RxRealm
import RxSwift
import RealmSwift


class MessageEntity: Object {

    @objc dynamic var messageId = ""
    @objc dynamic var conversationId = ""
    @objc dynamic var userId = ""
    @objc dynamic var category = ""
    @objc dynamic var url = ""
    @objc dynamic var message = ""
    @objc dynamic var createdAt = 0

    override static func primaryKey() -> String? {
        "conversationId"
    }

    convenience init(_ push: PushDTO) {
        self.init()
        messageId = push.messageId ?? ""
        conversationId = push.conversationId ?? ""
        userId = push.userId ?? ""
        url = push.url ?? ""
        message = push.message ?? ""
        createdAt = push.createdAt ?? 0
    }
}

extension MessageEntity {
    static func from(message: MessageDTO) -> MessageEntity? {

        guard(message.id != nil) else {
            return nil
        }

        guard (message.conversationId != nil) else {
            return nil
        }

        let entity = MessageEntity()
        entity.messageId = message.id!
        entity.conversationId = message.conversationId!
        entity.userId = message.userId ?? ""
        entity.category = message.category?.rawValue ?? ""
        entity.url = message.url ?? ""
        entity.message = message.message ?? ""
        entity.createdAt = message.createdAt ?? 0
        return entity
    }
}


class RealmConversationManager {

    static private let disposeBag: DisposeBag = DisposeBag()

    static private let realm = try! Realm()

    static func getMessage(conversationId: String) -> MessageEntity? {
        let message: MessageEntity? = realm.objects(MessageEntity.self)
                .filter("conversationId = %@", conversationId).first
        return message
    }

    static func setLastReadMessage(message: MessageEntity) {
        var exist = getMessage(conversationId: message.conversationId)
        if exist != nil {
            try! realm.write {
                exist = message  // update
            }
        } else {
            try! realm.write {
                realm.add(message)  // insert
            }
        }
    }

    static func deleteMessages(conversationId: String) {
        do {
            let query = "conversationId = %@"
            let param = conversationId
            let targets = realm.objects(MessageEntity.self).filter(query, param)
            try! realm.write {
                realm.delete(targets)
            }
        } catch let err {
            log.error(err)
        }
    }
}
