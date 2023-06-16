import Foundation
import UIKit

public class SosContactCell: UITableViewCell {
    static let reuseIdentifier: String = "SosContactCellIdentifier"

    public let button: StylingButton = {
        StylingButton.button(with: .circular)
    }()

    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textAlignment = .left
        return label
    }()

    public lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .foregroundPrimary
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textAlignment = .left
        return label
    }()

    private lazy var labelsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var contactNumber: String = ""

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(SosContactCell.callContactNumber), for: .touchUpInside)
        contentView.addSubview(button)
        labelsContainerView.addSubview(titleLabel)
        labelsContainerView.addSubview(subtitleLabel)
        contentView.addSubview(labelsContainerView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constraints.append(button.trailingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: -16))
        constraints.append(button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin / 2))
        constraints.append(button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin / 2))
        constraints.append(titleLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor))
        constraints.append(titleLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: labelsContainerView.topAnchor))
        constraints.append(subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor))
        constraints.append(subtitleLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor))
        constraints.append(subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2))
        constraints.append(subtitleLabel.bottomAnchor.constraint(equalTo: labelsContainerView.bottomAnchor, constant: 0))
        constraints.append(labelsContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    public func update(with contact: ContactData) {
        titleLabel.text = contact.title
        button.iconView.image = contact.icon
        subtitleLabel.text = contact.subtitle
        contactNumber = contact.phoneNumber
    }

    @objc
private func callContactNumber() {
        guard let phoneUrl = URL(string: "tel://\(contactNumber)"), UIApplication.shared.canOpenURL(phoneUrl) else { return }
        UIApplication.shared.open(phoneUrl, options: [:], completionHandler: nil)
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.assistanceCall, parameters: [AnalyticsKeys.Parameters.phoneNumberKey: contactNumber ])
    }
}
