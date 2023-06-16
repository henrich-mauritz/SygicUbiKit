import UIKit

public class RewardRequirementItemView: UIView {
    private let margin: CGFloat = 16

    private lazy var roundedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Styling.cornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .backgroundSecondary
        return view
    }()

    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 30).isActive = true
        titleLabel.textColor = Styling.foregroundTertiary
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.bold, with: 14)
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.numberOfLines = 0
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
        cover(with: roundedView, insets: NSDirectionalEdgeInsets(top: 8, leading: margin, bottom: 8, trailing: margin))
        titleView.addSubview(titleLabel)
        roundedView.addSubview(titleView)
        roundedView.addSubview(detailLabel)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: margin))
        constraints.append(titleView.topAnchor.constraint(equalTo: roundedView.topAnchor))
        constraints.append(titleView.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor))
        constraints.append(titleView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor))
        constraints.append(detailLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: margin))
        constraints.append(detailLabel.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor, constant: -margin))
        constraints.append(detailLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: margin))
        constraints.append(detailLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -margin))
        NSLayoutConstraint.activate(constraints)
    }

    public func addRequirement(_ description: String, fullfilled: Bool) {
        detailLabel.text = description
        var text: String = "rewards.detail.toFulfill".localized
        var color: UIColor = .backgroundTertiary
        if fullfilled {
            text = "rewards.detail.fulfilled".localized
            color = .positivePrimary
        }
        titleView.backgroundColor = color
        titleLabel.text = text
    }
}
