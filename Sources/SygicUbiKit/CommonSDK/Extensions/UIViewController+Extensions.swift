import Foundation
import UIKit

public extension UIViewController {
    func setupNavigationMultilineTitle() {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        // recursively find the label
        func findLabel(in view: UIView) -> UILabel? {
            if view.subviews.count > 0 {
                for subview in view.subviews {
                    if let label = findLabel(in: subview) {
                        return label
                    }
                }
            }
            return view as? UILabel
        }
        
        if let label = findLabel(in: navigationBar) {
            if label.text == self.title {
                label.lineBreakMode = .byWordWrapping
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.7
                label.sizeToFit()
            }
        }
    }
    
    func presentAsSheet(viewController: UIViewController) {
        let sheetPresenter = CoverFromBottomPresentationController(presentedViewController: viewController, presenting: self)
        viewController.view.backgroundColor = .clear
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = sheetPresenter
        self.present(viewController, animated: true)
    }
    
}
