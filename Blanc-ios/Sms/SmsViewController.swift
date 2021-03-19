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

    private var disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    internal var smsViewModel: SmsViewModel?

    lazy private var backButton: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "ic_arrow_back")
        imageView.image = image
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.width(30)
        imageView.height(30)
        imageView.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapBackButton))
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
        label.text = "전화번호는 개인 식별 용으로만 사용 되고\n절대 공개 되지 않습니다."
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2;
        label.textColor = .customGray4
        return label
    }()

    lazy private var phoneTextField: MDCOutlinedTextField = {
        let textField = MDCOutlinedTextField()
        let rightImage = UIImageView(image: UIImage(systemName: "iphone"))
        rightImage.image = rightImage.image?.withRenderingMode(.alwaysTemplate)
        textField.label.text = "휴대폰 번호를 입력하세요"
        textField.trailingView = rightImage
        textField.trailingViewMode = .always
        textField.placeholder = "휴대폰 번호를 입력하세요."
        textField.keyboardType = .numberPad
        textField.backgroundColor = .secondarySystemBackground
        textField.containerRadius = Constants.radius2
        textField.setColor(primary: .black, secondary: .secondaryLabel)
        textField.leadingAssistiveLabel.text = "옳바른 형식: 010 5555 5555 (하이픈 공백 없이)"
        textField.setLeadingAssistiveLabelColor(.black, for: .normal)
        textField.setLeadingAssistiveLabelColor(.black, for: .editing)
        textField.rx
            .text
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map({ text -> String in
                let countryCode = "+82"
                let text = text ?? ""
                let phone = "\(countryCode)\(text)"
                return phone
            })
            .map({ text -> Bool in
                let value = text
                let range = NSRange(location: 0, length: value.utf16.count)
                let result = self.regex.firstMatch(in: value, range: range)
                return (result != nil)
            })
            .subscribe(onNext: { [unowned self] value in
                self.activateConfirmButton(value)
            })
            .disposed(by: disposeBag)
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
        subscribeSmsViewModel()
    }

    override func viewDidLayoutSubviews() {
        phoneTextField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    deinit {
        log.info("deinit SmsViewController...")
        SwinjectStoryboard.defaultContainer.resetObjectScope(.smsScope)
    }

    private func configureSubviews() {
        view.addSubview(backButton)
        view.addSubview(smsLabel)
        view.addSubview(smsLabel2)
        view.addSubview(phoneTextField)
        view.addSubview(confirmButton)
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

    private func subscribeSmsViewModel() {
        smsViewModel?
            .toast
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        smsViewModel?
            .loading
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] boolean in
                showLoading(boolean)
            })
            .disposed(by: disposeBag)

        smsViewModel?
            .smsConfirm
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] verification in
                log.info("smsViewModel")
                presentSmsConfirmView(verification: verification)
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

    private func showLoading(_ flag: Bool) {
        spinnerView.visible(flag)
    }

    private func presentSmsConfirmView(verification: VerificationDTO) {
        log.info("smsConfirm")
        let storyboard = UIStoryboard(name: "Sms", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "SmsConfirmViewController") as! SmsConfirmViewController
        vc.modalPresentationStyle = .fullScreen
        vc.setVerification(verification)
        present(vc, animated: false)
    }

    @objc private func didTapConfirmButton() {
        let text = phoneTextField.text ?? ""
        let countryCode = "+82"
        let phone = "\(countryCode)\(text)"
        let range = NSRange(location: 0, length: phone.utf16.count)
        let result = regex.firstMatch(in: phone, range: range)

        if (result != nil) {
            smsViewModel?.issueSms(phone: phone)
            return
        }
        toast(message: "전화번호가 옳바르지 않습니다.")
    }

    @objc private func didTapBackButton() {
        smsViewModel?.signOut()
        replace(storyboard: "Main", withIdentifier: "LoginViewController")
    }
}
