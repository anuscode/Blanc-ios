import Foundation
import UIKit

enum Identifier: String {
    case userSingle = "UserSingleViewController",
         postSingle = "PostSingleViewController",
         alarms = "AlarmViewController"
}

extension UINavigationController {

    func pushViewController(_ identifier: Identifier,
                            hideBottomWhenStart: Bool = true,
                            hideBottomWhenEnd: Bool = false) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier.rawValue)
        hidesBottomBarWhenPushed = hideBottomWhenStart
        pushViewController(vc, animated: true)
        hidesBottomBarWhenPushed = hideBottomWhenEnd
    }

    func pushUserSingleViewController(current: UIViewController) {
        DispatchQueue.main.async { [unowned self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "UserSingleViewController")
            vc.modalPresentationStyle = .fullScreen
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = ""
            backBarButtonItem.tintColor = .black
            current.navigationItem.backBarButtonItem = backBarButtonItem
            current.hidesBottomBarWhenPushed = true
            pushViewController(vc, animated: true)
            current.hidesBottomBarWhenPushed = false
        }
    }

    func pushPostSingleViewController(current: UIViewController) {
        DispatchQueue.main.async { [unowned self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PostSingleViewController")
            vc.modalPresentationStyle = .fullScreen
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = ""
            backBarButtonItem.tintColor = .black
            current.hidesBottomBarWhenPushed = true
            current.navigationItem.backBarButtonItem = backBarButtonItem
            pushViewController(vc, animated: true)
            current.hidesBottomBarWhenPushed = false
        }
    }

    func pushAlarmViewController(current: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AlarmViewController")
        vc.modalPresentationStyle = .fullScreen
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = ""
        backBarButtonItem.tintColor = .black
        current.navigationItem.backBarButtonItem = backBarButtonItem
        current.hidesBottomBarWhenPushed = true
        pushViewController(vc, animated: true)
        current.hidesBottomBarWhenPushed = false
    }
}

extension UINavigationController {

    static private var progress: UIView = {
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

    func startProgress() {
        view.addSubview(UINavigationController.progress)
        view.bringSubviewToFront(UINavigationController.progress)
        UINavigationController.progress.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func stopProgress() {
        UINavigationController.progress.removeFromSuperview()
    }
}

