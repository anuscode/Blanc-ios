import Firebase
import GoogleSignIn
import RxFirebase
import RxSwift
import UIKit
import Lottie

import FBSDKCoreKit
import FBSDKLoginKit

import KakaoSDKAuth
import RxKakaoSDKAuth
import KakaoSDKUser
import RxKakaoSDKUser


class LoginViewController: UIViewController {

    private var auth: Firebase.Auth = Firebase.Auth.auth()

    private var disposeBag: DisposeBag = DisposeBag()

    private var ripple = Ripple()

    private let fireworkController = ClassicFireworkController()

    var locationService: LocationService?

    var userService: UserService?

    var session: Session?

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

    lazy private var secondaryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "돈, 명예, 권력, 사랑\n그중에 으뜸은 사랑이더라."
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.numberOfLines = 2;
        label.textColor = .lightBlack
        return label
    }()

    lazy private var lottieView: AnimationView = {
        let animationView = AnimationView()
        animationView.animation = Animation.named("intro")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        return animationView
    }()

    lazy private var progressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()

    lazy private var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 15
        view.visible(false)
        view.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
        }
        return view
    }()

    lazy private var googleLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Google 계정으로 로그인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.backgroundColor = .white
        button.setTitleColor(.darkText, for: .normal)
        let image = UIImage(named: "ic_google")
        let resized = image?.resize(targetSize: CGSize(width: 25, height: 25))
        button.setImage(resized, for: .normal)
        button.addTarget(self, action: #selector(didTapGoogleButton), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    lazy private var facebookLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Facebook 계정으로 로그인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.backgroundColor = .faceBook
        button.setTitleColor(.white, for: .normal)
        let image = UIImage(named: "ic_facebook")
        let resized = image?.resize(targetSize: CGSize(width: 25, height: 25))
        button.setImage(resized, for: .normal)
        button.addTarget(self, action: #selector(didTapFacebookButton), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    lazy private var kakaoLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("KakaoTalk 계정으로 로그인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.backgroundColor = .kakaoTalk
        button.setTitleColor(.kakaoBrown, for: .normal)
        let image = UIImage(named: "ic_kakao")
        let resized = image?.resize(targetSize: CGSize(width: 25, height: 25))
        button.setImage(resized, for: .normal)
        button.addTarget(self, action: #selector(didTapKakaoButton), for: .touchUpInside)
        ripple.activate(to: button)
        return button
    }()

    lazy private var snsWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "SNS 계정에는 그 어떤 내용도 게시되지 않으며,\n회원님의 정보 또한 절대 공개 되지 않습니다."
        label.font = .systemFont(ofSize: 10, weight: .light)
        label.textAlignment = .center
        label.numberOfLines = 2;
        label.textColor = .lightBlack
        return label
    }()

    lazy private var findAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "계정 찾기"
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.numberOfLines = 1;
        label.textColor = .black
        label.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapFindAccountLabel))
        return label
    }()

    lazy private var findAccountUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = .lightBlack
        return view
    }()

    lazy private var versionLabel: UILabel = {
        let label = UILabel()
        label.text = "powered by Ground • v1.0.0"
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.numberOfLines = 1;
        label.textColor = .black
        return label
    }()

    lazy private var host: UIView = {
        let size = UIScreen.main.bounds.size
        let host = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        host.layer.addSublayer(particlesLayer)
        host.layer.masksToBounds = true
        particlesLayer.emitterCells = [cell1, cell2, cell3]
        return host
    }()

    lazy private var particlesLayer: CAEmitterLayer = {
        let particlesLayer = CAEmitterLayer()
        let size = UIScreen.main.bounds.size
        particlesLayer.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        particlesLayer.backgroundColor = UIColor.clear.cgColor
        particlesLayer.emitterShape = .point
        particlesLayer.emitterPosition = CGPoint(x: 50, y: 100)
        particlesLayer.emitterSize = size
        particlesLayer.emitterMode = .surface
        particlesLayer.renderMode = .oldestLast
        return particlesLayer
    }()

    lazy private var cell1: CAEmitterCell = {
        let image1 = UIImage(named: "Smoke")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 0.5
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor.systemPurple.cgColor
        return cell
    }()

    lazy private var cell2: CAEmitterCell = {
        let image1 = UIImage(named: "Smoke")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 1
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor.bumble1.cgColor
        return cell
    }()

    lazy private var cell3: CAEmitterCell = {
        let image1 = UIImage(named: "Smoke")?.cgImage
        let cell = CAEmitterCell()
        cell.contents = image1
        cell.name = "Snow"
        cell.birthRate = 0.5
        cell.lifetime = 20.0
        cell.velocity = 59.0
        cell.velocityRange = -15.0
        cell.xAcceleration = 5.0
        cell.yAcceleration = 40.0
        cell.emissionRange = 180.0 * (.pi / 180.0)
        cell.spin = -28.6 * (.pi / 180.0)
        cell.spinRange = 57.2 * (.pi / 180.0)
        cell.scale = 0.06
        cell.scaleRange = 0.3
        cell.color = UIColor(hexCode: "F82E69").cgColor
        return cell
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        locationService?.requestLocationAuthorization()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let length1 = googleLoginButton.top - secondaryTitleLabel.bottom
        let length2 = view.width
        let height = min(length1, length2)
        lottieView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(height)
            make.height.equalTo(height)
            make.bottom.equalTo(googleLoginButton.snp.top)
        }
    }

    deinit {
        log.info("deinit LoginViewController..")
    }

    private func configureSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(dot)
        view.addSubview(secondaryTitleLabel)
        view.addSubview(lottieView)
        view.addSubview(host)
        view.addSubview(progressView)
        view.addSubview(googleLoginButton)
        view.addSubview(facebookLoginButton)
        view.addSubview(kakaoLoginButton)
        view.addSubview(snsWarningLabel)
        view.addSubview(findAccountLabel)
        view.addSubview(findAccountUnderline)
        view.addSubview(versionLabel)
    }

    private func configureConstraints() {

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(kakaoLoginButton.snp.leading)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(30)
        }

        dot.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing)
            make.bottom.equalTo(titleLabel.snp.bottom)
        }

        secondaryTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(kakaoLoginButton.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom).inset(-5)
        }

        googleLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(Constants.largeButtonHeight)
            make.bottom.equalTo(facebookLoginButton.snp.top).inset(-7)
        }

        facebookLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(Constants.largeButtonHeight)
            make.bottom.equalTo(kakaoLoginButton.snp.top).inset(-7)
        }

        kakaoLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(Constants.largeButtonHeight)
            make.bottom.equalTo(snsWarningLabel.snp.top).inset(-20)
        }

        snsWarningLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(findAccountLabel.snp.top).inset(-10)
        }

        findAccountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(versionLabel.snp.top).inset(-10)
        }

        findAccountUnderline.snp.makeConstraints { make in
            make.top.equalTo(findAccountLabel.snp.bottom)
            make.leading.equalTo(findAccountLabel.snp.leading)
            make.trailing.equalTo(findAccountLabel.snp.trailing)
            make.height.equalTo(0.5)
        }

        versionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(10)
        }

        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(30)
        }

        googleLoginButton.setImageLeftTextCenter()
        facebookLoginButton.setImageLeftTextCenter()
        kakaoLoginButton.setImageLeftTextCenter()
    }

    @objc private func didTapGoogleButton() {
        fireworkController.addFireworks(count: 3, around: googleLoginButton)
        GIDSignIn.sharedInstance().signIn()
    }

    @objc private func didTapKakaoButton() {
        fireworkController.addFireworks(count: 3, around: kakaoLoginButton)
        signInWithKakaoCredential()
    }

    @objc private func didTapFacebookButton() {
        fireworkController.addFireworks(count: 3, around: kakaoLoginButton)
        signInWithFacebookCredential()
    }

    func signInWithCredential(_ credential: AuthCredential) {

        progressView.visible(true)
        progressLabel.text = "토큰 발급중.."

        auth.rx.signInAndRetrieveData(with: credential)
                .do(onNext: { [unowned self] authResult in
                    DispatchQueue.main.async {
                        progressLabel.text = "회원 정보 조회 중.."
                    }
                })
                .flatMap({ [unowned self] authDataResult -> Single<Bool> in
                    let uid = authDataResult.user.uid
                    return userService!.isRegistered(uid: uid)
                })
                .do(onNext: { [unowned self] authResult in
                    DispatchQueue.main.async {
                        progressLabel.text = "세션 정보 수립 중.."
                    }
                })
                .subscribe(onNext: { [unowned self] isExists in
                    if (isExists) {
                        log.info("Sign in with credential done. beginning login progress..")
                        login()
                    } else {
                        log.info("Sign in with credential done. beginning registration progress..")
                        replace(storyboard: "Sms", withIdentifier: "SmsViewController")
                    }
                }, onError: { [unowned self] err in
                    log.error(err)
                    toast(message: "소셜 로그인 정보를 받아오지 못했습니다.")
                })
                .disposed(by: disposeBag)
    }

    func signInWithFacebookCredential() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: self) { [unowned self] (result, error) in

            // 4
            // Check for error
            guard error == nil else {
                // Error occurred
                print(error!.localizedDescription)
                return
            }

            // 5
            // Check for cancel
            guard let result = result, !result.isCancelled else {
                print("User cancelled login")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            signInWithCredential(credential)
        }
    }

    func signInWithKakaoCredential() {
        guard KakaoSDKAuth.AuthApi.isKakaoTalkLoginAvailable() else {
            toast(message: "카카오톡이 미설치 이거나 미인증 상태 입니다.")
            return
        }

        guard userService != nil else {
            toast(message: "Dependencies absence..")
            return
        }

        KakaoSDKAuth.AuthApi.shared.rx.loginWithKakaoTalk()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(MainScheduler.instance)
                .do(onNext: { [unowned self] authResult in
                    progressView.visible(true)
                    progressLabel.text = "카카오 토큰 검증 중.."
                })
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap { (oauthToken) -> Single<CustomTokenDTO> in
                    let idToken = oauthToken.accessToken
                    return self.userService!.signInWithKakaoToken(idToken: idToken)
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { [unowned self] authResult in
                    progressLabel.text = "카카오 토큰으로 로그인 중.."
                })
                .flatMap { verifiedToken in
                    self.auth.rx.signIn(withCustomToken: verifiedToken.customToken)
                }
                .observeOn(MainScheduler.instance)
                .do(onNext: { [unowned self] authResult in
                    progressLabel.text = "회원 정보 조회 중.."
                })
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .flatMap({ [unowned self] authDataResult -> Single<Bool> in
                    let uid = authDataResult.user.uid
                    return userService!.isRegistered(uid: uid)
                })
                .observeOn(MainScheduler.instance)
                .do(onNext: { [unowned self] authResult in
                    progressLabel.text = "세션 정보 수립 중.."
                })
                .subscribe(onNext: { isExists in
                    if (isExists) {
                        log.info("Sign in with kakao credential done. beginning login progress..")
                        self.login()
                    } else {
                        log.info("Sign in with kakao credential done. beginning registration progress..")
                        self.replace(storyboard: "Sms", withIdentifier: "SmsViewController")
                    }
                }, onError: { error in
                    print(error)
                    self.progressView.visible(false)
                })
                .disposed(by: disposeBag)
    }

    private func login() {
        session?.generate()
                .subscribe(onSuccess: { [unowned self]_ in
                    if (session?.user?.available == true) {
                        replace(storyboard: "Main",
                                withIdentifier: "MainTabBarController")
                    } else {
                        replace(storyboard: "Registration",
                                withIdentifier: "RegistrationNavigationViewController")
                    }
                }, onError: { [unowned self] err in
                    log.error(err)
                    progressView.visible(false)
                    session?.signOut()
                })
                .disposed(by: disposeBag)
    }

    @objc private func didTapFindAccountLabel() {
        fireworkController.addFireworks(count: 2, around: findAccountLabel)
    }

}

extension LoginViewController: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if error != nil {
            log.error(error!)
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        let credential = GoogleAuthProvider.credential(
                withIDToken: authentication.idToken,
                accessToken: authentication.accessToken)
        signInWithCredential(credential)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        toast(message: "로그인 세션이 종료 되었습니다.")
    }
}
