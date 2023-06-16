import Foundation
import UIKit

// MARK: - MonthlyStatsOverviewCellViewModelType

public protocol MonthlyStatsOverviewCellViewModelType {
    var monthImage: UIImage { get }
    var monthScore: String { get }
    var description: NSAttributedString { get }
    var state: ReportScoreMonthComparision { get }
}

// MARK: - MonthlyStatsOverviewCell

class MonthlyStatsOverviewCell: BubbleTableViewCell {
    let monthImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .backgroundSecondary
        imageView.layer.cornerRadius = Styling.cornerRadius
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.heightAnchor.constraint(equalToConstant: 216).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 136).isActive = true
        return imageView
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.numberOfLines = 0
        return label
    }()

    let scoreView: OverviewScoreView = OverviewScoreView()

    let statusIndicator: ScoreStatusIndicatorView = ScoreStatusIndicatorView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with viewModel: MonthlyStatsOverviewCellViewModelType) {
        monthImageView.image = viewModel.monthImage
        scoreView.scoreLabel.text = viewModel.monthScore
        descriptionLabel.attributedText = viewModel.description
        statusIndicator.update(with: viewModel.state)
    }

    private func setupLayout() {
        monthImageView.translatesAutoresizingMaskIntoConstraints = false
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainerView.removeFromSuperview()
        contentView.addSubview(bubbleContainerView)
        bubbleContainerView.addSubview(monthImageView)
        bubbleContainerView.addSubview(scoreView)
        bubbleContainerView.addSubview(descriptionLabel)
        bubbleContainerView.addSubview(statusIndicator)
        var constrains: [NSLayoutConstraint] = []
        constrains.append(bubbleContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constrains.append(bubbleContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constrains.append(bubbleContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin))
        constrains.append(monthImageView.leadingAnchor.constraint(equalTo: bubbleContainerView.leadingAnchor, constant: margin))
        constrains.append(monthImageView.topAnchor.constraint(equalTo: bubbleContainerView.topAnchor, constant: -62))
        constrains.append(monthImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin))
        constrains.append(scoreView.leadingAnchor.constraint(equalTo: monthImageView.trailingAnchor, constant: margin * 2))
        constrains.append(scoreView.bottomAnchor.constraint(equalTo: monthImageView.bottomAnchor, constant: -margin))
        constrains.append(descriptionLabel.leadingAnchor.constraint(equalTo: bubbleContainerView.leadingAnchor, constant: margin))
        constrains.append(descriptionLabel.trailingAnchor.constraint(equalTo: bubbleContainerView.trailingAnchor, constant: -margin))
        constrains.append(descriptionLabel.topAnchor.constraint(equalTo: monthImageView.bottomAnchor, constant: margin * 1.5))
        constrains.append(descriptionLabel.bottomAnchor.constraint(equalTo: bubbleContainerView.bottomAnchor, constant: -margin * 2))
        constrains.append(statusIndicator.topAnchor.constraint(equalTo: bubbleContainerView.topAnchor, constant: margin))
        constrains.append(statusIndicator.trailingAnchor.constraint(equalTo: bubbleContainerView.trailingAnchor, constant: -margin))
        NSLayoutConstraint.activate(constrains)
    }
}

// MARK: - OverviewScoreView

class OverviewScoreView: UIStackView {
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.thin, with: 80)
        label.textAlignment = .center
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "monthlyStats.overview.overallScore".localized
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        spacing = 0
        addArrangedSubview(scoreLabel)
        addArrangedSubview(descriptionLabel)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
