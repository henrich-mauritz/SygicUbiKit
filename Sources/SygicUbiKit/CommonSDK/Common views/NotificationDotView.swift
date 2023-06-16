import Foundation
import UIKit

public class NotificationDotView: UIView {
    public static let dotSize: CGFloat = 14

    public var badgeColor: UIColor = .actionPrimary
    public var badgeBorderColor: UIColor = .backgroundPrimary

    public let borderWidth: CGFloat = 3

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func draw(_ rect: CGRect) {
        badgeColor.setFill()
        badgeBorderColor.setStroke()
        let circleRect = rect.insetBy(dx: borderWidth / 2.0, dy: borderWidth / 2.0)
        let circle = UIBezierPath(ovalIn: circleRect)
        circle.lineWidth = borderWidth
        circle.fill()
        circle.stroke()
    }
}
