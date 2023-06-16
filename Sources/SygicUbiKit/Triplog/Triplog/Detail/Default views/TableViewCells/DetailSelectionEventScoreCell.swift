import UIKit
import Foundation

class DetailSelectionEventScoreCell: DetailSelectionCell {
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundPrimary
        label.font = .stylingFont(.regular, with: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        leftLabel.font = .stylingFont(.bold, with: 16)
        hasIndicator = false
        hideSeparator = true
        setupLayout()
    }

    private func setupLayout() {
        leftLabel.removeFromSuperview()
        intensityView.removeFromSuperview()
        contentView.addSubview(leftLabel)
        contentView.addSubview(intensityView)
        contentView.addSubview(timeLabel)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(leftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: labelMargin))
        constraints.append(leftLabel.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(timeLabel.leadingAnchor.constraint(equalTo: leftLabel.leadingAnchor))
        constraints.append(timeLabel.topAnchor.constraint(equalTo: leftLabel.bottomAnchor, constant: 4))
        constraints.append(timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14))
        constraints.append(intensityView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -labelMargin))
        constraints.append(intensityView.centerYAnchor.constraint(equalTo: timeLabel.centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(with eventString: String, severnity: SevernityLevel?, time: String? = nil) {
        super.update(with: eventString, severnity: severnity)
        timeLabel.text = time
    }
}
