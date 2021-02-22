import Foundation
import RxSwift

class MainTabBarViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<Bool>.create(bufferSize: 1)

    private let conversationModel: ConversationModel

    private var conversations: [ConversationDTO] = []

    init(conversationModel: ConversationModel) {
        self.conversationModel = conversationModel
        subscribeConversationModel()
    }

    private func publish(_ value: Bool) {
        observable.onNext(value)
    }

    func observe() -> Observable<Bool> {
        observable
    }

    private func subscribeConversationModel() {
        conversationModel.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { [self] conversations in
                    let hasUnread = conversations.first(where: {
                        $0.unreadMessageCount ?? 0 > 0
                    }) != nil
                    publish(hasUnread)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }
}
