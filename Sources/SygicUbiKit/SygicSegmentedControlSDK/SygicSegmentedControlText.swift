import UIKit

// MARK: - SygicSegmentedControlItem

public protocol SygicSegmentedControlItem where Self: UIControl {
    var showNotificationBadge: Bool { get set }
}

// MARK: - SygicSegmentedControlText

public class SygicSegmentedControlText: UIControl, SygicSegmentedControlItem {
    public var text: String? {
        get {
            label.text
        }
        set {
            label.text = newValue
        }
    }

    public var showNotificationBadge: Bool = false {
        didSet {
            updateBadge()
        }
    }

    public var textColor: UIColor = .foregroundSecondary
    public var selectedTextColor: UIColor = .buttonForegroundPrimary

    override public var isSelected: Bool {
        didSet {
            label.textColor = isSelected ? selectedTextColor : textColor
            updateBadge()
        }
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.textAlignment = .center
        label.textColor = textColor
        return label
    }()

    private lazy var badgeView: UIView = {
        let view = NotificationDotView()
        view.isHidden = true
        view.badgeBorderColor = .actionPrimary
        view.widthAnchor.constraint(equalToConstant: badgeSize).isActive = true
        view.heightAnchor.constraint(equalToConstant: badgeSize).isActive = true
        return view
    }()

    private let badgeSize: CGFloat = 8

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupLayout() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        addSubview(label)

        badgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(label.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(label.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(label.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(label.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5))
        constraints.append(badgeView.topAnchor.constraint(equalTo: topAnchor, constant: 4.0))
        NSLayoutConstraint.activate(constraints)
    }

    private func updateBadge() {
        badgeView.isHidden = !showNotificationBadge || isSelected
    }
}
