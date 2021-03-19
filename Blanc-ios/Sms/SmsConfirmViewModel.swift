import Foundation
import RxSwift
import FirebaseAuth

class SmsConfirmViewModel {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    internal let toast: PublishSubject = PublishSubject<String>()

    internal let loading: PublishSubject = PublishSubject<Bool>()

    internal let registration: PublishSubject = PublishSubject<Void>()

    internal let confirmButton: PublishSubject = PublishSubject<Bool>()

    internal let resetButton: PublishSubject = PublishSubject<Bool>()

    private let session: Session

    private let userService: UserService

    private let verificationService: VerificationService

    init(session: Session, userService: UserService, verificationService: VerificationService) {
        self.session = session
        self.userService = userService
        self.verificationService = verificationService
    }

    deinit {
        log.info("deinit SmsConfirmViewModel..")
    }

    func verifySmsCode(phone: String, smsCode: String, expiredAt: Int) {

        guard let currentUser = auth.currentUser,
              let uid = auth.uid else {
            toast.onNext("지정 된 로그인 값이 유효하지 않습니다. 다시 로그인해 주세요.")
            return
        }

        // initial view setup before verifying sms code..
        loading.onNext(true)
        confirmButton.onNext(false)
        resetButton.onNext(false)

        verificationService
            .verifySmsCode(
                currentUser: currentUser,
                uid: uid,
                phone: phone,
                smsCode: smsCode,
                expiredAt: expiredAt
            )
            .do(onSuccess: { [unowned self] it in
                if (it.status == .INVALID_SMS_CODE) {
                    let message = "유효하지 않은 인증번호 입니다."
                    toast.onNext(message)
                    throw NSError(domain: message, code: 42, userInfo: nil)
                }
                if (it.status == .EXPIRED_SMS_CODE) {
                    let message = "인증시간이 만료 되었습니다."
                    toast.onNext(message)
                    throw NSError(domain: message, code: 42, userInfo: nil)
                }
                if (it.status == .DUPLICATE_PHONE_NUMBER) {
                    let message = "이미 등록 된 전화번호 입니다."
                    toast.onNext(message)
                    throw NSError(domain: message, code: 42, userInfo: nil)
                }
                if (it.status == .VERIFIED_SMS_CODE) {
                    log.info("Successfully verified sms code..")
                }
            })
            .do(onError: { [unowned self] err in
                log.error(err)
                confirmButton.onNext(true)
            })
            .flatMap { [unowned self] it -> Single<UserDTO> in
                userService.createUser(
                    currentUser: currentUser,
                    uid: uid,
                    phone: it.phone,
                    smsCode: it.smsCode,
                    smsToken: it.smsToken
                )
            }
            .flatMap { [unowned self] it -> Single<Void> in
                session.generate()
            }
            .observeOn(MainScheduler.instance)
            .do(onDispose: { [unowned self] in
                loading.onNext(false)
                confirmButton.onNext(true)
                resetButton.onNext(true)
            })
            .subscribe(onSuccess: { [unowned self] _ in
                registration.onNext(Void())
            }, onError: { [unowned self] err in
                log.error(err)
                toast.onNext("문자 인증에 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }
}
