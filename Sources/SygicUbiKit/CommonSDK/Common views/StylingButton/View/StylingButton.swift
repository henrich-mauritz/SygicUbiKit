import Swinject
import UIKit

// MARK: - StylingButton

public class StylingButton: UIControl, InjectableType {
    public enum ButtonStyle: Equatable {
        case normal
        case bar
        case textIcon
        case plain
        case secondary
        case tertiary
        case normalModal
        case secondaryModal
        case circular
        case custom(titleFont: UIFont, height: CGFloat, radius: CGFloat, textAlignment: NSTextAlignment, customStyleName: String)

        public var styleName: String {
            switch self {
            case .normal:
                return "normal"
            case .bar:
                return "bar"
            case .textIcon:
                return "textIcon"
            case .plain:
                return "plain"
            case .secondary:
                return "secondaryPlain"
            case .tertiary:
                return "tertiary"
            case .normalModal:
                return "normalModal"
            case .secondaryModal:
                return "secondaryModal"
            case .circular:
                return "circular"
            case let .custom(_, _, _, _, customStyleName):
                return customStyleName
            }
        }

        var height: CGFloat {
            switch self {
            case .bar:
                return 28
            case .plain:
                return 20
            case .circular:
                return 70
            default:
                return 48
            }
        }

        public static func == (lhs: Self, rhs: Self) -> Bool {
            return lhs.styleName == rhs.styleName
        }
    }

    override public var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : Styling.disabledStateAlpha
        }
    }

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = titleColor
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    public lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = titleColor
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    public var titleColor: UIColor = .buttonForegroundPrimary {
        didSet {
            titleLabel.textColor = titleColor
            iconView.tintColor = titleColor
        }
    }

    /// Chaning the visualStyle properties will change just how the button will look regarding the type upon initialization. This buttonStyle property remains unchanged.
    public var visualStyleProperties: StylingButtonType? {
        didSet {
            guard let properties = visualStyleProperties else {
                return
            }
            setupVisualAtributes(with: properties)
        }
    }

    public var buttonStyle: ButtonStyle = .normal {
        didSet {
            if let visualStyle = container.resolve(StylingButtonType.self, name: buttonStyle.styleName) {
                setupVisualAtributes(with: visualStyle)
                self.visualStyleProperties = visualStyle
            } else { // register default style
                let styleName = buttonStyle.styleName
                var visualStyle: StylingButtonType

                switch buttonStyle {
                case .bar:
                    visualStyle = StylingButtonStyle.barStyle()
                case .textIcon:
                    visualStyle = StylingButtonStyle.textIconStyle()
                case .plain:
                    visualStyle = StylingButtonStyle.plainIconStyle()
                case .normal:
                    visualStyle = StylingButtonStyle.normalStyle()
                case .secondary:
                    visualStyle = StylingButtonStyle.secondaryPlain()
                case .tertiary:
                    visualStyle = StylingButtonStyle.tertiaryStyle()
                case .normalModal:
                    visualStyle = StylingButtonStyle.normalModalStyle()
                case .secondaryModal:
                    visualStyle = StylingButtonStyle.secondaryModalStyle()
                case .circular:
                    visualStyle = StylingButtonStyle.circularStyle()
                case let .custom(titleFont, height, radius, textAlignment, _):
                    visualStyle = StylingButtonStyle(titleFont: titleFont)
                    visualStyle.height = height
                    visualStyle.radius = radius
                    visualStyle.textAlignment = textAlignment
                }
                container.register(StylingButtonType.self, name: styleName) {_ in visualStyle }
                self.visualStyleProperties = visualStyle
            }
        }
    }

    private func setupVisualAtributes(with visuals: StylingButtonType) {
        if visuals.filled {
            backgroundColor = visuals.backgroundColor
        } else {
            backgroundColor = .clear
        }
        if visuals.stroked {
            layer.borderColor = visuals.strokeColor.cgColor
            layer.borderWidth = visuals.lineWidth
        }
        height = visuals.height
        layer.cornerRadius = visuals.radius
        titleLabel.font = visuals.titleFont
        titleLabel.textAlignment = visuals.textAlignment
        titleLabel.textColor = visuals.titleColor

        if let _ = visuals as? StylingButtonCircularStyle {
            changeLayoutForCircularStyle()
        }
    }

    public var height: CGFloat = ButtonStyle.normal.height {
        didSet {
            heightConstraint?.constant = height
            if self.buttonStyle == .circular {
                self.layer.cornerRadius = height / 2
            }
        }
    }

    private let margin: CGFloat = 22
    private let iconHeight: CGFloat = 24

    private var heightConstraint: NSLayoutConstraint?

    //MARK: -  initializers

    public class func button(with style: StylingButton.ButtonStyle = .normal) -> StylingButton {
        let button = StylingButton(frame: CGRect(x: 0, y: 0, width: style.height, height: style.height)) //to avoid _UITemporaryLayoutWidth
        button.buttonStyle = style
        return button
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    //MARK: - Lifecycle

    private func setupLayout() {
        backgroundColor = .actionPrimary
        heightConstraint = heightAnchor.constraint(equalToConstant: height)
        heightConstraint?.isActive = true
        layer.cornerRadius = Styling.cornerRadius

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(UILayoutPriority(0), for: .horizontal)
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(titleLabel)
        addSubview(iconView)

        let titleTailContraint = titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin)
        titleTailContraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            titleTailContraint,
            titleLabel.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: 0),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: iconHeight),
            iconView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
        ])
    }

    private func changeLayoutForCircularStyle() {
        titleLabel.removeFromSuperview()
        iconView.removeFromSuperview()
        layoutIfNeeded()
        addSubview(iconView)

        let aspectRatio = NSLayoutConstraint(item: self,
                                             attribute: .height,
                                             relatedBy: .equal,
                                             toItem: self,
                                             attribute: .width,
                                             multiplier: 1,
                                             constant: 0)
        NSLayoutConstraint.activate([
            aspectRatio,
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: iconHeight),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}

//MARK: - User Interaction Feedback

public extension StylingButton {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = Styling.highlightedStateAlpha
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
        super.touchesEnded(touches, with: event)
    }
}
