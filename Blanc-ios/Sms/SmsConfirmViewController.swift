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

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var interval: Disposable?

    var session: Session?

    var verificationService: VerificationService?

    var userService: UserService?

    var verificationDTO: VerificationDTO?

    lazy private var smsLabel: UILabel = {
        let label = UILabel()
        label.text = "SMS 휴대폰 전화 인증"
        label.font = UIFont.systemFont(ofSize: 25)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var smsLabel2: UILabel = {
        let label = UILabel()
        label.text = "전달 받은 숫자 코드를 입력 하세요."
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 2;
        label.textColor = .customGray4
        return label
    }()

    lazy private var smsCodeTextField: MDCOutlinedTextField = {
        let textField = MDCOutlinedTextField()

        let rightImage = UIImageView(image: UIImage(systemName: "number.circle"))
        rightImage.image = rightImage.image?.withRenderingMode(.alwaysTemplate)

        textField.trailingView = rightImage
        textField.trailingViewMode = .always
        textField.placeholder = "전달받은 코드를 입력 하세요."
        textField.label.text = "전달받은 코드를 입력 하세요."

        textField.keyboardType = .numberPad
        textField.backgroundColor = .secondarySystemBackground
        textField.containerRadius = Constants.radius
        textField.sizeToFit()
        textField.setColor(primary: .faceBook, secondary: .secondaryLabel)

        textField.leadingAssistiveLabel.text = "6자리의 숫자 코드."
        textField.setLeadingAssistiveLabelColor(.deepGray, for: .normal)
        textField.setLeadingAssistiveLabelColor(.deepGray, for: .editing)

        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        button.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
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
        showRemainingTime()
    }

    override func viewDidLayoutSubviews() {
        smsCodeTextField.becomeFirstResponder()
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

    @objc private func textFieldDidChange() {
        let value = smsCodeTextField.text ?? ""
        let range = NSRange(location: 0, length: value.utf16.count)
        let result = regex.firstMatch(in: value, range: range)
        activateConfirmButton(result != nil)
    }

    @objc private func didTapResetButton() {
        dismiss(animated: true) { [self] in
            interval?.dispose()
        }
    }

    @objc private func didTapConfirmButton() {
        let smsCode = smsCodeTextField.text ?? ""
        let range = NSRange(location: 0, length: smsCode.utf16.count)
        let result = regex.firstMatch(in: smsCode, range: range)
        if (result == nil) {
            return
        }
        spinnerView.visible(true)
        verificationService?.verifySmsCode(
                        currentUser: auth.currentUser!,
                        uid: auth.uid,
                        phone: verificationDTO?.phone,
                        smsCode: smsCode,
                        expiredAt: verificationDTO?.expiredAt
                )
                .do(onSuccess: { [self] it in
                    if (it.verified != true) {
                        let message = "문자 인증에 실패 하였습니다."
                        toast(message: it.reason ?? message)
                        throw NSError(domain: message, code: 42, userInfo: ["uid": auth.uid as String? as Any])
                    }
                })
                .do(onError: { err in
                    log.error(err)
                })
                .flatMap { [self] it -> Single<UserDTO> in
                    userService!.createUser(
                            currentUser: auth.currentUser!,
                            uid: auth.uid,
                            phone: it.phone,
                            smsCode: it.smsCode,
                            smsToken: it.smsToken
                    )
                }
                .flatMap { [self] it -> Single<Void> in
                    session!.generate()
                }
                .subscribe(onSuccess: { [self] _ in
                    spinnerView.visible(false)
                    interval?.dispose()
                    presentPendingViewController()
                }, onError: { [self] err in
                    log.error(err)
                    spinnerView.visible(false)
                    toast(message: "문자 요청에 실패 하였습니다.")
                })
                .disposed(by: disposeBag)
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

    private func formatRemainingTime(expiredAt: Int) -> String {
        let current = Int(NSDate().timeIntervalSince1970)
        let seconds = expiredAt - current
        if (seconds <= 0) {
            dismiss(animated: true) { [self] in
                interval?.dispose()
            }
            return "시간 만료"
        }
        return String(format: "남은 시간: %02d:%02d", ((seconds % 3600) / 60), (seconds % 60))
    }

    private func showRemainingTime() {
        interval = Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
                .subscribe(onNext: { [self] _ in
                    let expiredAt = verificationDTO?.expiredAt ?? 0
                    let formatted = formatRemainingTime(expiredAt: expiredAt)
                    timeLeftLabel.text = formatted
                })
    }


    func setVerificationDTO(verificationDTO: VerificationDTO) {
        self.verificationDTO = verificationDTO
    }

    private func presentPendingViewController() {
        log.info("presenting pending..")
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegistrationNavigationViewController")
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
