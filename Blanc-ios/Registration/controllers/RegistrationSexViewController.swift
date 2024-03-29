import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import SwinjectStoryboard


class RegistrationSexViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    internal weak var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    lazy private var starFallView: StarFallView = {
        let view = StarFallView(layerTransparency: 0.5)
        return view
    }()

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .secondarySystemBackground
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
        view.backgroundColor = .secondarySystemBackground
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor

        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.text = "남자"

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        view.addSubview(maleCheckmark)
        maleCheckmark.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        view.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [unowned self] _ in
                self.user?.sex = .MALE
                self.registrationViewModel?.update()
            })
            .disposed(by: disposeBag)

        ripple.activate(to: view)
        return view
    }()

    private lazy var maleCheckmark: UIImageView = {
        let view = UIImageView()
        let image = UIImage(systemName: "checkmark")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        view.image = image
        view.visible(false)
        return view
    }()

    private lazy var female: UIView = {
        let view = UIView()
        view.layer.cornerRadius = RConfig.cornerRadius
        view.layer.masksToBounds = true
        view.backgroundColor = .secondarySystemBackground
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor

        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.text = "여자"

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        view.addSubview(femaleCheckmark)
        femaleCheckmark.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        view.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [unowned self] _ in
                self.user?.sex = .FEMALE
                self.registrationViewModel?.update()
            })
            .disposed(by: disposeBag)

        ripple.activate(to: view)
        return view
    }()

    private lazy var femaleCheckmark: UIImageView = {
        let view = UIImageView()
        let image = UIImage(systemName: "checkmark")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        view.image = image
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
        view.backgroundColor = .systemBlue
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        view.addSubview(male)
        view.addSubview(female)
        view.addSubview(noticeLabel)
        view.addSubview(nextButton)
        view.addSubview(backButton)
    }

    deinit {
        log.info("deinit registration sex view controller..")
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
        male.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
        female.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(male.snp.bottom).inset(-10)
            make.height.equalTo(60)
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
        registrationViewModel?
            .user
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] user in
                self.user = user

                let isMale = user.sex == .MALE
                male.layer.borderColor = isMale ? UIColor.systemBlue.cgColor : UIColor.white.cgColor
                maleCheckmark.visible(isMale)

                let isFemale = user.sex == .FEMALE
                female.layer.borderColor = isFemale ? UIColor.systemBlue.cgColor : UIColor.white.cgColor
                femaleCheckmark.visible(isFemale)
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapNextButton() {
        if (user?.sex == nil) {
            toast(message: "성별이 입력 되지 않았습니다.")
            return
        }
        next()
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RegistrationBirthdayViewController")
        navigationController?.pushViewController(vc, animated: true)
        if let index = navigationController?.viewControllers.firstIndex(of: self) {
            navigationController?.viewControllers.remove(at: index)
        }
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationNicknameViewController", animated: false)
    }
}