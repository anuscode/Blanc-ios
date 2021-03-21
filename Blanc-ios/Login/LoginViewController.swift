import AuthenticationServices  // Apple login.
import CoreLocation
import CryptoKit
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

    private let manager = CLLocationManager()

    var userService: UserService?

    var session: Session?

    fileprivate var currentNonce: String?

    private var buttons: [UIView] {
        get {
            [appleLoginButton, facebookLoginButton, kakaoLoginButton]
        }
    }

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

    lazy private var appleLoginButton: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.black.cgColor
        view.backgroundColor = .white

        let label = UILabel()
        label.text = "Apple로 로그인"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "applelogo")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(25)
        }

        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapAppleButton))
        ripple.activate(to: view)
        return view
    }()


    lazy private var facebookLoginButton: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .faceBook

        let label = UILabel()
        label.text = "Facebook으로 로그인"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_facebook")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }

        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapFacebookButton))
        ripple.activate(to: view)
        return view
    }()

    lazy private var kakaoLoginButton: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .kakaoTalk

        let label = UILabel()
        label.text = "KakaoTalk으로 로그인"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .kakaoBrown
        label.textAlignment = .center

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_kakao")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }

        view.addTapGesture(numberOfTapsRequired: 1, target: self, action: #selector(didTapKakaoButton))
        ripple.activate(to: view)
        return view
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
        label.text = "presented by ground • v1.0.4"
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
        manager.requestAlwaysAuthorization()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let length1 = appleLoginButton.top - secondaryTitleLabel.bottom
        let length2 = view.width
        let height = min(length1, length2)
        lottieView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(height)
            make.height.equalTo(height)
            make.bottom.equalTo(appleLoginButton.snp.top)
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
        view.addSubview(facebookLoginButton)
        view.addSubview(kakaoLoginButton)
        view.addSubview(appleLoginButton)
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

        appleLoginButton.snp.makeConstraints { make in
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
    }

    @objc private func didTapAppleButton() {
        fireworkController.addFireworks(count: 3, around: appleLoginButton)
        startSignInWithAppleCredential()
    }

    @objc private func didTapFacebookButton() {
        fireworkController.addFireworks(count: 3, around: facebookLoginButton)
        signInWithFacebookCredential()
    }

    @objc private func didTapKakaoButton() {
        fireworkController.addFireworks(count: 3, around: kakaoLoginButton)
        signInWithKakaoCredential()
    }

    @objc private func didTapFindAccountLabel() {
        fireworkController.addFireworks(count: 2, around: findAccountLabel)
        toast(message: "구현 중 입니다. 다음 패치 때 이용 하세요.")
    }

    private func signInWithCredential(_ credential: AuthCredential) {

        enableLoginButtons(false)
        progressView.visible(true)
        progressLabel.text = "토큰 발급중.."

        auth.rx
            .signInAndRetrieveData(with: credential)
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
                progressView.visible(false)
                enableLoginButtons(true)
                toast(message: "해당 계정이 이미 존재 하거나 다른 이유로 로그인 할 수 없습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func signInWithFacebookCredential() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["email"], from: self) { [unowned self] (result, error) in
            guard error == nil else {
                log.error(error!.localizedDescription)
                return
            }
            guard let result = result, !result.isCancelled else {
                log.info("User cancelled login")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            signInWithCredential(credential)
        }
    }

    private func signInWithKakaoCredential() {
        guard let userService = userService else {
            toast(message: "Dependencies absence..")
            return
        }

        let loginWithKakao: () -> Observable<OAuthToken> = {
            if (UserApi.isKakaoTalkLoginAvailable()) {
                return UserApi.shared.rx.loginWithKakaoTalk()
            } else {
                return UserApi.shared.rx.loginWithKakaoAccount()
            }
        }

        loginWithKakao()
            .subscribeOn(MainScheduler.instance)
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] authResult in
                enableLoginButtons(false)
                progressView.visible(true)
                progressLabel.text = "카카오 토큰 검증 중.."
            })
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap { (oauthToken) -> Single<CustomTokenDTO> in
                let idToken = oauthToken.accessToken
                return userService.createCustomTokenWithKakao(idToken: idToken)
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] authResult in
                progressLabel.text = "카카오 토큰으로 로그인 중.."
            })
            .flatMap { [unowned self] verifiedToken in
                auth.rx.signIn(withCustomToken: verifiedToken.customToken)
            }
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] authResult in
                progressLabel.text = "회원 정보 조회 중.."
            })
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .flatMap({ authDataResult -> Single<Bool> in
                let uid = authDataResult.user.uid
                return userService.isRegistered(uid: uid)
            })
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] authResult in
                progressLabel.text = "세션 정보 수립 중.."
            })
            .subscribe(onNext: { [unowned self] isExists in
                if (isExists) {
                    log.info("Sign in with kakao credential done. beginning login progress..")
                    login()
                } else {
                    log.info("Sign in with kakao credential done. beginning registration progress..")
                    replace(storyboard: "Sms", withIdentifier: "SmsViewController")
                }
            }, onError: { error in
                log.error(error)
                self.enableLoginButtons(true)
                self.progressView.visible(false)
            })
            .disposed(by: disposeBag)
    }

    private func login() {
        session?.generate()
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [unowned self]_ in
                if (session?.user?.available == true) {
                    replace(storyboard: "Main", withIdentifier: "MainTabBarController")
                } else {
                    replace(storyboard: "Registration", withIdentifier: "RegistrationNavigationViewController")
                }
            }, onError: { [unowned self] err in
                log.error(err)
                progressView.visible(false)
                enableLoginButtons(true)
                Session.signOut()
            })
            .disposed(by: disposeBag)
    }

    private func enableLoginButtons(_ isEnable: Bool) {
        buttons.forEach({ $0.isUserInteractionEnabled = isEnable })
    }
}

extension LoginViewController: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            log.error(error)
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

extension LoginViewController: ASAuthorizationControllerDelegate,
    ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window!
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                log.error("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                log.error("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce)
            // Sign in with Firebase.
            self.signInWithCredential(credential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        log.error("Sign in with Apple errored: \(error)")
    }

    @available(iOS 13, *)
    func startSignInWithAppleCredential() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
