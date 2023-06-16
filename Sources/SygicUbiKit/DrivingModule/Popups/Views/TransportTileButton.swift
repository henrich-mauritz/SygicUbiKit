import Foundation
import UIKit

class TransportTileButton: UIControl {
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .buttonForegroundPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .buttonForegroundPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override public var isHighlighted: Bool {
        didSet {
            guard isEnabled else { return }
            alpha = !isHighlighted ? 1 : Styling.highlightedStateAlpha
        }
    }

    override public var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1 : Styling.disabledStateAlpha
        }
    }

    private let buttonSize: CGFloat = 120
    private let margin: CGFloat = 8

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        backgroundColor = .buttonBackgroundPrimary
        layer.cornerRadius = Styling.cornerRadius

        let stackView = UIStackView()
        stackView.isUserInteractionEnabled = false
        stackView.axis = .vertical
        stackView.spacing = margin
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: margin * 2))
        constraints.append(stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: margin))
        constraints.append(stackView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(stackView.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(widthAnchor.constraint(equalToConstant: buttonSize))
        constraints.append(heightAnchor.constraint(equalToConstant: buttonSize))
        NSLayoutConstraint.activate(constraints)
    }
}
