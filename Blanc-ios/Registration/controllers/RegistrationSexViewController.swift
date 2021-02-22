import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationSexViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
        progress.progressTintColor = .black
        progress.progress = 2 / RConfig.progressCount
        return progress
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = UIFont.boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    private lazy var male: UIView = {
        let view = UIView()
        view.layer.cornerRadius = RConfig.cornerRadius
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor

        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .light)
        label.text = "남자"

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        view.addSubview(checkMale)
        checkMale.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapMaleButton))
        return view
    }()

    private lazy var checkMale: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "checkmark")
        view.image?.withTintColor(.systemBlue)
        view.visible(false)
        return view
    }()

    private lazy var female: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor

        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .light)
        label.text = "여자"

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        view.addSubview(checkFemale)
        checkFemale.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapFemaleButton))
        return view
    }()

    private lazy var checkFemale: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "checkmark")
        view.image?.withTintColor(.systemBlue)
        view.visible(false)
        return view
    }()

    private let noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 성별은 추후 변경이 불가 합니다."
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

    lazy private var backButton: BackButton = {
        let button = BackButton()
        button.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapBackButton))
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .bumble1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

        male.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(RConfig.cellHeight)
        }

        female.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(male.snp.bottom).inset(-10)
            make.height.equalTo(RConfig.cellHeight)
        }

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(female.snp.bottom).offset(RConfig.noticeTopMargin)
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(RConfig.nextTrailingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.nextBottomMargin)
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.backLeadingMargin)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(RConfig.backBottomMargin)
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?.observe()
                .take(1)
                .subscribe(onNext: { [self] user in
                    self.user = user
                    update()
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func configureSubviews() {
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(male)
        view.addSubview(female)
        view.addSubview(noticeLabel)
        view.addSubview(nextButton)
        view.addSubview(backButton)
    }

    private func update() {
        if (user?.sex == Sex.MALE) {
            didTapMaleButton()
        } else if (user?.sex == Sex.FEMALE) {
            didTapFemaleButton()
        }
    }

    @objc private func didTapMaleButton() {
        male.layer.borderColor = UIColor.systemBlue.cgColor
        female.layer.borderColor = UIColor.white.cgColor
        checkMale.visible(true)
        checkFemale.visible(false)
        user?.sex = Sex.MALE
    }

    @objc private func didTapFemaleButton() {
        female.layer.borderColor = UIColor.systemBlue.cgColor
        male.layer.borderColor = UIColor.white.cgColor
        checkFemale.visible(true)
        checkMale.visible(false)
        user?.sex = Sex.FEMALE
    }

    @objc private func didTapNextButton() {
        if (user?.sex == nil) {
            toast(message: "성별이 입력 되지 않았습니다.")
            return
        }
        presentNextView()
    }

    @objc private func didTapBackButton() {
        presentBackView()
    }

    private func presentNextView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationBirthdayViewController")
    }

    private func presentBackView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationNicknameViewController", animated: false)
    }
}