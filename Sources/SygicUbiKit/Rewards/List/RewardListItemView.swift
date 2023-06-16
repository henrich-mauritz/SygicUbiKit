import UIKit

// MARK: - RewardCellProtocol

public protocol RewardCellProtocol {
    func update(with viewModel: InfoItemType)
}

// MARK: - RewardCell

public class RewardCell: UITableViewCell, InjectableType, RewardCellProtocol {
    //MARK: - Properties

    public let thumbnailViewContainer: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.widthAnchor.constraint(equalToConstant: 100).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        return view
    }()

    public let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    public let rewardCodeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    public let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.numberOfLines = 1
        return label
    }()

    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.numberOfLines = 3
        return label
    }()

    public let contentStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        contentStackView.alignment = .fill
        contentStackView.spacing = 2
        contentStackView.distribution = .equalSpacing
        return contentStackView
    }()

    private let contnetSVViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let rootStackView: UIStackView = {
        let rsv = UIStackView()
        rsv.axis = .horizontal
        rsv.isLayoutMarginsRelativeArrangement = true
        rsv.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
        rsv.spacing = 14
        rsv.translatesAutoresizingMaskIntoConstraints = false
        return rsv
    }()

    public var spacerTop = UIView()
    public lazy var spacerBottom: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()

    private var imageUri: String?

    //MARK: - LifeCycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        selectedBackgroundView = view
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override open func prepareForReuse() {
        imageUri = nil
        thumbnailImageView.image = nil
        titleLabel.text = ""
        subtitleLabel.text = ""
        descriptionLabel.text = ""
        requirementsStack.removeAll()
    }

    open func update(with viewModel: InfoItemType) {
        spacerBottom.removeFromSuperview()
        contentStackView.removeArrangedSubview(spacerBottom)
        updateBasicInfo(with: viewModel)

        guard let viewModel = viewModel as? RewardViewModelProtocol else {
            contentStackView.addArrangedSubview(spacerBottom)
            return
        }

        if let rewardCode = viewModel.rewardCode {
            updateLabel(rewardCodeLabel, with: rewardCode)
            updateLabel(subtitleLabel, with: nil)
        } else if let gainedRewardSubtitleText = viewModel.gainedRewardSubtitleText {
            updateLabel(rewardCodeLabel, with: nil) //forece remove in any case
            updateLabel(subtitleLabel, with: nil)
            updateLabel(descriptionLabel, with: nil)
            updateLabel(rewardCodeLabel, with: gainedRewardSubtitleText)
        } else if viewModel.rewardCode == nil {
            if viewModel.type == .custom {
                updateLabel(subtitleLabel, with: nil)
            } else if viewModel.conditions.count > 0 {
                for requirement in viewModel.conditions {
                    requirementsStack.addArrangedSubview(requirementView(fullfilled: requirement))
                }
                requirementsStack.addArrangedSubview(UIView())
                contentStackView.addArrangedSubview(requirementsStack)
            } else {
                contentStackView.removeArrangedSubview(requirementsStack)
                requirementsStack.removeFromSuperview()
            }
        }
        contentStackView.addArrangedSubview(spacerBottom)
    }

    private func updateBasicInfo(with viewModel: InfoItemType) {
        titleLabel.text = viewModel.title
        updateLabel(subtitleLabel, with: viewModel.subtitle)
        updateLabel(descriptionLabel, with: viewModel.description)
        imageUri = viewModel.imageUri
        if !viewModel.imageUri.isEmpty {
            UIImage.loadImage(from: viewModel.imageUri) { [weak self] uri, image, _ in
                guard let weakSelf = self, weakSelf.imageUri == uri else { return }
                weakSelf.thumbnailImageView.image = image
            }
        }
    }

    public func updateLabel(_ label: UILabel, with text: String?) {
        if let text = text {
            label.text = text
            contentStackView.addArrangedSubview(label)
        } else {
            contentStackView.removeArrangedSubview(label)
            label.removeFromSuperview()
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        let layerMask = CAShapeLayer()
        layerMask.frame = contentView.bounds
        layerMask.path = UIBezierPath(roundedRect: layerMask.bounds.inset(by: UIEdgeInsets(top: margin / 2, left: margin, bottom: margin / 2, right: margin)), byRoundingCorners: .allCorners,
                                      cornerRadii: CGSize(width: Styling.cornerRadiusSecondary, height: Styling.cornerRadiusSecondary)).cgPath
        contentView.layer.mask = layerMask
    }

    open func setupLayout() {
        backgroundColor = .clear
        spacerBottom.text = "  "
        let roundedBackgroundView = UIView()
        roundedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        roundedBackgroundView.backgroundColor = .backgroundSecondary
        roundedBackgroundView.layer.cornerRadius = Styling.cornerRadius
        contnetSVViewContainer.cover(with: contentStackView, insets: NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
        contentView.addSubview(rootStackView)
        rootStackView.addSubview(roundedBackgroundView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constraints.append(rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constraints.append(rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin / 2))
        constraints.append(rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin / 2))
        constraints.append(rootStackView.leadingAnchor.constraint(equalTo: roundedBackgroundView.leadingAnchor))
        constraints.append(rootStackView.trailingAnchor.constraint(equalTo: roundedBackgroundView.trailingAnchor))
        constraints.append(rootStackView.topAnchor.constraint(equalTo: roundedBackgroundView.topAnchor))
        constraints.append(rootStackView.bottomAnchor.constraint(equalTo: roundedBackgroundView.bottomAnchor))
        constraints.append(spacerTop.heightAnchor.constraint(equalToConstant: 0))
        constraints.append(spacerBottom.heightAnchor.constraint(equalToConstant: 0))
        NSLayoutConstraint.activate(constraints)

        thumbnailViewContainer.cover(with: thumbnailImageView, insets: .zero)
        rootStackView.addArrangedSubview(thumbnailViewContainer)
        rootStackView.addArrangedSubview(contnetSVViewContainer)
        //contentStackView.addArrangedSubview(spacerTop)
        contentStackView.addArrangedSubview(titleLabel)
    }

    private func requirementView(fullfilled: Bool) -> UIView {
        let uiStyle = container.resolve(RewardsStyleConfigurable.self, name: RewardsResolversNames.styleResolver)
        let view = UIView()
        view.backgroundColor = fullfilled ? uiStyle?.conditionColor ?? .positivePrimary : .backgroundPrimary
        view.layer.cornerRadius = uiStyle?.conditionCornerRadious ?? 4.5
        view.widthAnchor.constraint(equalToConstant: 20).isActive = true
        view.heightAnchor.constraint(equalToConstant: 9).isActive = true
        return view
    }

    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        contentView.alpha = highlighted ? Styling.highlightedStateAlpha : 1.0
    }

    private let requirementsStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 9
        stack.alignment = .leading
        return stack
    }()
}
