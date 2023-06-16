import Foundation
import UIKit

class TriplogListCollectionViewCell: UICollectionViewCell {
    private let controlsContentView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = Styling.cornerRadius
        return view
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.bold, with: 16)
        return label
    }()

    private let distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textAlignment = .right
        return label
    }()

    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundSecondary
        label.textAlignment = .right
        label.font = UIFont.stylingFont(.thin, with: 30)
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundSecondary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textAlignment = .left
        return label
    }()

    private let chevronImage: UIImageView = {
        let image = UIImage(named: "disclosureIndicator", in: .module, compatibleWith: nil)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override public var reuseIdentifier: String? {
        return TriplogListCollectionViewCell.cellIdentifier
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.backgroundColor = .backgroundPrimary
        contentView.addSubview(controlsContentView)
        contentView.cover(with: controlsContentView, insets: NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        controlsContentView.addSubview(addressLabel)
        controlsContentView.addSubview(distanceLabel)
        controlsContentView.addSubview(timeLabel)
        controlsContentView.addSubview(scoreLabel)
        controlsContentView.addSubview(chevronImage)

        NSLayoutConstraint.activate([
            addressLabel.leadingAnchor.constraint(equalTo: controlsContentView.leadingAnchor, constant: 20),
            addressLabel.bottomAnchor.constraint(equalTo: timeLabel.topAnchor, constant: -2),
            timeLabel.centerYAnchor.constraint(equalTo: controlsContentView.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor),
            distanceLabel.leadingAnchor.constraint(equalTo: addressLabel.leadingAnchor, constant: 0),
            distanceLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 2),
            scoreLabel.centerYAnchor.constraint(equalTo: controlsContentView.centerYAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: controlsContentView.trailingAnchor, constant: -40),
            addressLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant: -10),
            timeLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant: -10),
            chevronImage.trailingAnchor.constraint(equalTo: controlsContentView.trailingAnchor, constant: -20),
            chevronImage.centerYAnchor.constraint(equalTo: controlsContentView.centerYAnchor, constant: 0),
        ])
        addressLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        addressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        scoreLabel.setContentHuggingPriority(.required, for: .horizontal)
        scoreLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func update(with viewModel: TriplogTripCardViewModelProtocol) {
        addressLabel.text = viewModel.destinationText != "" ? viewModel.destinationText : "triplog.monthOverview.locationPlaceholder".localized
        scoreLabel.text = viewModel.scoreText
        distanceLabel.text = viewModel.descriptionText
        timeLabel.text = viewModel.dateText
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        addressLabel.text = ""
        scoreLabel.text = ""
        distanceLabel.text = ""
    }
}
