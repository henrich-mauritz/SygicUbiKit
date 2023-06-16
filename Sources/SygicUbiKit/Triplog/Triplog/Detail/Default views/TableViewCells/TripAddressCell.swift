import UIKit

class TripAddressCell: UITableViewCell, TripDetailAddressCellProtocol {
    public var startAddress: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = .itemTitleFont()
        return label
    }()

    public var startDate: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = .itemTitleFont()
        return label
    }()

    public var endAddress: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = .itemTitleFont()
        return label
    }()

    public var endDate: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = .itemTitleFont()
        return label
    }()

    private let leadingMargin: CGFloat = 14
    private let trailingMargin: CGFloat = 58
    private let topMargin: CGFloat = 10

    private let startStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 3
        view.alignment = .leading
        view.distribution = .fill
        return view
    }()

    private let endStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 3
        view.alignment = .leading
        view.distribution = .fill
        return view
    }()

    private let iconStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        view.alignment = .center
        view.distribution = .fillProportionally
        view.addArrangedSubview(StartAddressIconView())
        view.addArrangedSubview(ArrowAddressIconView())
        view.addArrangedSubview(EndAddressIconView())
        return view
    }()

    required init() {
        super.init(style: .default, reuseIdentifier: nil)
        backgroundColor = .clear
        isUserInteractionEnabled = false
        contentView.addSubview(startStackView)
        startStackView.addArrangedSubview(startAddress)
        startStackView.addArrangedSubview(startDate)
        contentView.addSubview(endStackView)
        endStackView.addArrangedSubview(endAddress)
        endStackView.addArrangedSubview(endDate)
        contentView.addSubview(iconStackView)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        startStackView.translatesAutoresizingMaskIntoConstraints = false
        endStackView.translatesAutoresizingMaskIntoConstraints = false
        iconStackView.translatesAutoresizingMaskIntoConstraints = false
        //address label constraints
        var constraints = [iconStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2 * topMargin)]
        constraints.append(iconStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: leadingMargin))
        constraints.append(iconStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26))
        constraints.append(iconStackView.widthAnchor.constraint(equalToConstant: 16))

        constraints.append(startStackView.leadingAnchor.constraint(equalTo: iconStackView.trailingAnchor, constant: leadingMargin))
        constraints.append(startStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -trailingMargin))
        constraints.append(startStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topMargin))
        constraints.append(startStackView.bottomAnchor.constraint(equalTo: endStackView.topAnchor, constant: -22))

        constraints.append(endStackView.leadingAnchor.constraint(equalTo: iconStackView.trailingAnchor, constant: leadingMargin))
        constraints.append(endStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -trailingMargin))
        constraints.append(endStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -topMargin))

        NSLayoutConstraint.activate(constraints)
    }
}
