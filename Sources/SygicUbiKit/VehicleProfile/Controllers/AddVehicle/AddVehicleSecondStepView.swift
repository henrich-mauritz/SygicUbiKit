import UIKit

// MARK: - AddVehicleSecondStepViewDelegate

public protocol AddVehicleSecondStepViewDelegate: VehicleProfileEditViewProtocol {}

// MARK: - AddVehicleSecondStepView

public class AddVehicleSecondStepView: VehicleProfileEditView {
    override public var viewModel: VehicleProfileViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            imageView.image = viewModel.icon
        }
    }

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 45).isActive = true
        iv.heightAnchor.constraint(equalTo: iv.widthAnchor).isActive = true
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .foregroundPrimary
        return iv
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let av = UIActivityIndicatorView(style: .large)
        av.color = Styling.foregroundPrimary
        av.translatesAutoresizingMaskIntoConstraints = false
        av.hidesWhenStopped = true
        return av
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        saveChangesButton.titleLabel.text = "vehicleProfile.addVehicle2.addButton".localized.uppercased()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func setupLayout() {
        super.setupLayout()
        addSubview(imageView)
        addSubview(activityIndicator)
        maxCharactersLabel.textAlignment = .center
        var constraints: [NSLayoutConstraint] = []
        topLabelConstraint?.isActive = false
        constraints.append(imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margins.top))
        constraints.append(imageView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32))
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    override public func save() {
        saveChangesButton.isEnabled = false
        viewModel?.name = textField.text ?? ""
        activityIndicator.startAnimating()
        delegate?.saveChanges()
    }
}
