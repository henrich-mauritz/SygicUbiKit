import UIKit

public class TriplogMonthCardView: UIControl, TriplogOverviewMonthCardProtocol {
    public weak var delegate: TriplogMonthCardViewDelegate?

    public var viewModel: TriplogOverviewCardViewModelProtocol? {
        didSet {
            guard let viewModel = viewModel else { return }
            titleLabel.font = viewModel.isLongerPeriodCard ? UIFont.stylingFont(.bold, with: 12) : UIFont.stylingFont(.bold, with: 16)
            imageView.image = viewModel.image
            titleLabel.text = viewModel.title
            subtitleLabel.text = viewModel.kilometers
            scoreLabel.text = viewModel.score
        }
    }

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textColor = .foregroundPrimary
        label.textAlignment = .right
        return label
    }()

    public let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.textAlignment = .right
        return label
    }()

    public let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.thin, with: 30)
        label.textColor = .foregroundTertiary
        label.textAlignment = .right
        return label
    }()

    public let imageView: UIImageView = {
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

    private let margin: CGFloat = 16

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(scoreLabel)

        var constraints = [NSLayoutConstraint]()
        constraints.append(imageView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(imageView.topAnchor.constraint(equalTo: topAnchor))

        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8))

        constraints.append(subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0))
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin / 2))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin / 2))
        constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor))

        constraints.append(scoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constraints.append(scoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin / 2))
        constraints.append(scoreLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -margin / 2))

        NSLayoutConstraint.activate(constraints)
    }
}
