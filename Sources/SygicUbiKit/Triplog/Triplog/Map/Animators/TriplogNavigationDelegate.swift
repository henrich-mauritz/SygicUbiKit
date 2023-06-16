import Foundation

import MapKit
import UIKit

// MARK: - MapAnimatingType

protocol MapAnimatingType where Self: UIViewController {
    var mapUIView: MKMapView { get }
}

// MARK: - TriplogNavigationDelegate

class TriplogNavigationDelegate: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let _ = fromVC as? TriplogMapViewController,
              let _ = toVC as? TriplogMapViewController else {
            return nil
        }
        return TriplogMapPushPopTransitioning()
    }
}
