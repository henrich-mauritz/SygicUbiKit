import Foundation
import UIKit

public extension UIView {
    func apply(style: Styling.Style) {
        switch style {
        case let .roundedWithDropShadowStyle(cornerRadious, shadowColor, shadowOffset, shadowRadius):
            layer.cornerRadius = cornerRadious
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = 0.8
            layer.shadowRadius = shadowRadius
            layer.masksToBounds = false
        case let .roundedCornersStyle(cornerRadius):
            applyRoundedMask(cornerRadious: cornerRadius)
        case let .secondaryRoundeCornerStyle(cornerRadius):
            applyRoundedMask(cornerRadious: cornerRadius)
        }
    }

    func applyRoundedMask(cornerRadious: CGFloat, applyMask: Bool = true, corners: UIRectCorner = .allCorners) {
        if applyMask {
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadious, height: cornerRadious)).cgPath
            self.layer.mask = mask
        } else {
            self.layer.cornerRadius = cornerRadious
            self.layer.masksToBounds = true
        }
    }
}

public extension UIView {
    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}

public extension UIView {
    func containedInView(with margins: NSDirectionalEdgeInsets) -> UIView {
        let view = UIView()
        view.cover(with: self, insets: margins)
        return view
    }
}
