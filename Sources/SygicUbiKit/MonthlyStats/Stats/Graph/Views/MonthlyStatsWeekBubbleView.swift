import UIKit

class MonthlyStatsWeekBubbleView: UIView {
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundTertiary
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: contentView)
        contentView.cover(with: titleLabel, insets: NSDirectionalEdgeInsets(top: 3, leading: 2, bottom: 3, trailing: 2))
        widthAnchor.constraint(equalToConstant: 52).isActive = true
    }
}
