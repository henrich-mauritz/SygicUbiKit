import UIKit

class StartAddressIconView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: 12).isActive = true
        heightAnchor.constraint(equalToConstant: 12).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let fillColor = UIColor.mapRoute
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 12, height: 12))
        fillColor.setFill()
        ovalPath.fill()
    }
}
