import Foundation
import UIKit

class DisclosureTableViewCell: BasicTriplogTableViewCell, TripDetailScoreCellProtocol {
    private let arrowMargin: CGFloat = 24
    private let stackViewMargin: CGFloat = 42

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let arrowView = UIImageView(image: UIImage(named: "disclosureIndicator", in: .module, compatibleWith: nil))
        contentView.addSubview(arrowView)
        arrowView.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()
        constraints.append(arrowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -arrowMargin))
        constraints.append(arrowView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        stackViewTrailingAnchor?.isActive = false
        constraints.append(stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -stackViewMargin))
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(with title: String, icon: UIImage?, margins: UIEdgeInsets = .zero) {
        stackView.removeArrangedSubview(colorView)
        let imageView = UIImageView()
        imageView.tintColor = Styling.foregroundPrimary
        imageView.image = icon
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        stackView.insertArrangedSubview(imageView, at: 0)
        leftLabel.text = title
        if margins != .zero {
            stackViewLeadingAnchor?.constant = margins.left
            stackViewTrailingAnchor?.constant = margins.right
        }
    }
}
