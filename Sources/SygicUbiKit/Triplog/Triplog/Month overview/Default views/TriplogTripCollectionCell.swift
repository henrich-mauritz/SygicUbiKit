import UIKit

public class TriplogTripCollectionCell: UICollectionViewCell, TriplogTripCollectiocCellProtocol {
    public let destinationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.bold, with: titleSize)
        return label
    }()

    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = UIFont.itemTitleFont()
        return label
    }()

    public let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundTertiary
        label.font = UIFont.itemTitleFont()
        return label
    }()

    public let scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundTertiary
        label.font = UIFont.stylingFont(.thin, with: scoreSize)
        return label
    }()

    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var labelStack: UIStackView = {
        let labelStack = UIStackView()
        labelStack.spacing = 0
        labelStack.axis = .vertical
        labelStack.addArrangedSubview(destinationLabel)
        labelStack.addArrangedSubview(descriptionLabel)
        return labelStack
    }()

    private lazy var contentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        view.clipsToBounds = true
        view.layer.cornerRadius = Styling.cornerRadius
        return view
    }()

    private lazy var gradientView: GradientDrawView = {
        let view = GradientDrawView()
        view.colors = [UIColor.backgroundOverlay.withAlphaComponent(0), UIColor.backgroundOverlay]
        return view
    }()

    private var imageUrlString: String?

    private static let titleSize: CGFloat = 16
    private static let scoreSize: CGFloat = 28
    private let margin: CGFloat = 10
    private let margin2: CGFloat = 8
    private let gradientHeight: CGFloat = 56

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        imageView.image = nil
        imageUrlString = nil
        dateLabel.text = ""
        scoreLabel.text = ""
        descriptionLabel.text = ""
        destinationLabel.text = ""
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        contentContainer.layer.cornerRadius = Styling.cornerRadius
    }

    override public var reuseIdentifier: String? {
        return TriplogTripCollectionCell.cellIdentifier
    }

    public func update(with viewModel: TriplogTripCardViewModelProtocol) {
        dateLabel.text = viewModel.dateText
        scoreLabel.text = viewModel.scoreText
        destinationLabel.text = viewModel.destinationText
        descriptionLabel.text = viewModel.descriptionText
        imageUrlString = viewModel.imageUrl
        loadTripImage()
    }

    private func loadTripImage() {
        guard let imagePath = imageUrlString else {
            self.imageView.image = UIImage(named: "tripPicture", in: .module, compatibleWith: nil)
            return
        }
        UIImage.loadImage(from: imagePath) { [weak self] loadedUrl, image, _ in
            guard self?.imageUrlString == loadedUrl else { return }
            self?.imageView.image = image
        }
    }

    private func setupLayout() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentContainer)
        imageView.addSubview(gradientView)
        gradientView.addSubview(dateLabel)
        gradientView.addSubview(scoreLabel)
        contentContainer.addSubview(imageView)
        contentContainer.addSubview(imageView)
        contentContainer.addSubview(imageView)
        contentContainer.addSubview(labelStack)

        var constraints = [NSLayoutConstraint]()
        constraints.append(contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
        constraints.append(contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor))
        constraints.append(contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor))

        constraints.append(imageView.topAnchor.constraint(equalTo: contentContainer.topAnchor))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor))

        constraints.append(imageView.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor))
        constraints.append(gradientView.heightAnchor.constraint(equalToConstant: gradientHeight))

        constraints.append(gradientView.bottomAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: margin2 / 2))
        constraints.append(gradientView.trailingAnchor.constraint(equalTo: scoreLabel.trailingAnchor, constant: margin2))

        constraints.append(dateLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: margin2))
        constraints.append(dateLabel.lastBaselineAnchor.constraint(equalTo: scoreLabel.lastBaselineAnchor))

        constraints.append(labelStack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: margin))
        constraints.append(labelStack.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -margin))
        constraints.append(labelStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: margin))
        constraints.append(labelStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -margin))
        NSLayoutConstraint.activate(constraints)
    }
}
