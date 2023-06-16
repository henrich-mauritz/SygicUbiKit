import UIKit

public class CheckmarkView: UIControl {
    private lazy var innerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
        view.isUserInteractionEnabled = false
        view.backgroundColor = .white
        return view
    }()

    private lazy var checkMarkImageView: UIImageView = {
        let checkMarkImage = UIImage(named: "combinedShape", in: .module, compatibleWith: nil)
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 8.2).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 11.2).isActive = true
        imageView.image = checkMarkImage
        imageView.tintColor = .backgroundDriving
        return imageView
    }()

    override public var isSelected: Bool {
        didSet {
            toggleVissuals()
        }
    }

    override public var isEnabled: Bool {
        didSet {
            if !isEnabled {
                alpha = Styling.disabledStateAlpha
            } else {
                alpha = 1.0
            }
        }
    }

    private func toggleVissuals() {
        checkMarkImageView.isHidden = !isSelected
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        innerView.applyRoundedMask(cornerRadious: 4.0, applyMask: false, corners: .allCorners)
        applyRoundedMask(cornerRadious: 14.0, applyMask: false, corners: .allCorners)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupLayout() {
        heightAnchor.constraint(equalToConstant: 38).isActive = true
        widthAnchor.constraint(equalToConstant: 38).isActive = true
        addSubview(innerView)
        innerView.addSubview(checkMarkImageView)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(innerView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(innerView.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(checkMarkImageView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor))
        constraints.append(checkMarkImageView.centerXAnchor.constraint(equalTo: innerView.centerXAnchor))
        NSLayoutConstraint.activate(constraints)
        backgroundColor = .actionPrimary
    }

    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.isSelected = !self.isSelected
        return true
    }
}
