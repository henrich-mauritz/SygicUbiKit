import Foundation
import UIKit

public class DiscountDetailCell: UITableViewCell {
    public static let cellReuseIdentifier = "DiscountDetailCell"

    public let icon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .foregroundPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    public lazy var disclosureIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .actionPrimary
        imageView.image = UIImage(named: "disclosureIndicator", in: .module, compatibleWith: nil)!
        return imageView
    }()

    public let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.isHidden = true
        return view
    }()

    private let height: CGFloat = 55

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        selectedBackgroundView = view
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        backgroundColor = .clear
        icon.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        disclosureIcon.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(disclosureIcon)
        addSubview(separatorView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentView.heightAnchor.constraint(equalToConstant: height))
        constraints.append(icon.widthAnchor.constraint(equalToConstant: 22))
        constraints.append(icon.heightAnchor.constraint(equalToConstant: 22))
        constraints.append(disclosureIcon.widthAnchor.constraint(equalToConstant: 16))
        constraints.append(disclosureIcon.heightAnchor.constraint(equalToConstant: 16))
        constraints.append(icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constraints.append(icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: margin))
        constraints.append(titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(disclosureIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constraints.append(disclosureIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(separatorView.heightAnchor.constraint(equalToConstant: 0.5))
        constraints.append(separatorView.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constraints.append(separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin))
        NSLayoutConstraint.activate(constraints)
    }
}
