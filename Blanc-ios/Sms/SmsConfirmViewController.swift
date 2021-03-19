import FirebaseAuth
import UIKit
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import RxSwift
import SwinjectStoryboard

class SmsConfirmViewController: UIViewController {

    private let smsRegex = try! NSRegularExpression(pattern: "^[0-9]{6}$")

    private let auth: Auth = Auth.auth()

    private var disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    internal var verification: VerificationDTO?

    internal var smsConfirmViewModel: SmsConfirmViewModel?

    lazy private var backButton: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_arrow_back")
        imageView.image = image
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.width(30)
        imageView.height(30)
        imageView.rx
            .tapGesture()
            .when(.recognized)
            .take(1)
            .subscribe(onNext: { [unowned self] _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        ripple.activate(to: imageView)
        return imageView
    }()

    lazy private var smsLabel: UILabel = {
        let label = UILabel()
        label.text = "SMS 인증"
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
                let result = self.smsRegex.firstMatch(in: value, range: range)
                return (result != nil)
            })
            .subscribe(onNext: self.activateConfirmButton)
            .disposed(by: disposeBag)
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
            .disposed(by: disposeBag)
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
        subscribeSmsConfirmViewModel()
        interval()
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
        SwinjectStoryboard.defaultContainer.resetObjectScope(.smsConfirmScope)
    }

    private func configureSubviews() {
        view.addSubview(backButton)
        view.addSubview(smsLabel)
        view.addSubview(smsLabel2)
        view.addSubview(smsCodeTextField)
        view.addSubview(confirmButton)
        view.addSubview(resetButton)
        view.addSubview(timeLeftLabel)
        view.addSubview(spinnerView)
    }

    private func configureConstraints() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        smsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.top.equalTo(backButton.snp.bottom).offset(15)
        }
        smsLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.top.equalTo(smsLabel.snp.bottom).offset(20)
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

    private func subscribeSmsConfirmViewModel() {
        smsConfirmViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        smsConfirmViewModel?
            .loading
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] boolean in
                showLoading(boolean)
            })
            .disposed(by: disposeBag)

        smsConfirmViewModel?
            .confirmButton
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] boolean in
                activateConfirmButton(boolean)
            })
            .disposed(by: disposeBag)

        smsConfirmViewModel?
            .resetButton
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] boolean in
                activateResetButton(boolean)
            })
            .disposed(by: disposeBag)

        smsConfirmViewModel?
            .registration
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] _ in
                goRegistrationView()
            })
            .disposed(by: disposeBag)
    }

    private func interval() {
        Observable<Int>
            .interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                let expiredAt = verification?.expiredAt ?? 0
                let current = Int(NSDate().timeIntervalSince1970)
                let seconds = expiredAt - current
                if (seconds <= 0) {
                    dismiss(animated: true)
                }
                let format = "남은 시간: %02d:%02d"
                let min = (seconds % 3600) / 60
                let sec = seconds % 60
                let text = String(format: format, min, sec)
                timeLeftLabel.text = text
            })
            .disposed(by: disposeBag)
    }

    func setVerification(_ verification: VerificationDTO) {
        self.verification = verification
    }

    private func showLoading(_ boolean: Bool) {
        spinnerView.visible(boolean)
    }

    private func activateConfirmButton(_ boolean: Bool) {
        if (boolean) {
            confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
            confirmButton.backgroundColor = .systemBlue
        } else {
            confirmButton.removeTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
            confirmButton.backgroundColor = .systemGray5
        }
    }

    private func activateResetButton(_ boolean: Bool) {
        resetButton.isUserInteractionEnabled = boolean
    }

    private func goRegistrationView() {
        replace(storyboard: "Registration", withIdentifier: "RegistrationNavigationViewController")
    }

    @objc private func didTapConfirmButton() {
        let smsCode = smsCodeTextField.text ?? ""
        let range = NSRange(location: 0, length: smsCode.utf16.count)
        let result = smsRegex.firstMatch(in: smsCode, range: range)

        if (result == nil) {
            toast(message: "SMS 번호가 옳바르지 않습니다.")
            return
        }
        guard let phone = verification?.phone,
              let expiredAt = verification?.expiredAt else {
            toast(message: "잘못 된 설정 입니다. 초기화 후 다시 시도해 주세요.")
            return
        }
        smsConfirmViewModel?.verifySmsCode(phone: phone, smsCode: smsCode, expiredAt: expiredAt)
    }
}
