import Foundation
import MaterialComponents.MaterialRipple

class Ripple {
    var rippleControllers = Array<MDCRippleTouchController>()

    func activate(to view: UIView) {
        let rippleController = MDCRippleTouchController()
        rippleController.addRipple(to: view)
        rippleControllers.append(rippleController)
    }
}
