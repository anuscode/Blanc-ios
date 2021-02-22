import Foundation
import UIKit

class RootViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController = storyboard.instantiateViewController(
                withIdentifier: "InitPagerViewController")
        initViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(initViewController, animated: false)
        }
    }
}
