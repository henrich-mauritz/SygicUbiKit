import UIKit

class BasicTriplogTableViewCell: UITableViewCell, TripDetailCellProtocol, TripDetailEventCellProtocol {
    public static let cellIdentifier: String = "BasicTableViewCell"
    public static let cellHeight: CGFloat = 56

    /// Use this property to set the icon in the cell, default it is disabled
    public var iconColor: UIColor? {
        didSet {
            colorView.isHidden = false
            colorView.backgroundColor = iconColor
        }
    }

    public var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.isHidden = true //for now hidden
        return view
    }()

    public lazy var disclosureIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .actionPrimary
        imageView.image = UIImage(named: "disclosureIndicator", in: .module, compatibleWith: nil)
        return imageView
    }()

    public let colorView: UIView = {
        let colorView = UIView()
        colorView.isHidden = true
        colorView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        colorView.layer.cornerRadius = 9
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

    public lazy var stackView: UIStackView = {
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

    public var stackViewTrailingAnchor: NSLayoutConstraint?
    public var stackViewLeadingAnchor: NSLayoutConstraint?

    private let separatorInsets: CGFloat = 24

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        selectedBackgroundView = view
        backgroundColor = .clear
        tintColor = .actionPrimary
        contentView.addSubview(separatorView)
        contentView.addSubview(stackView)
        var constraints = [NSLayoutConstraint]()

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackViewLeadingAnchor = stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
        constraints.append(stackViewLeadingAnchor!)
        constraints.append(stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        constraints.append(stackView.topAnchor.constraint(equalTo: contentView.topAnchor))
        stackViewTrailingAnchor = stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -separatorInsets)
        constraints.append(stackViewTrailingAnchor!)
        let height = stackView.heightAnchor.constraint(equalToConstant: Self.cellHeight)
        height.priority = .defaultLow
        constraints.append(height)
        constraints.append(separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: separatorInsets))
        constraints.append(separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -separatorInsets))
        constraints.append(separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
