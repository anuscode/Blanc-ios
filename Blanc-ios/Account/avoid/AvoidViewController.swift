import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Shimmer
import Lottie
import CoreLocation


class AvoidViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    internal var avoidViewModel: AvoidViewModel?

    lazy private var locationImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "shield.slash")
        imageView.image = image
        imageView.tintColor = .white
        return imageView
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.textColor = .white
        label.text = "지인을 만나지 마세요."
        return label
    }()

    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.text = "블랑은 사용자의 연락처를 수집하고\n한쪽만 등록해도 서로 만날 수 없게 하는\n서비스를 제공하고 있습니다.\n\n지인 피하기 기능을 사용하고 싶은 경우\n연락처 수집 권한에 동의해 주세요."
        label.textAlignment = .center
        label.numberOfLines = 7
        return label
    }()

    lazy private var saveButton: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.visible(false)

        let label = UILabel()
        label.text = "저장"
        label.textColor = .tinderPink
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapSaveButton))
        return view
    }()

    lazy private var acceptButton: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true

        let label = UILabel()
        label.text = "예, 동의합니다."
        label.textColor = .tinderPink
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapAcceptButton))
        return view
    }()

    lazy private var declineButton: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true

        let label = UILabel()
        label.text = "취소"
        label.textColor = .tinderPink
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        ripple.activate(to: view)
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapDeclineButton))
        return view
    }()

    lazy private var loadingView: Spinner = {
        let view = Spinner()
        view.visible(false)
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .tinderPink
        navigationItem.backBarButtonItem = UIBarButtonItem.back
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.setValue(false, forKey: "hidesShadow")
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeAvoidViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        log.info("deinit home view controller..")
    }

    private func configureSubviews() {
        view.addSubview(locationImageView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(saveButton)
        view.addSubview(acceptButton)
        view.addSubview(declineButton)
        view.addSubview(loadingView)
    }

    private func configureConstraints() {
        locationImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.7)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(150)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(locationImageView.snp.bottom).offset(40)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }

        saveButton.snp.makeConstraints { make in
            make.width.equalTo(250)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(declineButton.snp.top).inset(-10)
        }

        acceptButton.snp.makeConstraints { make in
            make.width.equalTo(250)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(declineButton.snp.top).inset(-10)
        }

        declineButton.snp.makeConstraints { make in
            make.width.equalTo(250)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
    }

    private func subscribeAvoidViewModel() {
        avoidViewModel?
            .contacts
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] contacts in
                titleLabel.text = "\(contacts.count)개의 연락처 발견"
                saveButton.visible(true)
                acceptButton.visible(false)
            })
            .disposed(by: disposeBag)

        avoidViewModel?
            .toast
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] message in
                toast(message: message)
            })
            .disposed(by: disposeBag)

        avoidViewModel?
            .dismiss
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] _ in
                dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        avoidViewModel?
            .loading
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] isVisible in
                loadingView.visible(isVisible)
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapSaveButton() {
        avoidViewModel?.updateUserContacts()
    }

    @objc private func didTapAcceptButton() {
        avoidViewModel?.populate()
    }

    @objc private func didTapDeclineButton() {
        dismiss(animated: true)
    }
}