import Foundation
import UIKit
import RxSwift


class RegistrationRootViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()

    var registrationViewModel: RegistrationViewModel?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .bumble1
        navigationItem.backBarButtonItem = UIBarButtonItem.back
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeViewModel()
    }

    private func subscribeViewModel() {
        registrationViewModel?.observe()
                .take(1)
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { user in
                    let status = user.status
                    if (status == .OPENED) {
                        DispatchQueue.main.async {
                            self.presentNicknameView()
                        }
                    } else if (status == .PENDING || status == .REJECTED || status == .BLOCKED) {
                        DispatchQueue.main.async {
                            self.presentPendingView()
                        }
                    } else {

                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func presentNicknameView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "RegistrationNicknameViewController", animated: false)
    }

    private func presentPendingView() {
        let navigation = navigationController as! RegistrationNavigationViewController
        navigation.present(identifier: "PendingViewController", animated: false)
    }
}
