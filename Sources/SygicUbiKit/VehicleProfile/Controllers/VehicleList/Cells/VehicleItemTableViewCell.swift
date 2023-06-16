import UIKit

class VehicleItemTableViewCell: UITableViewCell {
    private let margins: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)

    private lazy var carIcon: UIImageView = {
        let carimageView = UIImageView()
        carimageView.translatesAutoresizingMaskIntoConstraints = false
        carimageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        carimageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        carimageView.tintColor = .foregroundPrimary
        carimageView.contentMode = .scaleAspectFit
        return carimageView
    }()

    private lazy var carName: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: NSLayoutConstraint.Axis.horizontal)
        return label
    }()

    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private lazy var stateContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 14
        view.heightAnchor.constraint(equalToConstant: 28).isActive = true
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
        contentView.addSubview(carIcon)
        contentView.addSubview(carName)
        contentView.addSubview(disclosureIcon)
        contentView.addSubview(stateContainer)
        stateContainer.cover(with: stateLabel, insets: NSDirectionalEdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
        var constraints: [NSLayoutConstraint] = []
        constraints.append(carIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margins.leading))
        constraints.append(carIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margins.top))
        constraints.append(carIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margins.bottom))
        constraints.append(carName.leadingAnchor.constraint(equalTo: carIcon.trailingAnchor, constant: 16))
        constraints.append(carName.centerYAnchor.constraint(equalTo: carIcon.centerYAnchor))
        constraints.append(carName.trailingAnchor.constraint(equalTo: stateContainer.leadingAnchor, constant: 16))
        constraints.append(stateContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(stateContainer.trailingAnchor.constraint(equalTo: disclosureIcon.leadingAnchor, constant: -5))
        constraints.append(disclosureIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(disclosureIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(margins.trailing + 8)))
        NSLayoutConstraint.activate(constraints)
    }

    public func update(with vehicle: NetworkVehicle) {
        carIcon.image = vehicle.vehicleType.icon
        carName.text = vehicle.name.uppercased()
        if vehicle.state == .active {
            stateLabel.text = "vehicleProfile.overview.active".localized
            stateContainer.backgroundColor = .positivePrimary
        } else {
            stateContainer.backgroundColor = .negativeSecondary
            stateLabel.text = "vehicleProfile.overview.inactive".localized
        }
    }
}
