import Foundation
import UIKit

public class SpeedLimitView: UIView {
    public var strokeWidth: CGFloat = 7

    public let speedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.stylingFont(.bold, with: 26)
        label.textAlignment = .center
        label.text = "100"
        return label
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(speedLabel)
        speedLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        speedLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_ rect: CGRect) {
        guard rect.width > 0 && rect.height > 0 else { return }

        let ovalPath = UIBezierPath(ovalIn: rect.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2))
        UIColor.white.setFill()
        ovalPath.fill()
        UIColor.red2.setStroke()
        ovalPath.lineWidth = strokeWidth
        ovalPath.stroke()
    }
}
