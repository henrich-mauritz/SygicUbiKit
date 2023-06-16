import UIKit

// MARK: - DashcamOnboardingButton

final class DashcamOnboardingButton: UIView {
    let button = UIButton()
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let iconImageView = UIImageView()

    private let titleContainer = UIView()
    private let disclosureButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - Private

private extension DashcamOnboardingButton {
    func setupUI() {
        backgroundColor = DashcamColorManager.shared.background
        addAutoLayoutSubviews(disclosureButton, titleContainer, button)
        titleContainer.addAutoLayoutSubviews(iconImageView, titleLabel, subtitleLabel)
        button.coverWholeSuperview()

        disclosureButton.backgroundColor = .clear
        let image = UIImage(named: "icn-dashcam-disclosure", in: .module, compatibleWith: nil)
        disclosureButton.setImage(image, for: .normal)

        iconImageView.tintColor = DashcamColorManager.shared.blueIcon

        titleLabel.textColor = DashcamColorManager.shared.title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        subtitleLabel.textColor = DashcamColorManager.shared.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)

        titleContainer.coverWholeSuperview(margin: 12)
        iconImageView.constraints(leading: titleContainer.leadingAnchor, size: CGSize(width: 24, height: 24), centerY: titleContainer.centerYAnchor)
        titleLabel.constraints(top: titleContainer.topAnchor, leading: iconImageView.trailingAnchor, trailing: titleContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
        subtitleLabel.constraints(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, bottom: titleContainer.bottomAnchor, trailing: titleLabel.trailingAnchor, padding: UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0))
        disclosureButton.constraints(trailing: safeAreaTrailingAnchor, padding: UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 0), size: CGSize(width: 44, height: 44), centerY: centerYAnchor)
    }
}
