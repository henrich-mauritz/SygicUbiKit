import UIKit

class DetailSelectionCell: UITableViewCell, TripDetailPartialScoreEventCellProtocol {
    public let leftLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .itemTitleFont()
        label.textColor = .foregroundPrimary
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    public let arrowView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "disclosureIndicator", in: .module, compatibleWith: nil))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public var hasIndicator: Bool {
        set {
            arrowView.isHidden = !newValue
            if newValue == false {
                trailingAnchorIntesityView.constant = arrowView.frame.width
            } else {
                trailingAnchorIntesityView.constant = -8
            }
        }

        get {
            !arrowView.isHidden
        }
    }

    public var hideSeparator: Bool {
        set {
            separatorView.isHidden = newValue
        }
        get {
            separatorView.isHidden
        }
    }

    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.isHidden = true
        return view
    }()

    let intensityView: IntensityView = IntensityView()
    private lazy var trailingAnchorIntesityView: NSLayoutConstraint = {
        let constraint = intensityView.trailingAnchor.constraint(equalTo: arrowView.leadingAnchor, constant: -8)
        return constraint
    }()

    let labelMargin: CGFloat = 32
    private let arrowMargin: CGFloat = 24

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        selectedBackgroundView = view
        backgroundColor = .clear
        hasIndicator = true
        hideSeparator = true
        contentView.addSubview(intensityView)
        contentView.addSubview(leftLabel)
        contentView.addSubview(arrowView)
        contentView.addSubview(separatorView)
        intensityView.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()

        constraints.append(leftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: labelMargin))
        constraints.append(leftLabel.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(leftLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -10))

        constraints.append(trailingAnchorIntesityView)
        constraints.append(intensityView.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(intensityView.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -10))
        constraints.append(intensityView.leadingAnchor.constraint(equalTo: leftLabel.trailingAnchor, constant: 5))
        constraints.append(arrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -arrowMargin))
        constraints.append(arrowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))

        constraints.append(separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: arrowMargin))
        constraints.append(separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -arrowMargin))
        constraints.append(separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with eventString: String, severnity: SevernityLevel?, time: String? = nil) {
        leftLabel.text = eventString
        intensityView.isHidden = severnity == nil
        if let severityLevel = severnity {
            intensityView.severnity = severityLevel
        }
    }
}
