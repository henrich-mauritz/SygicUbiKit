import UIKit

class AboutYourScoreDescriptionTableViewCell: UITableViewCell {
    private let descrLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        selectionStyle = .none
        contentView.backgroundColor = .backgroundPrimary
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.cover(with: descrLabel, insets: NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
    }

    func update(with description: String) {
        descrLabel.text = description
    }
}
