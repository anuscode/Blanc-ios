import UIKit
import FirebaseAuth
import RxSwift

enum View {
    case LOGIN, MAIN, REGISTRATION, SMS
}

class InitPagerViewController: UIPageViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    internal var session: Session?

    internal var userService: UserService?

    lazy private var gradient: GradientView = {
        let alpha0 = UIColor.tinderPink
        let alpha1 = UIColor.bumble1
        let gradient = GradientView(
            colors: [alpha0, alpha1],
            locations: [0.0, 2],
            startPoint: CGPoint(x: 1, y: 0),
            endPoint: CGPoint(x: 0, y: 1)
        )
        return gradient
    }()

    private lazy var firstViewController: UIViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InitFirstViewController")
        return vc
    }()

    private lazy var secondViewController: UIViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InitSecondViewController")
        return vc
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initRoute()
        setViewControllers([firstViewController], direction: .forward, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.setViewControllers([self.secondViewController], direction: .reverse, animated: true)
        }
    }

    deinit {
        log.info("deinit init pager view controller..")
    }

    private func configureSubviews() {
        view.addSubview(gradient)
    }

    private func configureConstraints() {
        gradient.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func initRoute() {
        route()
            .observeOn(MainScheduler.instance)
            .flatMap { view -> Single<View> in
                self.delay(1.5).map({ view })
            }
            .subscribe(onSuccess: { view in
                switch view {
                case .MAIN:
                    self.replace(storyboard: "Main",
                        withIdentifier: "MainTabBarController")
                case .LOGIN:
                    self.replace(storyboard: "Main",
                        withIdentifier: "LoginViewController")
                case .REGISTRATION:
                    self.replace(storyboard: "Registration",
                        withIdentifier: "RegistrationNavigationViewController")
                case .SMS:
                    self.replace(storyboard: "Sms",
                        withIdentifier: "SmsViewController")
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func route() -> Single<View> {
        let subject: ReplaySubject<View> = ReplaySubject.create(bufferSize: 1)
        guard let userService = userService,
              let uid = auth.currentUser?.uid else {
            subject.onNext(View.LOGIN)
            return subject.take(1).asSingle()
        }
        userService
            .isRegistered(uid: uid)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { isRegistered in
                switch isRegistered {
                case true:
                    self.route(subject)
                case false:
                    subject.onNext(View.SMS)
                }
            }, onError: { err in
                log.error(err)
                self.toast(message: "유저 가입정보를 가져오는데 실패 하였습니다.")
            })
            .disposed(by: disposeBag)

        return subject.take(1).asSingle()
    }

    private func route(_ subject: ReplaySubject<View>) {
        session?
            .generate()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onSuccess: { user in
                let available = self.session?.user?.available
                switch available {
                case true:
                    subject.onNext(View.MAIN)
                default:
                    subject.onNext(View.REGISTRATION)
                }
            }, onError: { err in
                log.error(err)
                self.replace(withIdentifier: "LoginViewController")
                self.toast(message: "세션 정보를 가져오는데 실패 하였습니다.")
            })
            .disposed(by: disposeBag)
    }

    private func delay(_ seconds: Double) -> Single<Void> {
        let observable: ReplaySubject = ReplaySubject<Void>.create(bufferSize: 1)
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            observable.onNext(Void())
        }
        return observable.take(1).asSingle()
    }
}
