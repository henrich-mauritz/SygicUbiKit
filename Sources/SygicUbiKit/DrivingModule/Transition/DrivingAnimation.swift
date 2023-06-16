import UIKit

// MARK: - DrivingPresentationAnimationController

public class DrivingPresentationAnimationController: NSObject {
    private let originFrame: CGRect
    private let initialImage: UIImageView
    private let trainsitionDuration: TimeInterval = 0.4
    private weak var drivingPresController: DrivingPresentationController?

    public init(originFrame: CGRect, originCarImage: UIImageView, presentationController: DrivingPresentationController) {
        self.originFrame = originFrame
        self.initialImage = originCarImage
        self.drivingPresController = presentationController
    }

    private func findPresentationController(from transitionFromController: UIViewController?) -> DrivingPresentationController? {
        guard let fromController = transitionFromController else { return nil }
        if let drivingPresentationController = fromController as? DrivingPresentationController {
            return drivingPresentationController
        }
        for child in fromController.children {
            if let drivingPresentationController = child as? DrivingPresentationController {
                return drivingPresentationController
            }
        }
        return nil
    }
}

// MARK: - DrivingPresentationController

public protocol DrivingPresentationController where Self: UIViewController {
    var drivingControllerPresentingView: UIView { get }
    func restoreDrivingControllerPresentingView()
}

// MARK: - DrivingPresentationAnimationController + UIViewControllerAnimatedTransitioning

extension DrivingPresentationAnimationController: UIViewControllerAnimatedTransitioning {
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = drivingPresController,
              let toVC = transitionContext.viewController(forKey: .to) as? DrivingViewController
        else { return }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        let initialImageView = containerView.convert(initialImage.frame, from: initialImage.superview)
        containerView.addSubview(toVC.view)

        toVC.view.layoutIfNeeded()
        toVC.buttonBottomConstraint?.isActive = false

        toVC.view.frame = fromVC.drivingControllerPresentingView.convert(originFrame, to: containerView)
        toVC.view.clipsToBounds = true
        toVC.drivingView.closeButton.transform = CGAffineTransform(rotationAngle: .pi)
        containerView.addSubview(initialImage)
        containerView.bringSubviewToFront(initialImage)
        initialImage.frame = initialImageView
        let finalCarImage = toVC.drivingView.imageView
        finalCarImage.isHidden = true

        let duration = transitionDuration(using: transitionContext)
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: .calculationModeCubicPaced,
            animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 2 / 3) {
                    let carFrame = self.initialImage.frame
                    self.initialImage.transform = .identity
                    self.initialImage.center = CGPoint(x: containerView.frame.width / 2, y: carFrame.origin.y - 100)
                    self.initialImage.frame.size = CGSize(width: carFrame.width * 2, height: carFrame.height * 2)
                    toVC.view.layoutIfNeeded()
                }

                UIView.addKeyframe(withRelativeStartTime: 2 / 3, relativeDuration: 1 / 3) {
                    toVC.view.frame = finalFrame
                    toVC.buttonBottomConstraint?.isActive = true
                    toVC.view.layoutIfNeeded()
                    toVC.drivingView.closeButton.transform = CGAffineTransform.identity
                    self.initialImage.frame = containerView.convert(toVC.drivingView.imageView.frame, from: toVC.view)
                }
        }, completion: { _ in
            self.initialImage.isHidden = true
            finalCarImage.isHidden = false

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        )
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return trainsitionDuration
    }
}

// MARK: - DrivingDismissAnimationController

public class DrivingDismissAnimationController: NSObject {
    public let interactionController: SwipeInteractionController?
    private let destinationFrame: CGRect
    private let trainsitionDuration: TimeInterval = 0.4
    private weak var drivingPresController: DrivingPresentationController?

    public init(destinationFrame: CGRect, interactionController: SwipeInteractionController?, destinationController: DrivingPresentationController) {
        self.destinationFrame = destinationFrame
        self.interactionController = interactionController
        self.drivingPresController = destinationController
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension DrivingDismissAnimationController: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return trainsitionDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? DrivingViewController,
            let toVC = drivingPresController
            else { return }

        fromVC.view.clipsToBounds = true

        let imageView = fromVC.drivingView.imageView
        let duration = transitionDuration(using: transitionContext)
        fromVC.buttonBottomConstraint?.isActive = false

        UIView.animate(withDuration: duration, animations: {
            fromVC.view.layoutIfNeeded()
            let containerFrame = transitionContext.containerView.frame
            fromVC.view.frame = CGRect(x: 0, y: containerFrame.height, width: containerFrame.width, height: containerFrame.height)
                           imageView.layer.opacity = 0
        }, completion: { _ in

            if !transitionContext.transitionWasCancelled {
                toVC.restoreDrivingControllerPresentingView()
            } else {
                fromVC.buttonBottomConstraint?.isActive = true
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
