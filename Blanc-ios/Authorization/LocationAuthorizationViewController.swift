import UIKit
import Moya
import RxSwift
import SwinjectStoryboard
import FSPagerView
import Shimmer
import Lottie
import CoreLocation


class LocationAuthorizationViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let ripple: Ripple = Ripple()

    private var manager: CLLocationManager = CLLocationManager()

    internal var navigation: Navigation?

    lazy private var locationImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "location.viewfinder")
        imageView.image = image
        imageView.tintColor = .white
        return imageView
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.textColor = .white
        label.text = "어디 계세요 고객님?"
        return label
    }()

    lazy private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.text = "블랑은 사용자의 위치정보를 기반으로\n사람들을 추천해 주는 어플리케이션 입니다.\n\n원활한 서비스를 위해 위치정보 수집을 동의 해주세요."
        label.textAlignment = .center
        label.numberOfLines = 5
        return label
    }()

    lazy private var button: UIView = {
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
        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapButton))
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
        subscribeLocationAuthorizationChanges()
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
        view.addSubview(button)
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

        button.snp.makeConstraints { make in
            make.width.equalTo(250)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
    }

    private func subscribeLocationAuthorizationChanges() {
        manager.rx
            .didChangeAuthorization
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _, status in
                switch status {
                case .denied, .restricted, .notDetermined:
                    toast(message: "해당 앱은 위치정보를 필수로 요구 합니다.")
                case .authorizedAlways, .authorizedWhenInUse:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [unowned self] in
                        next()
                    }
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    @objc private func didTapButton() {
        let authorization = manager.authorizationStatus
        if (authorization == .denied || authorization == .restricted) {
            toast(message: "위치 설정은 필수 값 입니다.\n설정 -> 블랑 -> 위치정보 동의 과정을 통해\n권한을 획득 할 수 있습니다.", seconds: 3)
        }
        if (authorization == .authorizedAlways || authorization == .authorizedWhenInUse) {
            next()
            return
        }
        manager.requestAlwaysAuthorization()
    }

    private func next() {
        let window = UIApplication.shared.windows.first

        navigation?
            .next()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self] next in
                switch next {
                case .MAIN:
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
                    vc.modalPresentationStyle = modalPresentationStyle
                    present(vc, animated: true)
                case .LOGIN:
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                    vc.modalPresentationStyle = modalPresentationStyle
                    present(vc, animated: true)
                case .REGISTRATION:
                    let storyboard = UIStoryboard(name: "Registration", bundle: nil)
                    let vc = storyboard.instantiateViewController(
                        withIdentifier: "RegistrationNavigationViewController")
                    vc.modalPresentationStyle = modalPresentationStyle
                    present(vc, animated: true)
                case .SMS:
                    let storyboard = UIStoryboard(name: "Sms", bundle: nil)
                    let vc = storyboard.instantiateViewController(
                        withIdentifier: "SmsViewController")
                    vc.modalPresentationStyle = modalPresentationStyle
                    present(vc, animated: true)
                case .LOCATION:
                    let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
                    let controller = storyboard.instantiateViewController(
                        withIdentifier: "LocationAuthorizationViewController") as! LocationAuthorizationViewController
                    controller.modalPresentationStyle = .fullScreen
                    present(controller, animated: true, completion: nil)
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}