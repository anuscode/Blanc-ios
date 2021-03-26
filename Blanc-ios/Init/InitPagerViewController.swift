import UIKit
import FirebaseAuth
import RxSwift

class InitPagerViewController: UIPageViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    private let auth: Auth = Auth.auth()

    internal var session: Session?

    internal var userService: UserService?

    internal var navigation: Navigation?

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
        navigation?
            .next()
            .observeOn(MainScheduler.instance)
            .delay(1.5, scheduler: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [unowned self] next in
                log.info(next)
                switch next {
                case .MAIN:
                    replace(storyboard: "Main", withIdentifier: "MainTabBarController")
                case .LOGIN:
                    replace(storyboard: "Main", withIdentifier: "LoginViewController")
                case .REGISTRATION:
                    replace(storyboard: "Registration", withIdentifier: "RegistrationNavigationViewController")
                case .SMS:
                    replace(storyboard: "Sms", withIdentifier: "SmsViewController")
                case .LOCATION:
                    let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
                    let controller = storyboard.instantiateViewController(
                        withIdentifier: "LocationAuthorizationViewController"
                    ) as! LocationAuthorizationViewController
                    controller.modalPresentationStyle = .fullScreen
                    present(controller, animated: true, completion: nil)
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }
}
