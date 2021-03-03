import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationNicknameViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    var userDTO: UserDTO?

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
        progress.progressTintColor = .black
        progress.progress = 1 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = .boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        let view = UIView()
        view.backgroundColor = .systemBlue
        return label
    }()

    lazy private var underLine1: UIView = {
        let view = UIView()
        view.backgroundColor = .bumble1
        return view
    }()

    lazy private var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.addPadding(direction: .left, width: 15)
        textField.attributedPlaceholder = NSAttributedString(
                string: "닉네임을 입력 하세요.", attributes: [.foregroundColor: UIColor.deepGray]
        )
        textField.font = .systemFont(ofSize: 22, weight: .light)
        textField.keyboardType = .default
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = RConfig.cornerRadius
        textField.tintColor = .bumble3
        let rightView = UIView()
        textField.rightView = rightView
        textField.rightViewMode = .always
        return textField
    }()

    lazy private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 닉네임은 자신의 2번째 얼굴 입니다.\n2. 불건전 한 닉네임 사용 시 제제를 받을 수 있습니다."
        label.font = UIFont.systemFont(ofSize: RConfig.noticeSize)
        label.numberOfLines = 4;
        label.textColor = .black
        return label
    }()

    lazy private var nextButton: NextButton = {
        let button = NextButton()
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapNextButton))
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .bumble1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                name: UIResponder.keyboardWillShowNotification, object: nil
        )
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    private func configureConstraints() {

        progressView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(RConfig.progressTopMargin)
            make.height.equalTo(3)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(progressView.snp.bottom).offset(RConfig.titleTopMargin)
        }

        nicknameTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(RConfig.cellHeight)
        }

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(nicknameTextField.snp.bottom).offset(RConfig.noticeTopMargin)
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.nextBottomMargin).priority(500)
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?.observe()
                .take(1)
                .subscribe(onNext: { [self] user in
                    userDTO = user
                    update()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func configureSubviews() {
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(noticeLabel)
        view.addSubview(nextButton)
    }

    private func update() {
        nicknameTextField.text = userDTO?.nickname
    }

    @objc private func didTapNextButton() {
        let value = nicknameTextField.text ?? ""
        guard (!value.isEmpty) else {
            toast(message: "닉네임은 필수 값 입니다.")
            return
        }
        userDTO?.nickname = value
        presentNextView()
    }

    private func presentNextView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationSexViewController")
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        DispatchQueue.main.async { [self] in
            let screenHeight = UIScreen.main.bounds.height
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                let keyboardHeight = keyboardSize.height
                if (nextButton.frame.origin.y > screenHeight - keyboardHeight) {
                    nextButton.snp.makeConstraints { make in
                        make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
                        make.bottom.equalTo(view.safeAreaLayoutGuide).inset(15 + keyboardHeight)
                    }
                }
            }
        }
    }
}