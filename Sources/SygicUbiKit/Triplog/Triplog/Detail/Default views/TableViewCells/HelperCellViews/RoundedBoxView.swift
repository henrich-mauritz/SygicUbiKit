import UIKit

class RoundedBoxView: UIView {
    public var hide: Bool {
        set {
            if newValue {
                backgroundColor = .backgroundSecondary
            }
        }
        get {
            isHidden
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        heightAnchor.constraint(equalToConstant: 16).isActive = true
        widthAnchor.constraint(equalToConstant: 16).isActive = true
        layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
