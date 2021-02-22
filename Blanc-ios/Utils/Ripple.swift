import Foundation
import MaterialComponents.MaterialRipple

class Ripple {
    var rippleControllers = Array<MDCRippleTouchController>()

    func activate(to: UIView) {
        let rippleController = MDCRippleTouchController()
        rippleController.addRipple(to: to)
        rippleControllers.append(rippleController)
    }

}
