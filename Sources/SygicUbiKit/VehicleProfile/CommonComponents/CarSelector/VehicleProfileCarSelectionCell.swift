import UIKit

class VehicleProfileCarSelectionCell: UITableViewCell {
    private lazy var innerStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 13
        return stackView
    }()

    private lazy var bubbledContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .actionPrimary //can change upon update
        view.layer.cornerRadius = Styling.cornerRadius
        view.layer.masksToBounds = false
        view.widthAnchor.constraint(equalToConstant: 296).isActive = true
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }()

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.alpha = Styling.highlightedStateAlpha
        } else {
            self.alpha = 1
        }
    }

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .foregroundPrimary
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel.stylingLabel(with: .bold, size: 16, textColor: .foregroundPrimary)
        label.textAlignment = .center
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        let sv = UIView()
        sv.backgroundColor = .clear
        self.selectedBackgroundView = sv
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.addSubview(bubbledContentView)
        //innerStackView.addArrangedSubview(iconImageView) //Icons might come later
        innerStackView.addArrangedSubview(nameLabel)
        bubbledContentView.cover(with: innerStackView, insets: NSDirectionalEdgeInsets(top: 11, leading: 13, bottom: 11, trailing: 13))
        var constraints: [NSLayoutConstraint] = []
        constraints.append(bubbledContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8))
        constraints.append(bubbledContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8))
        constraints.append(bubbledContentView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    func update(with vehicle: VehicleProfileType, selected: Bool) {
        nameLabel.text = vehicle.name.uppercased()
        iconImageView.image = vehicle.vehicleType.icon
        if selected {
            bubbledContentView.backgroundColor = Styling.actionPrimary
        } else {
            bubbledContentView.backgroundColor = Styling.buttonBackgroundModalSecondary
        }
    }
}
