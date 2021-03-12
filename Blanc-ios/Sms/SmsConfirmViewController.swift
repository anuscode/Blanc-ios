import FirebaseAuth
import UIKit
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import RxSwift

class SmsConfirmViewController: UIViewController {

    private let regex = try! NSRegularExpression(pattern: "^[0-9]{6}$")

    private let auth: Auth = Auth.auth()

    private var disposeBag: DisposeBag? = DisposeBag()

    private let ripple: Ripple = Ripple()

    internal weak var session: Session?

    internal weak var verificationService: VerificationService?

    internal weak var userService: UserService?

    internal var verification: VerificationDTO?

    lazy private var smsLabel: UILabel = {
        let label = UILabel()
        label.text = "SMS 모바일 인증"
        label.font = .systemFont(ofSize: 28)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var smsLabel2: UILabel = {
        let label = UILabel()
        label.text = "전달 받은 코드를 입력 하세요."
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 2;
        label.textColor = .customGray4
        return label
    }()

    lazy private var smsCodeTextField: MDCOutlinedTextField = {
        let rightImage = UIImageView(image: UIImage(systemName: "number.circle"))
        rightImage.image = rightImage.image?.withRenderingMode(.alwaysTemplate)
        let textField = MDCOutlinedTextField()
        textField.trailingView = rightImage
        textField.trailingViewMode = .always
        textField.placeholder = "전달받은 코드를 입력 하세요."
        textField.label.text = "전달받은 코드를 입력 하세요."
        textField.keyboardType = .numberPad
        textField.backgroundColor = .secondarySystemBackground
        textField.containerRadius = Constants.radius
        textField.sizeToFit()
        textField.setColor(primary: .black, secondary: .secondaryLabel)
        textField.leadingAssistiveLabel.text = "6자리의 숫자 코드."
        textField.setLeadingAssistiveLabelColor(.black, for: .normal)
        textField.setLeadingAssistiveLabelColor(.black, for: .editing)
        textField.rx
            .text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map({ [unowned self] text -> String in text ?? "" })
            .map({ [unowned self] text -> Bool in
                let value = text
                let range = NSRange(location: 0, length: value.utf16.count)
                let result = self.regex.firstMatch(in: value, range: range)
                return (result != nil)
            })
            .subscribe(onNext: self.activateConfirmButton)
            .disposed(by: disposeBag!)
        return textField
    }()

    lazy private var timeLeftLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.text = "남은 시간: 10:00"
        return label
    }()

    lazy private var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("초기화", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.rx
            .tapGesture()
            .when(.recognized)
            .take(1)
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag!)
        return button
    }()

    lazy private var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = .systemGray5
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    lazy private var spinnerView: Spinner = {
        let view = Spinner()
        view.visible(false)
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        initInterval()
    }

    override func viewDidLayoutSubviews() {
        smsCodeTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }

    deinit {
        log.info("deinit SmsConfirmViewController..")
    }

    private func configureSubviews() {
        view.addSubview(smsLabel)
        view.addSubview(smsLabel2)
        view.addSubview(smsCodeTextField)
        view.addSubview(confirmButton)
        view.addSubview(resetButton)
        view.addSubview(timeLeftLabel)
        view.addSubview(spinnerView)
    }

    private func configureConstraints() {
        smsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.width.equalTo(view.width - 50)
        }

        smsLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.top.equalTo(smsLabel.snp.bottom).offset(10)
            make.width.equalTo(view.width - 50)
        }

        smsCodeTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.top.equalTo(smsLabel2.snp.bottom).offset(30)
            make.width.equalTo(view.width - 50)
            make.height.equalTo(60)
        }

        timeLeftLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(25)
            make.top.equalTo(smsCodeTextField.snp.bottom).offset(40)
            make.width.equalTo(view.width - 50)
            make.height.equalTo(52)
        }

        confirmButton.snp.makeConstraints { make in
            make.trailing.equalTo(smsCodeTextField.snp.trailing)
            make.top.equalTo(smsCodeTextField.snp.bottom).offset(40)
            make.width.equalTo((view.width - 50) / 3)
            make.height.equalTo(52)
        }

        resetButton.snp.makeConstraints { make in
            make.trailing.equalTo(confirmButton.snp.leading).inset(-20)
            make.centerY.equalTo(confirmButton.snp.centerY)
            make.width.equalTo(resetButton.intrinsicContentSize.width)
            make.height.equalTo(52)
        }

        spinnerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @objc private func didTapConfirmButton() {
        let smsCode = smsCodeTextField.text ?? ""
        let range = NSRange(location: 0, length: smsCode.utf16.count)
        let result = regex.firstMatch(in: smsCode, range: range)
        if (result == nil) {
            return
        }
        guard let currentUser = auth.currentUser,
              let uid = auth.uid else {
            return
        }
        spinnerView.visible(true)
        activateConfirmButton(false)
        verificationService?.verifySmsCode(
                currentUser: auth.currentUser!,
                uid: auth.uid,
                phone: verification?.phone,
                smsCode: smsCode,
                expiredAt: verification?.expiredAt
            )
            .do(onSuccess: { [unowned self] it in
                if (it.status == .INVALID_SMS_CODE) {
                    let message = "유효하지 않은 인증번호 입니다."
                    toast(message: message)
                    throw NSError(domain: message, code: 42, userInfo: nil)
                }
                if (it.status == .EXPIRED_SMS_CODE) {
                    let message = "인증시간이 만료 되었습니다."
                    toast(message: message)
                    throw NSError(domain: message, code: 42, userInfo: nil)
                }
                if (it.status == .VERIFIED_SMS_CODE) {
                    log.info("Successfully verified sms code..")
                }
            })
            .do(onError: { [unowned self] err in
                log.error(err)
                activateConfirmButton(true)
            })
            .flatMap { [unowned self] it -> Single<UserDTO> in
                userService!.createUser(
                    currentUser: currentUser,
                    uid: uid,
                    phone: it.phone,
                    smsCode: it.smsCode,
                    smsToken: it.smsToken
                )
            }
            .flatMap { [unowned self] it -> Single<Void> in
                session!.generate()
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] _ in
                spinnerView.visible(false)
                replace(storyboard: "Registration", withIdentifier: "RegistrationNavigationViewController")
            }, onError: { [unowned self] err in
                log.error(err)
                spinnerView.visible(false)
                activateConfirmButton(true)
                toast(message: "문자 인증에 실패 하였습니다.")
            })
            .disposed(by: disposeBag!)
    }

    private func activateConfirmButton(_ isActivate: Bool) {
        if (isActivate) {
            confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
            confirmButton.backgroundColor = .systemBlue
        } else {
            confirmButton.removeTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
            confirmButton.backgroundColor = .systemGray5
        }
    }

    private func formatRemainingTime(_ expiredAt: Int) -> String {
        let current = Int(NSDate().timeIntervalSince1970)
        let seconds = expiredAt - current
        if (seconds <= 0) {
            dismiss(animated: true)
            return "시간 만료"
        }
        return String(format: "남은 시간: %02d:%02d", ((seconds % 3600) / 60), (seconds % 60))
    }

    private func initInterval() {
        Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                let expiredAt = verification?.expiredAt ?? 0
                let formatted = formatRemainingTime(expiredAt)
                timeLeftLabel.text = formatted
            })
            .disposed(by: disposeBag!)
    }

    func setVerification(_ verification: VerificationDTO) {
        self.verification = verification
    }
}
