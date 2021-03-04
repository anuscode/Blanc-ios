import AMShimmer
import FirebaseAuth
import Foundation
import MaterialComponents.MaterialTextControls_FilledTextAreas
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import UIKit
import RxSwift
import SwinjectStoryboard


class SmsViewController: UIViewController {

    private let regex = try! NSRegularExpression(pattern: "^\\+82[\\s-]?(0?10)[\\s-]?[0-9]{3,4}[\\s-]?[0-9]{4}$")

    private let auth: Auth = Auth.auth()

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var verificationService: VerificationService?

    lazy private var smsLabel: UILabel = {
        let label = UILabel()
        label.text = "SMS 휴대폰 전화 인증"
        label.font = .systemFont(ofSize: 28)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var smsLabel2: UILabel = {
        let label = UILabel()
        label.text = "전화번호는 개인 식별 용으로만 사용 되고\n절대 공개 되지 않습니다."
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 2;
        label.textColor = .customGray4
        return label
    }()

    lazy private var phoneTextField: MDCOutlinedTextField = {
        let textField = MDCOutlinedTextField()

        let rightImage = UIImageView(image: UIImage(systemName: "number.circle"))
        rightImage.image = rightImage.image?.withRenderingMode(.alwaysTemplate)

        textField.label.text = "휴대폰 번호를 입력 하세요"
        textField.text = "+82"
        textField.trailingView = rightImage
        textField.trailingViewMode = .always
        textField.placeholder = "+82 10 5555 5555"

        textField.keyboardType = .numberPad
        textField.backgroundColor = .secondarySystemBackground
        textField.containerRadius = Constants.radius2
        textField.setColor(primary: .black, secondary: .secondaryLabel)

        textField.leadingAssistiveLabel.text = "옳바른 형식: +82 10 5555 5555 (하이픈 공백 없이)"
        textField.setLeadingAssistiveLabelColor(.black, for: .normal)
        textField.setLeadingAssistiveLabelColor(.black, for: .editing)

        textField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)
        return textField
    }()

    lazy private var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.radius2
        button.backgroundColor = .systemGray5
        button.setTitleColor(.white, for: .normal)
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
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
    }

    override func viewDidLayoutSubviews() {
        phoneTextField.becomeFirstResponder()
    }

    private func configureSubviews() {
        view.addSubview(smsLabel)
        view.addSubview(smsLabel2)
        view.addSubview(phoneTextField)
        view.addSubview(confirmButton)
        view.addSubview(spinnerView)
    }

    private func configureConstraints() {
        smsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
        }

        smsLabel2.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.top.equalTo(smsLabel.snp.bottom).offset(10)
        }

        phoneTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.top.equalTo(smsLabel2.snp.bottom).offset(30)
            make.width.equalTo(view.width - 50)
            make.height.equalTo(60)
        }

        confirmButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25)
            make.top.equalTo(phoneTextField.snp.bottom).offset(50)
            make.width.equalTo(view.width - 50)
            make.height.equalTo(52)
        }

        spinnerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    @objc private func didChangeTextField() {
        let value = phoneTextField.text ?? ""
        let range = NSRange(location: 0, length: value.utf16.count)
        let result = regex.firstMatch(in: value, range: range)
        activateConfirmButton(result != nil)
        if (value == "") {
            phoneTextField.text = "+"
        }
    }

    @objc private func didTapConfirmButton() {
        let phone = phoneTextField.text ?? ""
        let range = NSRange(location: 0, length: phone.utf16.count)
        let result = regex.firstMatch(in: phone, range: range)
        if (result == nil) {
            return
        }

        spinnerView.visible(true)
        verificationService?.issueSmsCode(currentUser: auth.currentUser!, uid: auth.uid, phone: phone)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .do(onDispose: { [unowned self] in
                    spinnerView.visible(false)
                })
                .subscribe(onSuccess: { [unowned self] verificationDTO in
                    if (verificationDTO.issued == true) {
                        let smsConfirmViewController = SmsConfirmViewController()
                        let session = SwinjectStoryboard.defaultContainer.resolve(Session.self)
                        let userService = SwinjectStoryboard.defaultContainer.resolve(UserService.self)
                        let verificationService = SwinjectStoryboard.defaultContainer.resolve(VerificationService.self)
                        smsConfirmViewController.session = session
                        smsConfirmViewController.userService = userService
                        smsConfirmViewController.verificationService = verificationService
                        smsConfirmViewController.setVerificationDTO(verificationDTO: verificationDTO)
                        smsConfirmViewController.modalPresentationStyle = .fullScreen
                        present(smsConfirmViewController, animated: false)
                    } else {
                        toast(message: verificationDTO.reason)
                    }
                }, onError: { [unowned self]err in
                    log.error(err)
                    toast(message: "문자 요청에 실패 하였습니다.")
                }).disposed(by: disposeBag)
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
}
