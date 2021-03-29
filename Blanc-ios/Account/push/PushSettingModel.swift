import Foundation
import RxSwift

enum PushSettingAttribute: String {
    case all = "전체",
         poke = "찔러보기",
         request = "친구 요청",
         comment = "내 게시물 코멘트",
         highRate = "내게 높은 점수",
         matched = "매칭",
         commentThumbUp = "내 코멘트 좋아요",
         conversationOpen = "대화방 오픈",
         lookup = "내 프로필 열람 한 유저",
         postFavorite = "내 게시물 좋아요",
         conversation = "대화방 메세지"
}

class PushSettingModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<PushSetting>.create(bufferSize: 1)

    private var pushSetting: PushSetting?

    private var session: Session

    private var userService: UserService

    init(session: Session, userService: UserService) {
        self.session = session
        self.userService = userService
        populate()
    }

    func observe() -> Observable<PushSetting> {
        observable
    }

    private func populate() {
        guard let uid = session.uid,
              let userId = session.id else {
            return
        }
        userService
            .getPushSetting(uid: uid, userId: userId)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { pushSetting in
                self.pushSetting = pushSetting
                self.publish()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func publish() {
        guard let pushSetting = pushSetting else {
            return
        }
        observable.onNext(pushSetting)
    }

    func update(_ attribute: PushSettingAttribute, onError: @escaping () -> Void) {

        guard let pushSetting = pushSetting else {
            return
        }

        if (attribute == .all) {
            pushSetting.all = !pushSetting.all
        } else if (attribute == .poke) {
            pushSetting.poke = !(pushSetting.poke ?? false)
        } else if (attribute == .request) {
            pushSetting.request = !(pushSetting.request ?? false)
        } else if (attribute == .comment) {
            pushSetting.comment = !(pushSetting.comment ?? false)
        } else if (attribute == .highRate) {
            pushSetting.highRate = !(pushSetting.highRate ?? false)
        } else if (attribute == .matched) {
            pushSetting.matched = !(pushSetting.matched ?? false)
        } else if (attribute == .postFavorite) {
            pushSetting.postFavorite = !(pushSetting.postFavorite ?? false)
        } else if (attribute == .commentThumbUp) {
            pushSetting.commentThumbUp = !(pushSetting.commentThumbUp ?? false)
        } else if (attribute == .conversationOpen) {
            pushSetting.conversationOpen = !(pushSetting.conversationOpen ?? false)
        } else if (attribute == .lookup) {
            pushSetting.lookup = !(pushSetting.lookup ?? false)
        } else if (attribute == .conversation) {
            pushSetting.conversation = !(pushSetting.conversation ?? false)
        } else {
            fatalError("WATCH OUT YOUR ASS HOLE..")
        }

        updateUserPushSetting()
        publish()
    }

    private func updateUserPushSetting() {
        guard let uid = session.uid,
              let userId = session.id,
              let pushSetting = pushSetting else {
            return
        }
        userService
            .updateUserPushSetting(
                uid: uid,
                userId: userId,
                pushSetting: pushSetting
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onSuccess: { _ in
                log.info("Successfully push setting updated...")
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}
