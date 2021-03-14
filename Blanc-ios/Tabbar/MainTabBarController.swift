import UIKit
import RxSwift

class MainTabBarController: UITabBarController {

    private var disposeBag: DisposeBag? = DisposeBag()

    internal weak var mainTabBarViewModel: MainTabBarViewModel?

    // Foreground Notification Candidates..
    private let candidates: [Event?] = [
        .POKE, .REQUEST, .COMMENT, .FAVORITE, .MATCHED, .THUMB_UP, .OPENED, .LOG_OUT, .LOOK_UP, .STAR_RATING
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = nil
    }

    private func subscribeBroadcast() {
        Broadcast
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: notify)
            .disposed(by: disposeBag!)
    }

    private func subscribeMainTabBarViewModel() {
        mainTabBarViewModel?
            .observe()
            .subscribeOn(SerialDispatchQueueScheduler(qos: .default))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: setBadgeOnTab)
            .disposed(by: disposeBag!)
    }

    private func notify(_ push: PushDTO) {
        if (!candidates.contains(push.event)) {
            return
        }
        let window = UIApplication.shared.keyWindow!
        let notification = NotificationView(imageUrl: push.imageUrl, message: push.message)
        notification.insert(into: window)
        notification.show()
    }

    private func setBadgeOnTab(_ hasUnread: Bool) {
        if let tabBarItems = tabBar.items {
            let tabBarItem = tabBarItems[3]
            tabBarItem.badgeValue = hasUnread ? "●" : ""
            tabBarItem.badgeColor = .clear
            tabBarItem.setBadgeTextAttributes([
                NSAttributedString.Key.foregroundColor: UIColor.systemPink
            ], for: .normal)
        }
    }
}
