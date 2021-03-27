import Foundation
import UIKit
import RxSwift
import SnapKit
import TTGTagCollectionView


class RegistrationPendingViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private var ripple = Ripple()

    internal var registrationViewModel: RegistrationViewModel!

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

    lazy private var unregisterLabel: UILabel = {
        let label = UILabel()
        label.text = "가입 취소"
        label.underline()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .darkSilverBlue
        label.isUserInteractionEnabled = true
        label.visible(true)
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(unregister))
        label.addGestureRecognizer(tapRecognizer)
        return label
    }()

    lazy private var secondaryTextLabel: UILabel = {
        let label = UILabel()
        label.text = "승인 시 메인 화면으로 자동 전환 됩니다."
        label.font = .systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 2;
        label.textColor = .black3
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
        button.setTitleColor(.black, for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.radius
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(didTapImageButton), for: .touchUpInside)
        button.visible(false)
        ripple.activate(to: button)
        return button
    }()

    lazy private var goBackFirstButton: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        let label = UILabel()
        label.text = "프로필 처음부터 다시 작성"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 18)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        view.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [unowned self] _ in
                let navigation = self.navigationController as! RegistrationNavigationViewController
                navigation.stackAfterClear(identifier: "RegistrationNicknameViewController", animated: true)
            })
            .disposed(by: disposeBag)
        ripple.activate(to: view)
        return view
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
        subscribeBackground()
    }

    deinit {
        log.info("deinit RegistrationPendingViewController..")
    }

    private func configureSubviews() {
        view.addSubview(starFallView)
        view.addSubview(titleLabel)
        view.addSubview(dot)
        view.addSubview(unregisterLabel)
        view.addSubview(secondaryTextLabel)
        view.addSubview(imageView)
        view.addSubview(noticeView)
        view.addSubview(imageButton)
        view.addSubview(goBackFirstButton)
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

        unregisterLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(20)
        }

        secondaryTextLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(-5)
            make.centerX.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.leading)
        }

        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
        }

        noticeView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }

        imageButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(30)
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(50)
            make.bottom.equalTo(goBackFirstButton.snp.top).inset(-10)
        }

        goBackFirstButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.leading.equalToSuperview().inset(30)
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?
            .user
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] user in
                update(user)
            })
            .disposed(by: disposeBag)
    }

    private func subscribeBroadcast() {
        Broadcast
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] push in
                if (push.isApproved()) {
                    parent?.replace(storyboard: "LaunchAnimation", withIdentifier: "LaunchPagerViewController")
                }
            })
            .disposed(by: disposeBag)
    }

    private func subscribeBackground() {
        Background
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] push in
                parent?.replace(storyboard: "LaunchAnimation", withIdentifier: "LaunchPagerViewController")
            })
            .disposed(by: disposeBag)
    }

    private func update(_ userDTO: UserDTO) {

        imageView.url(userDTO.getTempImageUrl(index: 0))

        if (userDTO.status == .BLOCKED) {
            secondaryTextLabel.text = "고객센터로 연락 바랍니다."
            progressTextLabel.text = "해당 계정은 이용 정지 되었습니다."
            progressTextLabel.textColor = .systemRed
            return
        }

        if (userDTO.status == .REJECTED) {
            progressTextLabel.text = "사진이 반려 되었습니다.\n수정 후 다시 이용 바랍니다."
            progressTextLabel.textColor = .systemRed
            imageButton.visible(true)
            return
        }

        if (userDTO.status == .PENDING) {
            progressTextLabel.text = "관리자의 프로필 검수 후\n가입이 완료 됩니다."
            progressTextLabel.textColor = .black
            return
        }
    }

    @objc private func didTapImageButton(sender: UITapGestureRecognizer) {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationImageViewController", animated: true)
    }

    @objc private func unregister(sender: UITapGestureRecognizer) {
        let unregisterAction = UIAlertAction(title: "가입 취소", style: .default) { [unowned self] (action) in
            registrationViewModel?.unregister(onSuccess: { [unowned self] in
                let isSignOut = Session.signOut()
                if (isSignOut) {
                    parent?.replace(storyboard: "LaunchAnimation", withIdentifier: "LaunchPagerViewController")
                } else {
                    toast(message: "로그아웃에 실패 하였습니다.")
                }
            }, onError: { [unowned self] in
                toast(message: "가입 취소가 정상적으로 완료되지 않았습니다..")
            })
        }
        let signOutAction = UIAlertAction(title: "LOG OUT", style: .default) { [unowned self] (action) in
            let isSignOut = Session.signOut()
            if (isSignOut) {
                parent?.replace(storyboard: "LaunchAnimation", withIdentifier: "LaunchPagerViewController")
            } else {
                toast(message: "로그아웃에 실패 하였습니다.")
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(unregisterAction)
        alertController.addAction(signOutAction)
        alertController.addAction(cancelAction)
        alertController.modalPresentationStyle = .popover

        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
                present(alertController, animated: true, completion: nil)
            }
        } else {
            present(alertController, animated: true, completion: nil)
        }
    }
}
