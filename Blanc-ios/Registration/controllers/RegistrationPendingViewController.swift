import Foundation
import UIKit
import RxSwift
import SnapKit
import TTGTagCollectionView


class RegistrationPendingViewController: UIViewController {

    var registrationViewModel: RegistrationViewModel?

    private let disposeBag: DisposeBag = DisposeBag()

    private var ripple = Ripple()

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "blanc"
        label.font = .boldSystemFont(ofSize: 35)
        label.textColor = .black
        return label
    }()

    lazy private var dot: UILabel = {
        let dot = UILabel()
        dot.text = "."
        dot.textColor = .bumble4
        dot.font = .boldSystemFont(ofSize: 40)
        return dot
    }()

    lazy private var secondaryTextLabel: UILabel = {
        let label = UILabel()
        label.text = "승인 시 메인 화면으로 자동 전환 됩니다."
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 2;
        label.textColor = .lightBlack
        return label
    }()

    lazy private var imageView: GradientCircleImageView = {
        let width = UIScreen.main.bounds.width
        let imageView = GradientCircleImageView(diameter: width / 3.5)
        return imageView
    }()

    lazy private var noticeView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.addSubview(progressTextLabel)
        progressTextLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(40)
            make.trailing.equalToSuperview().inset(40)
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
            make.center.equalToSuperview()
        }
        return view
    }()

    lazy private var progressTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 3
        label.textColor = .darkText
        label.alpha = 1
        label.font = .systemFont(ofSize: 20)
        return label
    }()

    lazy private var imageButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.setTitle("이미지 변경 하기", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.radius
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        button.visible(false)
        ripple.activate(to: button)
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
        subscribeBroadcast()
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(titleLabel)
        view.addSubview(dot)
        view.addSubview(secondaryTextLabel)
        view.addSubview(imageView)
        view.addSubview(noticeView)
        view.addSubview(imageButton)
    }

    private func configureConstraints() {

        starFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageButton.snp.leading)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
        }

        dot.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing)
            make.bottom.equalTo(titleLabel.snp.bottom)
        }

        secondaryTextLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.80)
        }

        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.9)
        }

        noticeView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }

        imageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?
            .observe()
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { user in
                self.update(user)
            }, onError: { err in
                self.toast(message: "알 수 없는 에러가 발생 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func subscribeBroadcast() {
        Broadcast
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { push in
                if (push.isApproval()) {
                    self.parent?.replace(storyboard: "Main", withIdentifier: "InitPagerViewController")
                }
            }, onError: { err in
                self.toast(message: "알 수 없는 에러가 발생 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func update(_ userDTO: UserDTO) {

        imageView.url(userDTO.getTempImageUrl(index: 0))

        if (userDTO.status == Status.BLOCKED) {
            secondaryTextLabel.text = "고객센터로 연락 바랍니다."
            progressTextLabel.text = "해당 계정은 이용 정지 되었습니다."
            progressTextLabel.textColor = .systemRed
            return
        }

        if (userDTO.status == Status.REJECTED) {
            progressTextLabel.text = "사진이 반려 되었습니다.\n수정 후 다시 이용 바랍니다."
            progressTextLabel.textColor = .systemRed
            imageButton.visible(true)
            return
        }

        if (userDTO.status == Status.PENDING) {
            progressTextLabel.text = "관리자의 프로필 검수 후\n가입이 완료 됩니다."
            return
        }
    }

    @objc private func didTapImageButton() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationImageViewController", animated: true)
    }
}
