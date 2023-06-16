import Foundation
import UIKit

public extension UIStackView {
    func removeAll() {
        for subview in arrangedSubviews {
            removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    func addArrangedSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.addArrangedSubview(subview)
        }
    }
    
    func addArrangedSubview(_ view: UIView, spacingAfter: CGFloat) {
        addArrangedSubview(view)
        setCustomSpacing(spacingAfter, after: view)
    }
    
    func addBackgroundView(color: UIColor) -> UIView {
        let subView = UIView(frame: bounds)
        subView.tag = 999
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
        return subView
    }
    
}
