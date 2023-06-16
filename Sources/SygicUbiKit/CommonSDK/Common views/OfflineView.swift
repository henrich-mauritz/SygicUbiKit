import Foundation
import UIKit

public class OfflineView: UIView {
    public let label: UILabel = {
        let label = UILabel()
        label.font = .bigTitleFont()
        label.textColor = .foregroundPrimary
        label.numberOfLines = 0
        label.contentMode = .center
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupView() {
        backgroundColor = .backgroundPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        var constraints = [NSLayoutConstraint]()

        constraints.append(label.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(label.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(label.trailingAnchor.constraint(equalTo: trailingAnchor))

        NSLayoutConstraint.activate(constraints)
    }
}
