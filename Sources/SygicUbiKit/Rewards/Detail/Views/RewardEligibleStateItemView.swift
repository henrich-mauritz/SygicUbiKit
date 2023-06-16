import UIKit

// MARK: - RewardEligibleStateItemViewDelegate

protocol RewardEligibleStateItemViewDelegate: AnyObject {
    func didTapGetReward()
}

// MARK: - RewardEligibleStateItemView

class RewardEligibleStateItemView: UIView {
    private let margin: CGFloat = 16

    private lazy var roundedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Styling.cornerRadiusModalPopup
        view.clipsToBounds = true
        view.backgroundColor = .backgroundSecondary
        return view
    }()

    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 36).isActive = true
        view.backgroundColor = Styling.backgroundTertiary
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.textAlignment = .center
        label.text = "rewards.eligible.title".localized
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "rewards.eligible.subtitle".localized
        return label
    }()

    private lazy var getRewardButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel.text = "rewards.eligible.button".localized.uppercased()
        button.addTarget(self, action: #selector(getRewwardTapped), for: .touchUpInside)
        return button
    }()

    public weak var delegate: RewardEligibleStateItemViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func toggleButtonEnabled(value: Bool) {
        getRewardButton.isEnabled = value
    }

    private func setupLayout() {
        cover(with: roundedView, insets: NSDirectionalEdgeInsets(top: 8, leading: margin, bottom: 8, trailing: margin))
        titleView.addSubview(titleLabel)
        roundedView.addSubview(titleView)
        roundedView.addSubview(detailLabel)
        roundedView.addSubview(getRewardButton)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor))
        constraints.append(titleView.topAnchor.constraint(equalTo: roundedView.topAnchor))
        constraints.append(titleView.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor))
        constraints.append(titleView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor))
        constraints.append(detailLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: margin))
        constraints.append(detailLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 24))
        constraints.append(detailLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -24))
        constraints.append(detailLabel.bottomAnchor.constraint(equalTo: getRewardButton.topAnchor, constant: -margin))
        constraints.append(getRewardButton.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: margin))
        constraints.append(getRewardButton.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -margin))
        constraints.append(getRewardButton.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor, constant: -margin))

        NSLayoutConstraint.activate(constraints)
    }

    @objc private func getRewwardTapped() {
        toggleButtonEnabled(value: false)
        delegate?.didTapGetReward()
    }
}
