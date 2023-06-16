import UIKit

class DiscountProgressTableViewCell: UITableViewCell {
    public static let cellReuseIdentifier: String = "ProgressCellReuseIdentifier"

    public let label: UILabel = {
        let label = UILabel()
        label.font = .itemTitleFont()
        label.textColor = .foregroundPrimary
        return label
    }()

    public lazy var offSeasonLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.isHidden = true
        label.text = "discounts.progressOffseason".localized
        label.textAlignment = .center
        return label
    }()

    public var start: Bool = false {
        willSet {
            if newValue == true {
                stackView.start = true
                label.text = "discounts.monthlyProgress.initialChallenge".localized
            }
        }
    }

    public var firstValue: String {
        set {
            stackView.firstValue = newValue
        }

        get {
            return stackView.firstValue
        }
    }

    public var secondValue: String {
        set {
            stackView.secondValue = newValue
        }

        get {
            return stackView.secondValue
        }
    }

    public var firstState: DiscountProgressType {
        set {
            stackView.firstState = newValue
        }

        get {
            return stackView.firstState
        }
    }

    public var secondState: DiscountProgressType {
        set {
            stackView.secondState = newValue
        }

        get {
            return stackView.secondState
        }
    }

    public lazy var selectorView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = Styling.cornerRadius
        view.isHidden = true
        return view
    }()

    private let stackView: BubbleStackView = BubbleStackView()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        view.isHidden = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        offSeasonLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        contentView.addSubview(separator)
        contentView.addSubview(stackView)
        contentView.addSubview(offSeasonLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stackView.reset()
        label.font = .itemTitleFont()
        selectorView.isHidden = true
        stackView.secondBubble.backgroundColor = Styling.backgroundSecondary
        stackView.isHidden = false
        offSeasonLabel.isHidden = true
    }

    public func prepareUIForOffSeason() {
        stackView.isHidden = true
        offSeasonLabel.isHidden = false
    }

    private func setupConstraints() {
        contentView.cover(with: selectorView)
        contentView.sendSubviewToBack(selectorView)
        var constraints = [label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin)]
        constraints.append(label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin / 2.0))
        constraints.append(label.bottomAnchor.constraint(equalTo: separator.topAnchor, constant: -margin))
        constraints.append(separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin / 2.0))
        constraints.append(separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin / 2.0))
        constraints.append(separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin / 2.0))
        constraints.append(stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(offSeasonLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor))
        constraints.append(offSeasonLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor))
        constraints.append(offSeasonLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    public func configureCurrenChalengeState() {
        label.font = .stylingFont(.bold, with: 16)
        selectorView.isHidden = false
        stackView.secondBubble.backgroundColor = Styling.backgroundTertiary
    }
}
