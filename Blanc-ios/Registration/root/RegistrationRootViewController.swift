import Foundation
import UIKit
import RxSwift


class RegistrationRootViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    internal var registrationViewModel: RegistrationViewModel?

    lazy private var starFallView: StarFallView = {
        let view = StarFallView()
        return view
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        configureConstraints()
        subscribeViewModel()
    }

    func configureSubviews() {
        view.addSubview(starFallView)
    }

    func configureConstraints() {
        starFallView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func subscribeViewModel() {
        registrationViewModel?
            .user
            .take(1)
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { user in
                let status = user.status
                switch (status) {
                case .OPENED:
                    self.stackNicknameView()
                case .PENDING, .REJECTED, .BLOCKED:
                    self.stackPendingView()
                default:
                    log.error("Something wrong..")
                }
            }, onError: { err in
                log.error(err)
            })
            .disposed(by: disposeBag)
    }

    private func stackNicknameView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationNicknameViewController", animated: false)
    }

    private func stackPendingView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.stackAfterClear(identifier: "RegistrationPendingViewController", animated: false)
    }
}
