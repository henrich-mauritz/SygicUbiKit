import Foundation
import UIKit

class MonthlyStatsMonthSelectorCell: UITableViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundSecondary
        label.textAlignment = .left
        return label
    }()

    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundSecondary
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    let stateIndicator: ScoreStatusIndicatorView = ScoreStatusIndicatorView()

    let accessoryArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "iconsTriglavArrowSmall", in: .module, compatibleWith: nil)
        imageView.tintColor = .actionPrimary
        return imageView
    }()

    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .backgroundPrimary
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stateIndicator.isHidden = false
        accessoryArrowImageView.isHidden = false
        titleLabel.alpha = 1.0
    }

    func update(with month: MonthSelectorItem) {
        titleLabel.text = month.title
        scoreLabel.text = month.score
        guard let _ = month.score else {
            stateIndicator.isHidden = true
            accessoryArrowImageView.isHidden = true
            titleLabel.alpha = Styling.disabledStateAlpha
            return
        }
        stateIndicator.update(with: month.state)
    }

    private func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        stateIndicator.translatesAutoresizingMaskIntoConstraints = false
        accessoryArrowImageView.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)
        contentView.addSubview(accessoryArrowImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(scoreLabel)
        contentView.addSubview(stateIndicator)
        var constrains: [NSLayoutConstraint] = []
        constrains.append(contentView.heightAnchor.constraint(equalToConstant: 52))
        constrains.append(titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constrains.append(scoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constrains.append(stateIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constrains.append(titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constrains.append(scoreLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10))
        constrains.append(stateIndicator.leadingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: 10))
        constrains.append(stateIndicator.trailingAnchor.constraint(equalTo: accessoryArrowImageView.leadingAnchor, constant: -10))
        constrains.append(accessoryArrowImageView.widthAnchor.constraint(equalToConstant: 11))
        constrains.append(accessoryArrowImageView.heightAnchor.constraint(equalToConstant: 11))
        constrains.append(accessoryArrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constrains.append(accessoryArrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constrains.append(separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constrains.append(separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constrains.append(separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        NSLayoutConstraint.activate(constrains)
    }
}
