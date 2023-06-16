import UIKit

public class DiscountCodeView: UIView {
    override public var backgroundColor: UIColor? {
        get {
            backgroundView.backgroundColor
        }
        set {
            backgroundView.backgroundColor = newValue
        }
    }

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = Styling.cornerRadiusModalPopup
        view.layer.masksToBounds = true
        return view
    }()

    private let margin: CGFloat = 16

    private var onTouchApplyButton: ((_ code: String?) -> ())?

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    public let codeLabel: CopyableLabel = {
        let label = CopyableLabel(frame: .zero)
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public let validityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .backgroundTertiary
        return label
    }()

    public let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    public var applyButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let applyButtonContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public func adjustHeightOfValidityLabel(to value: CGFloat) {
        heightOfValidityConstraint.constant = value
    }
    
    private var heightOfValidityConstraint: NSLayoutConstraint!
    
    override public init(frame: CGRect) {
        super.init(frame: .zero)

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.addSubview(validityLabel)
        backgroundView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(codeLabel)
        var constraints = [NSLayoutConstraint]()
        
        heightOfValidityConstraint = validityLabel.heightAnchor.constraint(equalToConstant: 36)
        constraints.append(heightOfValidityConstraint)
        constraints.append(validityLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor))
        constraints.append(validityLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor))
        constraints.append(validityLabel.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constraints.append(contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin))
        constraints.append(contentStackView.topAnchor.constraint(equalTo: validityLabel.bottomAnchor, constant: 10))
        constraints.append(contentStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -22))
        constraints.append(backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constraints.append(backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin))
        constraints.append(backgroundView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -22))
        NSLayoutConstraint.activate(constraints)
        applyButton.addTarget(self, action: #selector(applyButtonTouched), for: .touchUpInside)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func showApplyButton(onTouchUpInside: @escaping ((_ code: String?) -> ())) {
        self.onTouchApplyButton = onTouchUpInside
        if applyButton.superview != nil {
            return
        }
        applyButtonContainerView.cover(with: applyButton, insets: NSDirectionalEdgeInsets(top: 0, leading: 32, bottom: 0, trailing: 32))
        contentStackView.addArrangedSubview(applyButtonContainerView)
    }

    @objc
private func applyButtonTouched() {
        guard let callBack = self.onTouchApplyButton else {
            return
        }
        callBack(codeLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
