import UIKit

class EndAddressIconView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: 15).isActive = true
        heightAnchor.constraint(equalToConstant: 25).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let image = UIImage(named: "pinFinish", in: .module, compatibleWith: nil)
        image?.draw(at: .zero)
    }
}
