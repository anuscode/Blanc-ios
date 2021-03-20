import Foundation
import RxSwift
import FirebaseAuth

class ReportViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    internal let popView: PublishSubject = PublishSubject<Void>()

    internal let reportButton: PublishSubject = PublishSubject<Bool>()

    private var reportService: ReportService

    init(reportService: ReportService) {
        self.reportService = reportService
    }

    func report(files: [UIImage], description: String) {
        loading.onNext(true)
        reportButton.onNext(false)
        reportService
            .report(uid: auth.uid, files: files, description: description)
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
