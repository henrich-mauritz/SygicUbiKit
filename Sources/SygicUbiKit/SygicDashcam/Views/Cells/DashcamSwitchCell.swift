import UIKit

// MARK: - DashcamSwitchCellModel

public struct DashcamSwitchCellModel {
    public enum CellType {
        case automaticRecording, oneTapRecording, recordSound, videoOverlay, crashDetector
        case customValue(String)
    }

    public var title: String
    public var subtitle: String?
    public var isOn: Bool
    public var type: CellType

    public init(title: String, subtitle: String?, isOn: Bool, type: CellType) {
        self.title = title
        self.subtitle = subtitle
        self.isOn = isOn
        self.type = type
    }
}

// MARK: - DashcamSwitchCellDelegate

protocol DashcamSwitchCellDelegate: AnyObject {
    func switchDidChange(isOn: Bool, cell: DashcamSwitchCell)
}

// MARK: - DashcamSwitchCell

public final class DashcamSwitchCell: UITableViewCell {
    private let titleContainer = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    let switchView = UISwitch()
    weak var delegate: DashcamSwitchCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        switchView.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with model: DashcamSwitchCellModel) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        switchView.isOn = model.isOn
    }

    @objc func switchValueChanged() {
        delegate?.switchDidChange(isOn: switchView.isOn, cell: self)
    }
}

// MARK: - Private

private extension DashcamSwitchCell {
    func setupUI() {
        selectionStyle = .none
        contentView.addAutoLayoutSubviews(titleContainer, switchView)
        backgroundColor = .backgroundPrimary
        titleContainer.addAutoLayoutSubviews(titleLabel, subtitleLabel)

        titleLabel.textColor = .foregroundPrimary
        titleLabel.font = UIFont.stylingFont(.regular, with: 16)
        titleLabel.numberOfLines = 2
        
        subtitleLabel.textColor = UIColor.foregroundPrimary.withAlphaComponent(0.4)
        subtitleLabel.font = UIFont.stylingFont(.regular, with: 16)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.minimumScaleFactor = 0.1
        subtitleLabel.adjustsFontSizeToFitWidth = true

        titleContainer.coverWholeSuperview(margin: 16)
        titleLabel.constraints(top: titleContainer.topAnchor, leading: titleContainer.leadingAnchor, trailing: switchView.leadingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 8))
        subtitleLabel.constraints(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, bottom: titleContainer.bottomAnchor, trailing: titleLabel.trailingAnchor, padding: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0))
        switchView.constraints(trailing: titleContainer.trailingAnchor, centerY: centerYAnchor)
    }
}
