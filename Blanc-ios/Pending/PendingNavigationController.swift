import Foundation
import UIKit

class PendingNavigationController: UINavigationController {

    var pendingViewModel: PendingViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}
