import Foundation
import RxSwift

enum PushSettingAttribute: String {
    case all = "전체",
         poke = "찔러보기",
         request = "친구 요청",
         comment = "내 게시물 코멘트",
         highRate = "내게 높은 점수",
         match = "매칭",
         favoriteComment = "내 코멘트 좋아요",
         conversation = "대화방 오픈",
         lookup = "내 프로필 열람 한 유저"
}

class PushSetting: Encodable, Decodable {
    var all: Bool {
        get {
            let flags: Set<Bool> = [poke, request, comment, highRate, match, favoriteComment, conversation, lookup]
            return flags.count == 1 && flags.contains(true)
        }
        set(newValue) {
            poke = newValue
            request = newValue
            comment = newValue
            highRate = newValue
            match = newValue
            favoriteComment = newValue
            conversation = newValue
            lookup = newValue
        }
    }
    var poke: Bool = true
    var request: Bool = true
    var comment: Bool = true
    var highRate: Bool = true
    var match: Bool = true
    var favoriteComment: Bool = true
    var conversation: Bool = true
    var lookup: Bool = true

    private func iterate() -> [Bool] {
        []
    }

    func encode() throws -> Data {
        try PropertyListEncoder().encode(self)
    }

    static func decode(data: Data) throws -> PushSetting {
        try PropertyListDecoder().decode(PushSetting.self, from: data)
    }
}

class PushSettingModel {

    private let key = "push_setting"

    private let pref = UserDefaults.standard

    private let observable: ReplaySubject = ReplaySubject<PushSetting>.create(bufferSize: 1)

    private var pushSetting: PushSetting

    init() {
        let data = pref.value(forKey: key) as? Data
        var pushSetting: PushSetting
        if (data == nil) {
            pushSetting = PushSetting()
        } else {
            if let result = try? PushSetting.decode(data: data!) {
                pushSetting = result
            } else {
                pushSetting = PushSetting()
            }
        }
        self.pushSetting = pushSetting
        publish()
    }

    func observe() -> Observable<PushSetting> {
        observable
    }

    private func publish() {
        observable.onNext(pushSetting)
    }

    func update(_ attribute: PushSettingAttribute, onError: @escaping () -> Void) {
        // all, poke, request, comment, highRate, match, favoriteComment, conversation, lookup
        if (attribute == PushSettingAttribute.all) {
            pushSetting.all = !pushSetting.all
        } else if (attribute == PushSettingAttribute.poke) {
            pushSetting.poke = !pushSetting.poke
        } else if (attribute == PushSettingAttribute.request) {
            pushSetting.request = !pushSetting.request
        } else if (attribute == PushSettingAttribute.comment) {
            pushSetting.comment = !pushSetting.comment
        } else if (attribute == PushSettingAttribute.highRate) {
            pushSetting.highRate = !pushSetting.highRate
        } else if (attribute == PushSettingAttribute.match) {
            pushSetting.match = !pushSetting.match
        } else if (attribute == PushSettingAttribute.favoriteComment) {
            pushSetting.favoriteComment = !pushSetting.favoriteComment
        } else if (attribute == PushSettingAttribute.conversation) {
            pushSetting.conversation = !pushSetting.conversation
        } else if (attribute == PushSettingAttribute.lookup) {
            pushSetting.lookup = !pushSetting.lookup
        } else {
            fatalError("WATCH OUT YOUR ASS HOLE..")
        }

        if let encoded = try? pushSetting.encode() {
            pref.set(encoded, forKey: key)
        } else {
            onError()
        }

        publish()
    }
}
