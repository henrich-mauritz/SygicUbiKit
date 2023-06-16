import UIKit

// MARK: - InteractionControllerDelegate

public protocol InteractionControllerDelegate: AnyObject {
    func shouldDismiss() -> Bool
}

// MARK: - SwipeInteractionController

public class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    public weak var delegate: InteractionControllerDelegate?
    public var interactionInProgress = false

    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        prepareGestureRecognizer(in: viewController.view)
    }

    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
    }

    @objc
func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let viewController = viewController,
              viewController.modalPresentationStyle != .fullScreen,
              let superView = gestureRecognizer.view?.superview else { return }
        let translation = gestureRecognizer.translation(in: superView)
        var progress: CGFloat = 0.0 // Dragging the view down by 200 points is considered to be 100% complete
        var shouldUseVelocityForDimsissal = true

        if let delegate = delegate, !delegate.shouldDismiss() {
                progress = (translation.y / (2 * UIScreen.main.bounds.height))
                shouldUseVelocityForDimsissal = false
               } else {
                   progress = (translation.y / UIScreen.main.bounds.height)
               }
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))

        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition || shouldUseVelocityForDimsissal && (gestureRecognizer.velocity(in: gestureRecognizer.view).y > 1800) {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
