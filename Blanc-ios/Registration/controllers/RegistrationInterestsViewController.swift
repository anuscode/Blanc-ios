import AMShimmer
import FirebaseAuth
import Foundation
import UIKit
import RxSwift
import TTGTagCollectionView
import SwinjectStoryboard


class RegistrationInterestsViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    var registrationViewModel: RegistrationViewModel?

    private var user: UserDTO?

    lazy private var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = .white
        progress.progressTintColor = .black
        progress.progress = 14 / RConfig.progressCount
        return progress
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "관심사"
        label.font = UIFont.boldSystemFont(ofSize: RConfig.titleSize)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var collectionBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        return view
    }()

    lazy private var collectionView: TTGTextTagCollectionView = {
        let collectionView = TTGTextTagCollectionView()
        collectionView.horizontalSpacing = 5
        collectionView.verticalSpacing = 5
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.addTags(UserGlobal.interests, with: config)
        return collectionView
    }()

    lazy private var config: TTGTextTagConfig = {
        let config = TTGTextTagConfig()
        config.backgroundColor = .secondarySystemBackground
        config.cornerRadius = 5
        config.textColor = .black
        config.textFont = UIFont.systemFont(ofSize: 16)
        config.borderColor = .secondarySystemBackground
        config.shadowOpacity = 0
        config.selectedBackgroundColor = .bumble0
        config.selectedCornerRadius = 5
        config.selectedTextColor = .black
        config.exactHeight = 36
        config.extraSpace = CGSize(width: 20, height: 0)
        return config
    }()

    lazy private var noticeLabel: UILabel = {
        let label = UILabel()
        label.text = "1. 최소 3개 이상 선택 하세요."
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

        collectionBackgroundView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(400)
        }

        noticeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(RConfig.horizontalMargin)
            make.trailing.equalToSuperview().inset(RConfig.horizontalMargin)
            make.top.equalTo(collectionBackgroundView.snp.bottom).offset(RConfig.noticeTopMargin)
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
                .subscribe(onNext: { [unowned self] user in
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
        view.addSubview(collectionBackgroundView)
        view.addSubview(noticeLabel)
        view.addSubview(nextButton)
        view.addSubview(backButton)
    }

    private func update() {
        guard user?.interestIds != nil else {
            return
        }
        for index in user!.interestIds! {
            collectionView.setTagAt(UInt(index), selected: true)
        }
    }

    @objc private func didTapNextButton() {
        if (user?.interestIds?.count ?? 0 < 3) {
            toast(message: "관심사는 최소 3개 이상 요구 됩니다.")
            return
        }

        registrationViewModel?.updateUserProfile(onSuccess: {
            DispatchQueue.main.async {
                self.next()
            }
        }, onError: {
            self.toast(message: "유저 프로필 업데이트 중 에러가 발생 하였습니다.")
        })
    }

    @objc private func didTapBackButton() {
        back()
    }

    private func next() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationImageViewController")
    }

    private func back() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationIdealTypeViewController", animated: false)
    }
}

extension RegistrationInterestsViewController: TTGTextTagCollectionViewDelegate {
    public func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!,
                                      didTapTag tagText: String!,
                                      at index: UInt,
                                      selected: Bool,
                                      tagConfig config: TTGTextTagConfig!) {
        if selected {
            user?.interestIds?.append(Int(index))
        } else {
            user?.interestIds = user?.interestIds?.filter({ $0 != index })
        }
    }
}