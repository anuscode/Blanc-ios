import Foundation
import UIKit

class RegistrationNavigationViewController: UINavigationController {

    internal var registrationViewModel: RegistrationViewModel?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func stackAfterClear(identifier: String, animated: Bool = true) {
        let storyboard = UIStoryboard(name: "Registration", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        popToRootViewController(animated: false)
        pushViewController(vc, animated: animated)
    }
}
