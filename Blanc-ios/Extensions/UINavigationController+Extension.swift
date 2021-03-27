import Foundation
import UIKit

enum Identifier: String {
    case userSingle = "UserSingleViewController",
         postList = "PostListViewController",
         postSingle = "PostSingleViewController",
         postManagement = "PostManagementViewController",
         postCreate = "PostCreateViewController",
         alarms = "AlarmViewController",
         inAppPurchase = "InAppPurchaseViewController",
         favoriteUsers = "FavoriteUserListViewController",

         pushSetting = "PushSettingViewController",
         imageView = "ImageViewController",
         profileView = "ProfileViewController",
         myRatedScore = "MyRatedScoreViewController",
         avoidView = "AvoidViewController",
         accountManagement = "AccountManagementViewController",

         reportUser = "ReportUserViewController",
         reportPost = "ReportPostViewController"
}

extension UINavigationController {

    func pushViewController(_ identifier: Identifier,
                            current: UIViewController? = nil,
                            hideBottomWhenStart: Bool = true,
                            hideBottomWhenEnd: Bool = false,
                            animated: Bool = true) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
        current?.hidesBottomBarWhenPushed = hideBottomWhenStart
        pushViewController(vc, animated: animated)
        current?.hidesBottomBarWhenPushed = hideBottomWhenEnd
    }

    func pushViewController(_ vc: UIViewController,
                            current: UIViewController? = nil,
                            hideBottomWhenStart: Bool = true,
                            hideBottomWhenEnd: Bool = false,
                            animated: Bool = true) {
        current?.hidesBottomBarWhenPushed = hideBottomWhenStart
        pushViewController(vc, animated: animated)
        current?.hidesBottomBarWhenPushed = hideBottomWhenEnd
    }
}

extension UINavigationController {

    static private var progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = true
        var indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
        indicator.startAnimating()
        view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()

    func progress(_ boolean: Bool) {
        if (boolean) {
            view.addSubview(UINavigationController.progressView)
            view.bringSubviewToFront(UINavigationController.progressView)
            UINavigationController.progressView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            UINavigationController.progressView.removeFromSuperview()
        }
    }
}

