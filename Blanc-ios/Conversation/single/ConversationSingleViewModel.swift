import Foundation
import RxSwift

class ConversationSingleViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    private weak var conversation: ConversationDTO?

    private let conversationSingleModel: ConversationSingleModel

    private let conversationModel: ConversationModel

    init(conversationSingleModel: ConversationSingleModel, conversationModel: ConversationModel) {
        self.conversationSingleModel = conversationSingleModel
        self.conversationModel = conversationModel
        subscribeConversationModel()
    }

    deinit {
        log.info("deinit conversation single view model..")
    }

    private func publish() {
        if let conversation = conversation {
            observable.onNext(conversation)
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

    func updateConversationAvailable(conversation: ConversationDTO?) {
        let onCompleted = {
            self.toast.onNext("대화방이 정상적으로 열렸습니다.")
        }
        let onError = {
            self.toast.onNext("대화방을 여는 도중 에러가 발생 하였습니다.")
        }
        conversationSingleModel.updateConversationAvailable(
            conversation: conversation, onCompleted: onCompleted, onError: onError
        )
    }

    func sendMessage(message: String) {
        let onError = {
            self.toast.onNext("메시지 전송에 실패 하였습니다.")
        }
        conversationSingleModel.sendMessage(message: message, onError: onError)
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