import UIKit

protocol InteractiveNavigation {
    var presentAnimation: UIViewControllerAnimatedTransitioning? { get }
    var dismissAnimation: UIViewControllerAnimatedTransitioning? { get }

    func showNext()
}

enum SwipeDirection: CGFloat, CustomStringConvertible {
    case left  = -1.0
    case none  = 0.0
    case right = 1.0

    var description: String {
        switch self {
            case .left: return "Left"
            case .none: return "None"
            case .right: return "Right"
        }
    }
}

class CustomInteractiveAnimationNavigationController: UINavigationController , UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

    // MARK: - Properties
    var interactionController: UIPercentDrivenInteractiveTransition?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")
        log.info("override func viewDidLoad()")


        transitioningDelegate = self   // for presenting the original navigation controller
        delegate = self                // for navigation controller custom transitions

        // Choose one stlye of gesture recognizer
        // Pan Gesture (swipe from/to anywhere on the screen)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(CustomInteractiveAnimationNavigationController.handlePan(_:)))
        view.addGestureRecognizer(pan)

        // Edge Pan Gestures (swipe only from either edge)
        let left = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(CustomInteractiveAnimationNavigationController.handleSwipeFromLeft(_:)))
        left.edges = .left
        view.addGestureRecognizer(left);

        let right = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(CustomInteractiveAnimationNavigationController.handleSwipeFromRight(_:)))
        right.edges = .right
        view.addGestureRecognizer(right);
    }


    // MARK: - Gesture Handlers
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }

        let flickThreshold: CGFloat = 700.0 // Speed to make transition complete
        let distanceThreshold: CGFloat = 0.3 // Distance to make transition complete

        let velocity = gesture.velocity(in: gestureView)
        let translation = gesture.translation(in: gestureView)
        let percent = fabs(translation.x / gestureView.bounds.size.width);

        var swipeDirection: SwipeDirection = (velocity.x > 0) ? .right : .left

        switch gesture.state {
            case .began:
                interactionController = UIPercentDrivenInteractiveTransition()

                if swipeDirection == .right {
                    if viewControllers.count > 1 {
                        popViewController(animated: true)
                    } else {
                        dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    if let currentViewController = viewControllers.last as? InteractiveNavigation {
                        currentViewController.showNext()
                    }
                }

            case .changed:
                if let interactionController = self.interactionController {
                    interactionController.update(percent)
                }

            case .cancelled:
                if let interactionController = self.interactionController {
                    interactionController.cancel()
                }

            case .ended:
                if let interactionController = self.interactionController {
                    if abs(percent) > distanceThreshold || abs(velocity.x) > flickThreshold {
                        interactionController.finish()
                    } else {
                        interactionController.cancel()
                    }

                    self.interactionController = nil
                    swipeDirection = .none
                }

            default:
                break
        }
    }

    @objc func handleSwipeFromLeft(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }

        let percent = gesture.translation(in: gestureView).x / gestureView.bounds.size.width

        switch gesture.state {
            case .began:
                interactionController = UIPercentDrivenInteractiveTransition()

                if viewControllers.count > 1 {
                    popViewController(animated: true)
                } else {
                    dismiss(animated: true, completion: nil)
            }

            case .changed:
                if let interactionController = self.interactionController {
                    interactionController.update(percent)
                }

            case .cancelled:
                if let interactionController = self.interactionController {
                    interactionController.cancel()
                }

            case .ended:
                if let interactionController = self.interactionController {
                    if percent > 0.5 {
                        interactionController.finish()
                    } else {
                        interactionController.cancel()
                    }

                    self.interactionController = nil
                }

            default:
                break
        }
    }

    @objc func handleSwipeFromRight(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }

        let percent = -gesture.translation(in: gestureView).x / gestureView.bounds.size.width

        switch gesture.state {
            case .began:
                if let currentViewController = viewControllers.last as? InteractiveNavigation {
                    interactionController = UIPercentDrivenInteractiveTransition()
                    currentViewController.showNext()
                }

            case .changed:
                if let interactionController = self.interactionController {
                    interactionController.update(percent)
                }

            case .cancelled:
                if let interactionController = self.interactionController {
                    interactionController.cancel()
                }

            case .ended:
                if let interactionController = self.interactionController {
                    if percent > 0.5 {
                        interactionController.finish()
                    } else {
                        interactionController.cancel()
                    }
                    self.interactionController = nil
                }

            default:
                break
        }
    }


    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let _ = presenting as? InteractiveNavigation else {
            return nil
        }

        if let currentViewController = viewControllers.last as? InteractiveNavigation {
            return currentViewController.presentAnimation
        }

        return nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard viewControllers.count != 1 else {
            return nil
        }

        if let currentViewController = viewControllers.last as? InteractiveNavigation {
            return currentViewController.dismissAnimation
        }
        return nil
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }


    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let controller = AnimationController(animationDuration: 1, animationType: .present)
//        controller.fromViewController = fromVC
//        controller.toViewController = toVC
//        return controller
        return nil
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}
