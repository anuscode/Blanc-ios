import Foundation
import UIKit

extension UIViewController {
    func toast(title: String? = nil, message: String?, seconds: Double = 1.5, callback: (() -> Void)? = nil) {
        DispatchQueue.main.async { [unowned self] in
            let alert = UIAlertController(title: title ?? "", message: message ?? "", preferredStyle: .alert)
            alert.view.backgroundColor = .black
            alert.view.alpha = 0.5
            alert.view.layer.cornerRadius = 15
            present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
                alert.dismiss(animated: true)
                callback?()
            }
        }
    }
}

extension UIViewController {
    func replace(
            storyboard: String = "Main",
            bundle: Bundle? = nil,
            withIdentifier: String,
            animated: Bool = true,
            modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
            completion: (() -> Void)? = nil
    ) {
        log.info("presenting \(withIdentifier)..")
        let storyboard = UIStoryboard(name: storyboard, bundle: bundle)
        let vc = storyboard.instantiateViewController(withIdentifier: withIdentifier)
        vc.modalPresentationStyle = modalPresentationStyle
        view.window?.rootViewController?.dismiss(animated: false, completion: {
            let window = UIApplication.shared.windows.first
            window?.rootViewController?.present(vc, animated: animated, completion: completion)
        })
    }
}