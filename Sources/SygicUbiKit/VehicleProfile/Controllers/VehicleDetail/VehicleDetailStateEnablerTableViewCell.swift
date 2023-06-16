import UIKit

// MARK: - VehicleDetailStateEnablerTableViewCell

public class VehicleDetailStateEnablerTableViewCell: UITableViewCell {
    private let margins: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)

    private var valChangedCallBack: ((Bool) -> ())?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "vehicleProfile.edit.statusTitle".localized
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary.withAlphaComponent(0.4)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = ""
        return label
    }()

    private lazy var separator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    lazy var switchControl: UISwitch = {
        let switchC = UISwitch()
        switchC.addTarget(self, action: #selector(VehicleDetailStateEnablerTableViewCell.switchStateChanged), for: .valueChanged)
        switchC.translatesAutoresizingMaskIntoConstraints = false
        return switchC
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
        backgroundColor = .backgroundPrimary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(switchControl)
        contentView.addSubview(separator)
        contentView.addSubview(statusLabel)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margins.leading))
        constraints.append(statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor))
        constraints.append(statusLabel.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -10))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -5))
        constraints.append(switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margins.trailing))
        constraints.append(switchControl.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor))
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor))
        constraints.append(subtitleLabel.topAnchor.constraint(equalTo: switchControl.bottomAnchor, constant: 2))
        constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: switchControl.trailingAnchor))
        constraints.append(separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16))
        constraints.append(separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16))
        constraints.append(separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    public func update(state: VehicleState, when valueChanged: @escaping ((Bool) -> ())) {
        if state == .active {
            statusLabel.text = "vehicleProfile.edit.statusValueActive".localized
            switchControl.isOn = true
            subtitleLabel.text = "vehicleProfile.edit.statusSubtitleActive".localized
        } else {
            statusLabel.text = "vehicleProfile.edit.statusValueInactive".localized
            switchControl.isOn = false
            subtitleLabel.text = "vehicleProfile.edit.statusSubtitleInactive".localized
        }
        valChangedCallBack = valueChanged
    }
}

extension VehicleDetailStateEnablerTableViewCell {
    @objc
func switchStateChanged() {
        guard let valChanged = self.valChangedCallBack else { return }
        valChanged(switchControl.isOn)
    }
}
