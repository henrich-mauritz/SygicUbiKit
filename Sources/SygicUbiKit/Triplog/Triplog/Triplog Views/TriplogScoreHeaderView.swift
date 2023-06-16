import UIKit

public class TriplogScoreHeaderView: UIView {
    public let leftTitleLabel: UILabel? = {
        createStatsLabel()
    }()

    public let rightTitleLabel: UILabel? = {
        createStatsLabel()
    }()

    public let leftDescriptionLabel: UILabel = {
        let label = createDescriptionLabel()
        return label
    }()

    public let rightDescriptionLabel: UILabel = {
        let label = createDescriptionLabel()
        return label
    }()

    private static let statsFontSize: CGFloat = 36
    private lazy var innerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private lazy var scoreStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private lazy var distanceStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    private let margin: CGFloat = 16

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        guard let scoreLabel = leftTitleLabel, let distanceLabel = rightTitleLabel else { return }

        cover(with: innerStackView, insets: NSDirectionalEdgeInsets(top: 0, leading: margin, bottom: 0, trailing: margin))

        scoreStack.addArrangedSubview(scoreLabel)
        scoreStack.addArrangedSubview(leftDescriptionLabel)

        distanceStack.addArrangedSubview(distanceLabel)
        distanceStack.addArrangedSubview(rightDescriptionLabel)

        innerStackView.addArrangedSubview(scoreStack)
        innerStackView.addArrangedSubview(distanceStack)
    }

    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.itemTitleFont()
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.heightAnchor.constraint(equalToConstant: 18).isActive = true
        return label
    }

    private static func createStatsLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.thin, with: statsFontSize)
        label.adjustsFontSizeToFitWidth = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    func configure(with visuals: TriplogOverviewViewVisualsConfigurable) {
        if visuals.displayOverviewScore == false {
            if scoreStack.superview != nil {
                innerStackView.removeArrangedSubview(scoreStack)
                scoreStack.removeFromSuperview()
            }
        }
        if visuals.displayDistanceValue == false {
            if distanceStack.superview != nil {
                innerStackView.removeArrangedSubview(distanceStack)
                distanceStack.removeFromSuperview()
            }
        }
    }
}
