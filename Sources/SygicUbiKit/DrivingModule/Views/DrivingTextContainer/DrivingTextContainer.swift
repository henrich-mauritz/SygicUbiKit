import UIKit

class DrivingTextContainer: UIView {
    /// use this property to change speed text on screen
    public var speed: String? {
        didSet {
            speedContainer.activeLabel.text = speed
        }
    }

    public var speedingIntensity: Int = 0 {
        didSet {
            speedContainer.activeLabel.textColor = UIColor.speedingColor(with: speedingIntensity)
        }
    }

    /// use this property to change speed dimension on screen
    public var speedDimension: String? {
        set {
            speedContainer.dimensionLabel.text = newValue
        }
        get {
            return speedContainer.dimensionLabel.text
        }
    }

    private let labelWidth: CGFloat = 140

    private var speedContainer: LabelContainer = LabelContainer()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
        addSubview(speedContainer)
        initConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initConstraints() {
        speedContainer.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()

        constraints.append(speedContainer.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(speedContainer.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(speedContainer.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(speedContainer.widthAnchor.constraint(equalToConstant: labelWidth))

        NSLayoutConstraint.activate(constraints)
    }
}
