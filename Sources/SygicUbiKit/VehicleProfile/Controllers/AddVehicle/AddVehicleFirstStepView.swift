import CryptoKit
import UIKit
import Swinject

// MARK: - AddVehicleFirstStepViewDelegate

protocol AddVehicleFirstStepViewDelegate: AnyObject {
    func didSelectCar(with type: VehicleType)
}

// MARK: - AddVehicleFirstStepView

class AddVehicleFirstStepView: UIView, InjectableType {
    private let margins = NSDirectionalEdgeInsets(top: 32, leading: 32, bottom: 32, trailing: 32)
    weak var delegate: AddVehicleFirstStepViewDelegate?
    var viewModel: VehicleProfileAddViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            viewModel.maxAllowedVehicles {[weak self] in
                guard let self = self else { return }
                self.maxVehiclesLabel.text = String(format: "vehicleProfile.addVehicle1.maxVehicleNote".localized, $0 - viewModel.numberOfVehicles)
            }
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 30)
        label.textColor = .foregroundPrimary
        label.text = "vehicleProfile.addVehicle1.title".localized
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.textColor = .foregroundPrimary
        label.text = "vehicleProfile.addVehicle1.subtitle".localized
        return label
    }()

    private lazy var middleStackView: UIStackView = {
       let stackView = UIStackView(arrangedSubviews: [carChooser, bikeChooser])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 24
        return stackView
    }()

    lazy var carChooser: VehicleProfileClassChooserControl = {
        let chooser = VehicleProfileClassChooserControl(frame: .zero)
        let carType = VehicleType.car
        chooser.configure(with: carType.localizedName, icon: carType.icon)
        chooser.addTarget(self, action: #selector(AddVehicleFirstStepView.carChoosen), for: .valueChanged)
        chooser.isSelected = true
        return chooser
    }()

    lazy var bikeChooser: VehicleProfileClassChooserControl = {
        let chooser = VehicleProfileClassChooserControl(frame: .zero)
        let carType = VehicleType.motorcycle
        chooser.configure(with: carType.localizedName, icon: carType.icon)
        chooser.addTarget(self, action: #selector(AddVehicleFirstStepView.bikeChoosen), for: .valueChanged)
        chooser.isSelected = true
        return chooser
    }()

    lazy var camperChooser: VehicleProfileClassChooserControl = {
        let chooser = VehicleProfileClassChooserControl(frame: .zero)
        let carType = VehicleType.camper
        chooser.configure(with: carType.localizedName, icon: carType.icon)
        chooser.addTarget(self, action: #selector(AddVehicleFirstStepView.camperChoosen), for: .valueChanged)
        chooser.isSelected = true
        chooser.translatesAutoresizingMaskIntoConstraints = false
        return chooser
    }()

    private lazy var maxVehiclesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        if let config = container.resolve(VehicleProfileConfigurable.self),
           config.displayMaxVehiclesNote {
            label.isHidden = false
        } else {
            label.isHidden = true
        }
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .backgroundPrimary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(middleStackView)
        addSubview(maxVehiclesLabel)
        addSubview(camperChooser)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margins.top))
        constraints.append(subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10))
        constraints.append(middleStackView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(middleStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32))
        constraints.append(camperChooser.centerXAnchor.constraint(equalTo: middleStackView.centerXAnchor))
        constraints.append(camperChooser.topAnchor.constraint(equalTo: middleStackView.bottomAnchor, constant: 24))
        constraints.append(maxVehiclesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins.leading))
        constraints.append(maxVehiclesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins.trailing))
        constraints.append(maxVehiclesLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32))
        NSLayoutConstraint.activate(constraints)
    }
}

extension AddVehicleFirstStepView {
    @objc
func carChoosen() {
        delegate?.didSelectCar(with: .car)
    }

    @objc
func bikeChoosen() {
        delegate?.didSelectCar(with: .motorcycle)
    }

    @objc
func camperChoosen() {
        delegate?.didSelectCar(with: .camper)
    }
}
