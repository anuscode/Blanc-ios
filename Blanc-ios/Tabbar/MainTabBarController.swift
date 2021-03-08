import UIKit
import RxSwift

class MainTabBarController: UITabBarController {

    weak var mainTabBarViewModel: MainTabBarViewModel?

    private var disposeBag: DisposeBag? = DisposeBag()

    // Foreground Notification Candidates..
    private let candidates: [PushFor?] = [
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
            .subscribe(onNext: setBadgeOnConversationTab)
            .disposed(by: disposeBag!)
    }

    private func notify(_ push: PushDTO) {
        if (!candidates.contains(push.pushFor)) {
            return
        }
        let window = UIApplication.shared.keyWindow!
        let notification = NotificationView(imageUrl: push.imageUrl, message: push.message)
        notification.insert(into: window)
        notification.show()
    }

    private func setBadgeOnConversationTab(_ hasUnread: Bool) {
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
