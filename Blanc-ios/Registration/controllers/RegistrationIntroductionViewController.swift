import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationIntroductionViewController: UIViewController {

    private var disposeBag: DisposeBag? = DisposeBag()

    private let ripple: Ripple = Ripple()

    private var user: UserDTO?

    internal weak var registrationViewModel: RegistrationViewModel?

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .secondarySystemBackground
        progress.progressTintColor = .black
        progress.progress = 12 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "자기 소개"
        label.font = .boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var textFieldSubjectLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        label.text = "자기 소개를 입력하세요."
        return label
    }()

    lazy private var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        textView.keyboardType = .default
        textView.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.9)
        textView.layer.cornerRadius = RConfig.cornerRadius
        textView.tintColor = .systemBlue
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        let placeholder = UILabel()
        placeholder.text = "자기 소개는 나중에 작성하셔도 됩니다."
        placeholder.font = .systemFont(ofSize: 16)
        placeholder.textColor = .systemGray

        textView.addSubview(placeholder)
        placeholder.snp.makeConstraints { make in
            make.leading.equalTo(textView.snp.leading).inset(20)
            make.top.equalTo(textView.snp.top).inset(20)
        }
        textView.rx
            .text
            .observeOn(MainScheduler.asyncInstance)
            .map({ text in text.isEmpty() })
            .subscribe(onNext: placeholder.visible)
            .disposed(by: disposeBag!)

        return textView
    }()

    lazy private var keyboardClearView: UIView = {
        let view = UIView()
        view.visible(false)
        view.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.closeKeyboard()
            })
            .disposed(by: disposeBag!)
        return view
    }()

    lazy private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "자기소개는 스킵 후 나중에 작성 하셔도 됩니다."
        label.font = .systemFont(ofSize: RConfig.noticeSize)
        label.numberOfLines = 2;
        label.textColor = .black
        return label
    }()

    lazy private var nextButton: NextButton = {
        let button = NextButton()
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapNextButton))
        return button
    }()

    lazy private var backButton: BackButton = {
        let button = BackButton()
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapBackButton))
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)

        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = nil
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(textFieldSubjectLabel)
        view.addSubview(noticeLabel)
        view.addSubview(keyboardClearView)
        view.addSubview(textView)
        view.addSubview(backButton)
        view.addSubview(nextButton)
    }

    private func configureConstraints() {

        starFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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

        textFieldSubjectLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
        }

        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(textFieldSubjectLabel.snp.bottom).offset(10)
            make.height.equalTo(300)
        }

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(textView.snp.bottom).offset(RConfig.noticeTopMargin)
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.nextBottomMargin)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.backLeadingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.backBottomMargin)
        }

        keyboardClearView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?
            .observe()
            .take(1)
            .subscribe(onNext: { user in
                self.user = user
                self.update()
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag!)
    }

    private func update() {
        textView.text = user?.introduction
    }

    @objc private func didTapNextButton() {
        user?.introduction = textView.text
        next()
    }

    @objc private func didTapBackButton() {
        user?.introduction = textView.text
        back()
    }

    private func next() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationCharmViewController")
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationBloodTypeViewController", animated: false)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            nextButton.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(keyboardHeight + 20)
            }
            backButton.snp.remakeConstraints { make in
                make.leading.equalToSuperview().inset(RConfig.backLeadingMargin)
                make.bottom.equalTo(view.safeAreaLayoutGuide).inset(keyboardHeight + 20)
            }
        }
        keyboardClearView.visible(true)
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        nextButton.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.nextBottomMargin)
        }
        backButton.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.backLeadingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.backBottomMargin)
        }
        keyboardClearView.visible(false)
    }

    @objc private func closeKeyboard() {
        textView.endEditing(true)
    }
}