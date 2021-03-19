import Foundation
import RxSwift
import FirebaseAuth

class SmsViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    internal let smsConfirm: PublishSubject = PublishSubject<VerificationDTO>()

    private let verificationService: VerificationService

    init(verificationService: VerificationService) {
        self.verificationService = verificationService
    }

    func issueSms(phone: String) {
        guard let currentUser = auth.currentUser,
              let uid = auth.uid else {
            toast.onNext("계정 인증의 문제가 발생 하였습니다. 다시 로그인 해 주세요.")
            return
        }
        loading.onNext(true)
        verificationService
            .issueSmsCode(currentUser: currentUser, uid: uid, phone: phone)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .do(onDispose: { [unowned self] in
                loading.onNext(false)
            })
            .subscribe(onSuccess: { [unowned self] verification in
                let status = verification.status
                switch status {
                case .SUCCEED_ISSUE:
                    log.info("SUCCEED_ISSUE")
                    smsConfirm.onNext(verification)
                case .FAILED_ISSUE:
                    toast.onNext("문자 발송에 실패 하였습니다. 개발팀에 문의 주세요.")
                case .INVALID_PHONE_NUMBER:
                    toast.onNext("옳바르지 않은 전화번호 입니다.")
                default:
                    toast.onNext("알 수 없는 에러가 발생 하였습니다.")
                }
            }, onError: { [unowned self] err in
                log.error(err)
                toast.onNext("문자 요청에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    public func signOut() {
        do {
            try auth.signOut()
        } catch {
            log.error("Failed to logout.")
        }
    }
}
