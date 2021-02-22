import UIKit
import RxSwift

class MainTabBarController: UITabBarController {

    weak var mainTabBarViewModel: MainTabBarViewModel?

    private let disposeBag: DisposeBag = DisposeBag()

    // Foreground Notification Candidates..
    private let foreground: [PushType?] = [
        .POKE, .REQUEST, .COMMENT, .FAVORITE, .MATCHED, .THUMB_UP,
        .OPENED, .LOG_OUT, .APPROVAL, .LOOK_UP, .STAR_RATING
    ]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeBroadcast()
        subscribeMainTabBarViewModel()
    }

    private func subscribeBroadcast() {
        Broadcast.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { push in
                    if (self.isForegroundNotifiable(push)) {
                        self.notify(push)
                    }
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func subscribeMainTabBarViewModel() {
        mainTabBarViewModel?.observe()
                .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
                .observeOn(SerialDispatchQueueScheduler(qos: .default))
                .subscribe(onNext: { hasUnread in
                    self.setBadgeOnConversationTab(hasUnread)
                }, onError: { err in
                    log.error(err)
                })
                .disposed(by: disposeBag)
    }

    private func notify(_ push: PushDTO) {
        DispatchQueue.main.async {
            let window = UIApplication.shared.keyWindow!
            let notification = NotificationView(imageUrl: push.imageUrl, message: push.message)
            notification.insert(into: window)
            notification.show { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    notification.hide()
                }
            }
        }
    }

    private func setBadgeOnConversationTab(_ hasUnread: Bool) {
        DispatchQueue.main.async {
            if let tabBarItems = self.tabBar.items {
                let tabBarItem = tabBarItems[3]
                tabBarItem.badgeValue = hasUnread ? "●" : ""
                tabBarItem.badgeColor = .clear
                tabBarItem.setBadgeTextAttributes([
                    NSAttributedString.Key.foregroundColor: UIColor.systemPink
                ], for: .normal)
            }
        }
    }

    private func isForegroundNotifiable(_ push: PushDTO) -> Bool {
        foreground.contains(push.pushType)
    }
}
