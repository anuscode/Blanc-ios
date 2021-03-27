import Foundation
import RxSwift
import FirebaseAuth

class ReportUserViewModel {

    private class Repository {
        var reportee: UserDTO!
    }

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    internal let reportee: ReplaySubject = ReplaySubject<UserDTO>.create(bufferSize: 1)

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    internal let popView: PublishSubject = PublishSubject<Void>()

    internal let reportButton: PublishSubject = PublishSubject<Bool>()

    private let repository: Repository = Repository()

    private var session: Session

    private var reportService: ReportService

    init(session: Session, reportService: ReportService) {
        self.session = session
        self.reportService = reportService
        subscribeChannel()
    }

    private func publish() {
        reportee.onNext(repository.reportee)
    }

    func subscribeChannel() {
        Channel
            .reportee
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .subscribe(onNext: { [unowned self] reportee in
                repository.reportee = reportee
                publish()
            })
            .disposed(by: disposeBag)
    }

    func report(files: [UIImage], description: String) {
        guard let uid = auth.uid,
              let reporterId = session.id,
              let reporteeId = repository.reportee.id else {
            toast.onNext("잘못 된 설정 값입니다. 화면 종료 후 다시 시도해 주세요.")
            return
        }
        loading.onNext(true)
        reportButton.onNext(false)
        reportService
            .report(
                uid: uid,
                reporterId: reporterId,
                reporteeId: reporteeId,
                files: files,
                description: description
            )
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .do(onDispose: { [unowned self] in
                loading.onNext(false)
                reportButton.onNext(true)
            })
            .subscribe(onSuccess: { [unowned self] in
                toast.onNext("신고가 접수 되었습니다.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [unowned self] in
                    popView.onNext(Void())
                }
            }, onError: { [unowned self] err in
                toast.onNext("신고에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }
}
