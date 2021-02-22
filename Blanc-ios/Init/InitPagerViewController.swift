import UIKit
import FirebaseAuth
import RxSwift

enum View {
    case LOGIN, MAIN, REGISTRATION, SMS
}

class InitPagerViewController: UIPageViewController {

    let disposeBag: DisposeBag = DisposeBag()

    let auth: Auth = Auth.auth()

    var session: Session?

    var userService: UserService?

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
        setViewControllers([firstViewController], direction: .forward, animated: true) { _ in
            self.subscribeRoute()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.setViewControllers([self.secondViewController], direction: .reverse, animated: true)
        }
    }

    deinit {
        log.info("deinit InitPagerViewController..")
    }

    private func configureSubviews() {
        view.addSubview(gradient)
    }

    private func configureConstraints() {
        gradient.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribeRoute() {
        route()
                .observeOn(MainScheduler.instance)
                .flatMap { view -> Single<View> in
                    self.delay(2.3).map({ view })
                }
                .subscribe(onSuccess: { [unowned self] view in
                    switch view {
                    case .MAIN:
                        replace(storyboard: "Main",
                                withIdentifier: "MainTabBarController")
                    case .LOGIN:
                        replace(storyboard: "Main",
                                withIdentifier: "LoginViewController")
                    case .REGISTRATION:
                        replace(storyboard: "Registration",
                                withIdentifier: "RegistrationNavigationViewController")
                    case .SMS:
                        replace(storyboard: "Sms",
                                withIdentifier: "SmsViewController")
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func route() -> Single<View> {
        let subject: ReplaySubject<View> = ReplaySubject.create(bufferSize: 1)
        let uid = auth.currentUser?.uid

        if (uid == nil) {
            subject.onNext(View.LOGIN)
            return subject.take(1).asSingle()
        }

        userService?.isRegistered(uid: uid)
                .subscribe(onSuccess: { [self] isExists in
                    if (!isExists) {
                        subject.onNext(View.SMS)
                        return
                    }
                    routeBySession(subject)
                }, onError: { [self] err in
                    log.error(err)
                    toast(message: "유저 가입정보를 가져오는데 실패 하였습니다.")
                })
                .disposed(by: disposeBag)

        return subject.take(1).asSingle()
    }

    private func routeBySession(_ subject: ReplaySubject<View>) {
        session?.generate()
                .subscribe(onSuccess: { [self] user in
                    if (session?.user?.available == true) {
                        subject.onNext(View.MAIN)
                    } else {
                        subject.onNext(View.REGISTRATION)
                    }
                }, onError: { [self] err in
                    log.error(err)
                    replace(withIdentifier: "LoginViewController")
                    toast(message: "세션 정보를 가져오는데 실패 하였습니다.")
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