import Foundation
import UIKit

class MonthlyStatsOtherCollectionCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.thin, with: 36)
        label.textAlignment = .left
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textAlignment = .left
        return label
    }()

    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = Styling.cornerRadius
        return view
    }()

    let margin: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with stat: MonthlyOtherStatType) {
        titleLabel.text = stat.value
        descriptionLabel.text = stat.description
    }

    private func setupLayout() {
        cover(with: bubbleView)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        cover(with: stackView, insets: NSDirectionalEdgeInsets(top: margin, leading: margin * 2, bottom: margin, trailing: margin * 2))
    }
}
