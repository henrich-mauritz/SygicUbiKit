import UIKit

open class NewInfoTableViewCell: UITableViewCell, NewInfoListItemProtocol {
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
        label.numberOfLines = 2
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 14)
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rightContentView: UIView = {
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
        descriptionLabel.text = ""
    }

    open func update(with viewModel: InfoItemType) {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        imageUri = viewModel.imageUri
        if !viewModel.imageUri.isEmpty {
            UIImage.loadImage(from: viewModel.imageUri) { [weak self] uri, image, _ in
                guard let weakSelf = self, weakSelf.imageUri == uri else { return }
                weakSelf.thumbnailImageView.image = image
            }
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
        let roundedBackgroundView = UIView()
        roundedBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        roundedBackgroundView.backgroundColor = .backgroundSecondary
        roundedBackgroundView.layer.cornerRadius = Styling.cornerRadius
        contentView.addSubview(rootStackView)
        rootStackView.addSubview(roundedBackgroundView)
        rightContentView.addSubview(titleLabel)
        rightContentView.addSubview(descriptionLabel)

        var constraints = [NSLayoutConstraint]()
        constraints.append(rootStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constraints.append(rootStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constraints.append(rootStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin / 2))
        constraints.append(rootStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin / 2))
        constraints.append(rootStackView.leadingAnchor.constraint(equalTo: roundedBackgroundView.leadingAnchor))
        constraints.append(rootStackView.trailingAnchor.constraint(equalTo: roundedBackgroundView.trailingAnchor))
        constraints.append(rootStackView.topAnchor.constraint(equalTo: roundedBackgroundView.topAnchor))
        constraints.append(rootStackView.bottomAnchor.constraint(equalTo: roundedBackgroundView.bottomAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: rightContentView.topAnchor, constant: 12))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: rightContentView.leadingAnchor))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: rightContentView.trailingAnchor))
        constraints.append(titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -2))
        constraints.append(descriptionLabel.leadingAnchor.constraint(equalTo: rightContentView.leadingAnchor))
        constraints.append(descriptionLabel.trailingAnchor.constraint(equalTo: rightContentView.trailingAnchor))
        NSLayoutConstraint.activate(constraints)

        thumbnailViewContainer.cover(with: thumbnailImageView, insets: .zero)
        rootStackView.addArrangedSubview(thumbnailViewContainer)
        rootStackView.addArrangedSubview(rightContentView)
    }

    private func requirementView(fullfilled: Bool) -> UIView {
        let view = UIView()
        view.backgroundColor = fullfilled ? .actionPrimary : .backgroundPrimary
        view.layer.cornerRadius = 4
        view.widthAnchor.constraint(equalToConstant: 30).isActive = true
        view.heightAnchor.constraint(equalToConstant: 8).isActive = true
        return view
    }

    override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
        contentView.alpha = highlighted ? Styling.highlightedStateAlpha : 1.0
    }
}
