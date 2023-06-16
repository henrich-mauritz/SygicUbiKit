
import UIKit

class VehicleDetailNameTableViewCell: UITableViewCell {
    private let margins: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)

    private lazy var profileNameTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        label.text = "vehicleProfile.addVehicle2.title".localized
        return label
    }()

    private lazy var carName: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    public lazy var disclosureIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .actionPrimary
        imageView.image = UIImage(named: "disclosureIndicator", in: .module, compatibleWith: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setuplayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setuplayout() {
        backgroundColor = .backgroundPrimary
        contentView.addSubview(profileNameTitleLabel)
        contentView.addSubview(carName)
        contentView.addSubview(disclosureIcon)
        contentView.addSubview(separator)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(profileNameTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margins.top))
        constraints.append(profileNameTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margins.leading))
        constraints.append(profileNameTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margins.bottom))
        constraints.append(carName.centerYAnchor.constraint(equalTo: profileNameTitleLabel.centerYAnchor))
        constraints.append(carName.trailingAnchor.constraint(equalTo: disclosureIcon.leadingAnchor, constant: -5))
        constraints.append(disclosureIcon.centerYAnchor.constraint(equalTo: profileNameTitleLabel.centerYAnchor))
        constraints.append(disclosureIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(margins.trailing + 8)))
        constraints.append(separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16))
        constraints.append(separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16))
        constraints.append(separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    public func update(with vehicle: NetworkVehicle) {
        carName.text = vehicle.name.uppercased()
    }
}
