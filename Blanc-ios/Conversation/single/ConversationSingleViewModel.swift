import Foundation
import RxSwift

class ConversationSingleViewModel {

    private class Repository {
        weak var conversation: ConversationDTO?
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let observable: ReplaySubject = ReplaySubject<ConversationDTO>.create(bufferSize: 1)

    internal let back: PublishSubject = PublishSubject<Void>()

    internal let toast: PublishSubject = PublishSubject<String>()

    internal var avatar: String? {
        get {
            session.user?.avatar
        }
    }

    private let repository: Repository = Repository()

    private let session: Session

    private let conversationSingleModel: ConversationSingleModel

    init(session: Session, conversationSingleModel: ConversationSingleModel) {
        self.session = session
        self.conversationSingleModel = conversationSingleModel
        subscribeConversationModel()
    }

    deinit {
        log.info("deinit conversation single view model..")
    }

    private func publish() {
        if let conversation = repository.conversation {
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
                repository.conversation = conversation
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

    func leaveConversation() {
        conversationSingleModel
            .leaveConversation()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] _ in
                back.onNext(Void())
            }, onError: { [unowned self]err in
                log.error(err)
                toast.onNext("서버와의 교신에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    func sync() {
        conversationSingleModel.setReadAll()
        if let conversation = repository.conversation {
            Synchronize.next(conversation: conversation)
        }
    }
}