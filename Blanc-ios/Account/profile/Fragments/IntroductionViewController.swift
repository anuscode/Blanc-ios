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


class IntroductionViewController: UIViewController, UITextViewDelegate {

    private let disposeBag: DisposeBag = DisposeBag()

    private let regex = try! NSRegularExpression(pattern: "^\\+82[\\s-]?(0?10)[\\s-]?[0-9]{3,4}[\\s-]?[0-9]{4}$")

    private let auth: Auth = Auth.auth()

    private let ripple: Ripple = Ripple()

    var verificationService: VerificationService?

    var profileViewModel: ProfileViewModel?

    var userDTO: UserDTO?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "자기소개를 입력 하세요"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    private let introductionTextField: UITextView = {
        let textField = UITextView()
        textField.layer.cornerRadius = FragmentConfig.textFieldCornerRadius
        textField.layer.borderColor = UIColor.faceBook.cgColor
        textField.sizeToFit()
        textField.keyboardType = .default
        textField.backgroundColor = .secondarySystemBackground
        textField.sizeToFit()
        return textField
    }()

    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 정성들여 작성 한 자기소개는 인생샷 못지 않은 효과를 제공 합니다."
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
        button.backgroundColor = .bumble3
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
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        introductionTextField.delegate = self
        subscribeViewModel()
    }

    override func viewDidLayoutSubviews() {
        titleLabel.frame = CGRect(
                x: 25,
                y: 0 + FragmentConfig.verticalMargin,
                width: view.width - 50,
                height: FragmentConfig.titleHeight)

        introductionTextField.frame = CGRect(
                x: 25,
                y: titleLabel.bottom + FragmentConfig.contentMarginTop,
                width: view.width - 50,
                height: 180)
        introductionTextField.becomeFirstResponder()

        warningLabel.frame = CGRect(
                x: 25,
                y: introductionTextField.bottom + FragmentConfig.warningTextMarginTop,
                width: view.width - 50,
                height: 35)

        confirmButton.frame = CGRect(
                x: 25,
                y: warningLabel.bottom + 10,
                width: view.width - 50,
                height: FragmentConfig.confirmButtonHeight)

        ripple.activate(to: confirmButton)

        guard (parent?.view.snp.centerX != nil) else {
            return
        }

        view.snp.makeConstraints { make in
            make.top.equalTo(self.parent!.topLayoutGuide.snp.bottom).inset(-20)
            make.bottom.equalTo(confirmButton.snp.bottom).inset(-FragmentConfig.verticalMargin)
            make.width.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalTo(self.parent!.view.snp.centerX)
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        let value = textView.text ?? ""
        userDTO?.introduction = value
    }

    private func subscribeViewModel() {
        profileViewModel?.observe()
                .subscribe(onNext: { [unowned self] user in
                    userDTO = user
                    introductionTextField.text = userDTO?.introduction
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(introductionTextField)
        view.addSubview(warningLabel)
        view.addSubview(confirmButton)
        view.addSubview(loadingView)
    }

    @objc private func didTapConfirmButton() {
        view.removeFromSuperview()
        profileViewModel?.update()
    }
}