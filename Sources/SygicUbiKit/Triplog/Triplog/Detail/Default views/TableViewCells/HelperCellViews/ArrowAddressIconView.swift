import UIKit

class ArrowAddressIconView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: 6).isActive = true
        heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        UIColor.backgroundSecondary.setFill()
        let dot = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 6, height: 6))
        let dot2 = UIBezierPath(ovalIn: CGRect(x: 0, y: 11, width: 6, height: 6))
        let dot3 = UIBezierPath(ovalIn: CGRect(x: 0, y: 22, width: 6, height: 6))
        dot.fill()
        dot2.fill()
        dot3.fill()
    }
}
