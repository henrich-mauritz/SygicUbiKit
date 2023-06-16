import Foundation
import UIKit

class EventStatView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundSecondary
        label.textAlignment = .left
        return label
    }()

    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundSecondary
        label.textAlignment = .right
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(scoreLabel)
        var constrains: [NSLayoutConstraint] = []
        constrains.append(heightAnchor.constraint(equalToConstant: 52))
        constrains.append(titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        constrains.append(scoreLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        constrains.append(titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0))
        constrains.append(scoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0))
        constrains.append(scoreLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10))
        NSLayoutConstraint.activate(constrains)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with event: EventStatViewModel) {
        titleLabel.text = event.type.formattedScoreString()
        scoreLabel.text = event.score
    }
}
