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


class NicknameViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let regex = try! NSRegularExpression(pattern: "^\\+82[\\s-]?(0?10)[\\s-]?[0-9]{3,4}[\\s-]?[0-9]{4}$")

    private let auth: Auth = Auth.auth()

    private let ripple: Ripple = Ripple()

    var verificationService: VerificationService?

    var profileViewModel: ProfileViewModel?

    var userDTO: UserDTO?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 2;
        label.textColor = .black
        return label
    }()

    private let nicknameTextField: MDCOutlinedTextField = {
        let textField = MDCOutlinedTextField()
        let rightImage = UIImageView(image: UIImage(systemName: "pencil.and.outline"))
        rightImage.image = rightImage.image?.withRenderingMode(.alwaysTemplate)

        textField.label.text = "닉네임을 입력 하세요."
        textField.trailingView = rightImage
        textField.trailingViewMode = .always
        textField.placeholder = "닉네임을 입력 하세요."
        textField.keyboardType = .default
        textField.backgroundColor = .secondarySystemBackground
        textField.containerRadius = FragmentConfig.textFieldCornerRadius
        textField.sizeToFit()
        textField.setColor(primary: .faceBook, secondary: .secondaryLabel)
        return textField
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 닉네임은 자신의 2번째 얼굴 입니다.\n2.불건전 한 닉네임 사용 시 제제를 받을 수 있습니다."
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 3;
        label.textColor = .secondaryLabel
        return label
    }()

    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = FragmentConfig.textFieldCornerRadius
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.visible(false)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.layer.add(FragmentConfig.transition, forKey: nil)
        addSubviews()
        nicknameTextField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)
        subscribeViewModel()
    }

    override func viewDidLayoutSubviews() {
        titleLabel.frame = CGRect(
                x: 25,
                y: 0 + FragmentConfig.verticalMargin,
                width: view.width - 50,
                height: FragmentConfig.titleHeight)

        nicknameTextField.frame = CGRect(
                x: 25,
                y: titleLabel.bottom + FragmentConfig.contentMarginTop,
                width: view.width - 50,
                height: 60)
        nicknameTextField.becomeFirstResponder()

        warningLabel.frame = CGRect(
                x: 25,
                y: nicknameTextField.bottom + FragmentConfig.warningTextMarginTop,
                width: view.width - 50,
                height: 35)

        confirmButton.frame = CGRect(
                x: 25,
                y: warningLabel.bottom + FragmentConfig.confirmButtonMarginTop,
                width: view.width - 50,
                height: FragmentConfig.confirmButtonHeight)

        ripple.activate(to: confirmButton)

        guard (parent?.view.snp.centerX != nil) else {
            return
        }

        view.snp.makeConstraints { make in
            make.top.equalTo(self.parent!.view.safeAreaLayoutGuide)
            make.bottom.equalTo(confirmButton.snp.bottom).inset(-FragmentConfig.verticalMargin)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalTo(self.parent!.view.snp.centerX)
        }
    }

    private func subscribeViewModel() {
        profileViewModel?.observe()
                .subscribe(onNext: { [unowned self] user in
                    userDTO = user
                    nicknameTextField.text = userDTO?.nickname
                    let value = userDTO?.nickname ?? ""
                    activateConfirmButton(!value.isEmpty)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(warningLabel)
        view.addSubview(confirmButton)
        view.addSubview(loadingView)
    }

    @objc private func didChangeTextField() {
        let value = nicknameTextField.text ?? ""
        activateConfirmButton(!value.isEmpty)
    }

    @objc private func didTapConfirmButton() {
        let value = nicknameTextField.text ?? ""
        guard (!value.isEmpty) else {
            toast(message: "닉네임은 필수 값 입니다.")
            log.info("nickname: empty value found..")
            return
        }
        userDTO?.nickname = value
        view.removeFromSuperview()
        log.info("nickname: \(value) confirmed..")
        profileViewModel?.update()
    }

    private func activateConfirmButton(_ isActivate: Bool) {
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        if (isActivate) {
            confirmButton.backgroundColor = .systemBlue
        } else {
            confirmButton.backgroundColor = .lightGray
        }
    }
}