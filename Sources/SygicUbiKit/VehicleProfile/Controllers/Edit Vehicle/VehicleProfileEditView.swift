import UIKit

// MARK: - VehicleProfileEditViewProtocol

public protocol VehicleProfileEditViewProtocol: AnyObject {
    func saveChanges()
}

// MARK: - VehicleProfileEditView

open class VehicleProfileEditView: UIView {
    private let maxLength = 10
    let margins: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 32, leading: 40, bottom: 32, trailing: 40)

//MARK: - properties

    public weak var delegate: VehicleProfileEditViewProtocol?

    open var viewModel: VehicleProfileViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }

            textField.text = viewModel.name
            saveChangesButton.isEnabled = viewModel.name.count > 0
            textFieldDidChangeSelection(textField)
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 30)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        label.text = "vehicleProfile.edit.profileName".localized
        return label
    }()

    lazy var maxCharactersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        label.text = String(format: "vehicleProfile.addVehicle2.subtitle".localized, maxLength)
        return label
    }()

    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.textColor = .foregroundPrimary
        tf.delegate = self
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.stylingFont(.regular, with: 16)
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        return tf
    }()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.textColor = .foregroundPrimary.withAlphaComponent(0.6)
        label.text = "0/0"
        return label
    }()

    private lazy var textContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = Styling.cornerRadius
        view.addSubview(textField)
        view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        view.cover(with: textField, insets: NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 40))
        view.addSubview(counterLabel)
        counterLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        counterLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14).isActive = true
        return view
    }()

    lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.textColor = Styling.actionPrimary
        label.text = "vehicleProfile.addVehicle2.errorTaken".localized
        label.isHidden = true
        label.textAlignment = .center
        return label
    }()

    lazy var saveChangesButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normal)
        button.titleLabel.text = "vehicleProfile.edit.saveButton".localized.uppercased()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()

    var topLabelConstraint: NSLayoutConstraint?

    //MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .backgroundPrimary
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func setupLayout() {
        addSubview(titleLabel)
        addSubview(maxCharactersLabel)
        addSubview(textContainer)
        addSubview(errorLabel)
        addSubview(saveChangesButton)

        var constraints: [NSLayoutConstraint] = []
        topLabelConstraint = titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margins.top)
        constraints.append(topLabelConstraint!)
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins.leading))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins.trailing))
        constraints.append(maxCharactersLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16))
        constraints.append(maxCharactersLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins.leading))
        constraints.append(maxCharactersLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins.leading))
        constraints.append(textContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins.leading))
        constraints.append(textContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins.trailing))
        constraints.append(textContainer.topAnchor.constraint(equalTo: maxCharactersLabel.bottomAnchor, constant: margins.top))
        constraints.append(errorLabel.topAnchor.constraint(equalTo: maxCharactersLabel.topAnchor, constant: 5))
        constraints.append(errorLabel.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 16))
        constraints.append(errorLabel.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -16))
        constraints.append(saveChangesButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 16))
        constraints.append(saveChangesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins.leading))
        constraints.append(saveChangesButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins.leading))

        NSLayoutConstraint.activate(constraints)
        saveChangesButton.addTarget(self, action: #selector(VehicleProfileEditView.save), for: .touchUpInside)
    }

    @objc
    open func save() {
        saveChangesButton.isEnabled = false
        viewModel?.vehicle.name = textField.text ?? ""
        delegate?.saveChanges()
    }

    func configureForError(error: VehicleProfileAddEditError) {
        if error == .vehicleWithThisNameAlreadyExists {
            errorLabel.isHidden = false
            maxCharactersLabel.isHidden = true
        }
    }
}

// MARK: UITextFieldDelegate

extension VehicleProfileEditView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        let canChange = newString.length <= maxLength
        errorLabel.isHidden = true
        maxCharactersLabel.isHidden = false
        saveChangesButton.isEnabled = textField.text?.count ?? 0 > 0
        return canChange
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        let current = textField.text ?? ""
        let converted = current.uppercased()
        textField.text = converted
        counterLabel.text = "\(current.count)/\(maxLength)"
        guard let viewModel = self.viewModel else { return }
        saveChangesButton.isEnabled = current.compare(viewModel.name, options: .caseInsensitive, range: nil, locale: nil) != .orderedSame
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
