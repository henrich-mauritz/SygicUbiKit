import Foundation
import UIKit

class BasicTableViewCell: UITableViewCell {
    public static let cellIdentifier: String = "BasicTableViewCell"
    public static let cellHeight: CGFloat = 56
    /// Use this property to set the icon in the cell, default it is disabled
    public var iconColor: UIColor? {
        didSet {
            colorView.isHidden = false
            colorView.backgroundColor = iconColor
        }
    }

    private let colorView: UIView = {
        let colorView = UIView()
        colorView.isHidden = true
        colorView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        colorView.layer.cornerRadius = 4
        return colorView
    }()

    public let leftLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .itemTitleFont()
        label.textColor = .foregroundPrimary
        return label
    }()

    public let rightLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .itemTitleFont()
        label.textColor = .foregroundPrimary
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(colorView)
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(rightLabel)
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.addSubview(stackView)
        var constraints = [NSLayoutConstraint]()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        constraints.append(stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8))
        constraints.append(stackView.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        let height = stackView.heightAnchor.constraint(equalToConstant: 56)
        height.priority = .defaultLow
        constraints.append(height)

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
