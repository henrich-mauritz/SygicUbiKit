import UIKit

// MARK: - InputFieldTableViewCellViewModelProtocol

public protocol InputFieldTableViewCellViewModelProtocol {
    var iconImage: UIImage? { get set }
    var text: String? { get set }
    var placeHolder: String? { get set }
    var isSecure: Bool { get set }
    var toolBarActionButttonText: String { get }
    var errorMessage: String? { get }
}

public extension InputFieldTableViewCellViewModelProtocol {
    var toolBarActionButttonText: String { "" }
    var errorMessage: String? { nil }
}

// MARK: - InputFieldTableViewCellDelegate

public protocol InputFieldTableViewCellDelegate: AnyObject {
    func cellDidFinishEditingText(cell: InputFieldTableViewCell)
}

// MARK: - InputFieldTableViewCell

public class InputFieldTableViewCell: UITableViewCell {
    public weak var delegate: InputFieldTableViewCellDelegate?

    override public var reuseIdentifier: String? {
        return InputFieldTableViewCell.identifier
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Styling.backgroundPrimary
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public lazy var iconImageView: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    public lazy var inputField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.stylingFont(.regular, with: 16)
        textField.textColor = .foregroundOnboarding
        textField.backgroundColor = .clear
        textField.inputAccessoryView = accessoryInputView
        return textField
    }()

    private lazy var actionButton: UIBarButtonItem = {
        let doneAction = UIBarButtonItem(title: "",
                                         style: .plain,
                                         target: self,
                                         action: #selector(InputFieldTableViewCell.doneButtonPressed))
        return doneAction
    }()

    private lazy var accessoryInputView: UIToolbar = {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolBar.tintColor = Styling.actionPrimary
        let expanderItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [expanderItem, actionButton]
        return toolBar
    }()

    private lazy var placeholderProperties: [NSAttributedString.Key: Any] = {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Styling.foregroundSecondary.withAlphaComponent(0.4),
            NSAttributedString.Key.font: UIFont.stylingFont(.regular, with: 16),
        ]
        return attributes
    }()

    private lazy var errorMessageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 10)
        label.textColor = .negativePrimary
        return label
    }()

    public lazy var innerContainerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 48))
        view.backgroundColor = Styling.textFieldBackgroundPrimary
        view.translatesAutoresizingMaskIntoConstraints = false
        let heighConstraint = view.heightAnchor.constraint(equalToConstant: 48)
        heighConstraint.priority = UILayoutPriority(750) //to avoid constrains logs
        heighConstraint.isActive = true
        view.applyRoundedMask(cornerRadious: 24, applyMask: false, corners: .allCorners)
        return view
    }()

    override public func setSelected(_ selected: Bool, animated: Bool) {}
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {}

    private func setupLayout() {
        contentView.addSubview(innerContainerView)
        contentView.addSubview(errorMessageLabel)
        innerContainerView.addSubview(inputField)
        innerContainerView.addSubview(iconImageView)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(innerContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40))
        constraints.append(innerContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40))
        constraints.append(innerContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8))
        constraints.append(iconImageView.centerYAnchor.constraint(equalTo: innerContainerView.centerYAnchor))
        constraints.append(iconImageView.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 18))
        constraints.append(inputField.topAnchor.constraint(equalTo: innerContainerView.topAnchor, constant: 0))
        constraints.append(inputField.bottomAnchor.constraint(equalTo: innerContainerView.bottomAnchor, constant: 0))
        constraints.append(inputField.trailingAnchor.constraint(equalTo: innerContainerView.trailingAnchor, constant: -4))
        constraints.append(inputField.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 44))
        constraints.append(errorMessageLabel.topAnchor.constraint(equalTo: innerContainerView.bottomAnchor, constant: 4))
        constraints.append(errorMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4))
        constraints.append(errorMessageLabel.leadingAnchor.constraint(equalTo: innerContainerView.leadingAnchor, constant: 20))
        constraints.append(errorMessageLabel.trailingAnchor.constraint(equalTo: innerContainerView.trailingAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    public func configure(with viewModel: InputFieldTableViewCellViewModelProtocol) {
        iconImageView.image = viewModel.iconImage
        inputField.text = viewModel.text
        inputField.attributedPlaceholder = NSAttributedString(string: viewModel.placeHolder ?? "", attributes: placeholderProperties)
        inputField.isSecureTextEntry = viewModel.isSecure
        actionButton.title = viewModel.toolBarActionButttonText
        errorMessageLabel.text = viewModel.errorMessage
        if viewModel.errorMessage != nil {
            innerContainerView.layer.borderColor = UIColor.negativePrimary.cgColor
            innerContainerView.layer.borderWidth = 2
        }
    }

    @objc
private func doneButtonPressed() {
        guard let delegate = self.delegate else {
            return
        }
        delegate.cellDidFinishEditingText(cell: self)
        inputField.resignFirstResponder()
    }
}
