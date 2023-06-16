import Foundation
import UIKit

// MARK: - DashcamDisclosureCellModel

public struct DashcamDisclosureCellModel {
    public enum CellType {
        case duration, quality
        case customType(String)
    }

    public var title: String
    public var subtitle: String?
    public var description: String?
    public var type: CellType
    public init(title: String, subtitle: String?, description: String?, type: CellType) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.type = type
    }
}

// MARK: - DashcamDisclosureCell

final class DashcamDisclosureCell: UITableViewCell {
    private let titleContainer = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let disclosureButton = UIButton()

    private lazy var descriptionSpaceConstraint: NSLayoutConstraint = {
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: margin / 2.0)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: DashcamDisclosureCellModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        descriptionLabel.isHidden = model.description == nil
        descriptionLabel.text = model.description
        descriptionSpaceConstraint.constant = model.description == nil ? 0 : margin / 2
    }
}

// MARK: - Private

extension DashcamDisclosureCell {
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .backgroundPrimary
        contentView.addAutoLayoutSubviews(disclosureButton, titleContainer)
        titleContainer.addAutoLayoutSubviews(titleLabel, subtitleLabel, descriptionLabel)

        disclosureButton.backgroundColor = .clear
        let image = UIImage(named: "icn-dashcam-disclosure", in: .module, compatibleWith: nil)
        disclosureButton.setImage(image, for: .normal)
        disclosureButton.tintColor = .actionPrimary

        titleLabel.textColor = .foregroundPrimary
        titleLabel.font = UIFont.stylingFont(.regular, with: 16)
        subtitleLabel.textColor = UIColor.foregroundPrimary.withAlphaComponent(0.4)
        subtitleLabel.font = UIFont.stylingFont(.regular, with: 16)
        descriptionLabel.textColor = UIColor.foregroundPrimary.withAlphaComponent(0.4)
        descriptionLabel.font = UIFont.stylingFont(.regular, with: 16)
        descriptionLabel.numberOfLines = 0

        titleContainer.coverWholeSuperview(margin: 16)
        titleLabel.constraints(top: titleContainer.topAnchor, leading: titleContainer.leadingAnchor, trailing: titleContainer.trailingAnchor)
        subtitleLabel.constraints(trailing: disclosureButton.leadingAnchor, centerY: titleLabel.centerYAnchor)
        descriptionLabel.constraints(leading: titleContainer.leadingAnchor, bottom: titleContainer.bottomAnchor, trailing: titleContainer.trailingAnchor)
        descriptionSpaceConstraint.isActive = true
        disclosureButton.constraints(trailing: safeAreaTrailingAnchor, padding: UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 0), size: CGSize(width: 32, height: 32), centerY: subtitleLabel.centerYAnchor)
    }
}
