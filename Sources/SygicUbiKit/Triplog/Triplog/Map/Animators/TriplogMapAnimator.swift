import Foundation
import UIKit

class TriplogMapPushPopTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    let transitionDuration: TimeInterval = 0.8

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let outgoingController = transitionContext.viewController(forKey: .from) as? TriplogMapViewController,
              let incomingController = transitionContext.viewController(forKey: .to) as? TriplogMapViewController else { return }

        guard let outgoingView = outgoingController.view,
              let incomingView = incomingController.view,
              let mapView = outgoingController.mapView else {
            transitionContext.completeTransition(false)
            return
        }

        let container = transitionContext.containerView
        var incommingFrame = outgoingView.frame
        var outgoingFrame = incommingFrame
        // Resetting the alpha of the bottosheet to force the right frames
        incomingController.bottomSheet.view.alpha = 0.0
        // Cover the container with the map
        container.cover(with: mapView, toSafeArea: false)
        // passign the map to the incomingController
        incomingController.mapView = mapView
        //6. Settting the orign frame for animatieon
        incommingFrame.origin.y = outgoingView.frame.height
        incomingView.frame = incommingFrame
        // adding the invomcing/outgoing view to the container
        container.addSubview(incomingView)
        container.addSubview(outgoingView)
        // laying out
        incomingView.layoutIfNeeded()
        // resetting the alpha
        incomingController.bottomSheet.view.alpha = 1.0

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            incomingController.adjustMapVisibleArea()
        }

        UIView.animate(withDuration: transitionDuration, delay: 0.0, options: [.curveEaseInOut]) {
            incommingFrame.origin.y = outgoingView.frame.origin.y
            incomingView.frame = incommingFrame
            outgoingFrame.origin.y = outgoingFrame.size.height
            outgoingView.frame = outgoingFrame
        } completion: { _ in
            mapView.removeFromSuperview()
            incomingView.cover(with: mapView, toSafeArea: false)
            incomingView.sendSubviewToBack(mapView)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
