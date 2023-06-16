import UIKit

public class RewardDiscountCodeView: UIView, InjectableType {
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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var titleBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundTertiary
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 36).isActive = true
        return view
    }()

     lazy var yourCodeLabel: UILabel = {
        let label = UILabel()
         label.font = UIFont.stylingFont(.regular, with: 16)
         label.translatesAutoresizingMaskIntoConstraints = false
         label.text = "rewards.code.yourCode".localized
         label.textAlignment = .center
         label.textColor = .foregroundPrimary
         return label
    }()

    public let codeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.thin, with: 36)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public lazy var validityLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        guard let configuration = container.resolve(RewardDetailConfigurable.self) else {
            label.isHidden = true
            return label
        }
        label.isHidden = configuration.hideValidityDate
        return label
    }()

    lazy var innerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: padding, bottom: 33, trailing: padding)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let padding: CGFloat = 16

    override public init(frame: CGRect) {
        super.init(frame: .zero)
        setupLayout()
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCopyMenu)))
        backgroundView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showCopyMenu)))
    }

    open func setupLayout() {
        cover(with: backgroundView, insets: NSDirectionalEdgeInsets(top: 19, leading: padding, bottom: 19, trailing: padding))
        backgroundView.addSubview(titleBackgroundView)
        titleBackgroundView.cover(with: validityLabel, insets: NSDirectionalEdgeInsets(top: 0, leading: padding, bottom: 0, trailing: padding))
        backgroundView.addSubview(innerStackView)
        innerStackView.addArrangedSubview(yourCodeLabel)
        innerStackView.addArrangedSubview(codeLabel)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(titleBackgroundView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor))
        constraints.append(titleBackgroundView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor))
        constraints.append(titleBackgroundView.topAnchor.constraint(equalTo: backgroundView.topAnchor))
        constraints.append(innerStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor))
        constraints.append(innerStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor))
        constraints.append(innerStackView.topAnchor.constraint(equalTo: titleBackgroundView.bottomAnchor))
        constraints.append(innerStackView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var canBecomeFirstResponder: Bool {
        if let code = codeLabel.text, !code.isEmpty {
            return true
        }
        return false
    }

    override public func copy(_ sender: Any?) {
        UIPasteboard.general.string = codeLabel.text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }

    public func update(_ code: String?, validity: String?) {
        codeLabel.text = code
        validityLabel.text = validity
    }

    @objc
private func showCopyMenu() {
        guard !UIMenuController.shared.isMenuVisible else { return }
        becomeFirstResponder()
        UIMenuController.shared.setTargetRect(codeLabel.frame, in: self)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
}
