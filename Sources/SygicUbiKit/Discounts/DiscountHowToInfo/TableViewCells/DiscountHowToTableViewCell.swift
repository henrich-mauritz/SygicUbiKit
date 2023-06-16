import UIKit

class DiscountHowToTableViewCell: UITableViewCell {
    public static let cellReuseIdentifier: String = "DiscountHowToTableViewCell"

    public let title: UILabel = {
        let label = UILabel()
        label.font = .stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    public let subtitle: UILabel = {
        let label = UILabel()
        label.font = .itemTitleFont()
        label.textColor = .foregroundPrimary
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .top
        view.spacing = 10
        view.distribution = .fill
        return view
    }()

    private let fillerView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 10).isActive = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        isUserInteractionEnabled = false
        backgroundColor = .clear
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(subtitle)
        stackView.addArrangedSubview(fillerView)
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupConstraints() {
        var constraints = [stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)]
        constraints.append(stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }
}
