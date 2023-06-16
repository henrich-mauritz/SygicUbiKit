import Foundation
import UIKit

public class SosAssistanceLocationCell: UITableViewCell, InjectableType {
    static let reuseIdentifier: String = "SosLocationCellIdentifier"

    public let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    public let warningIcon: UIImageView = {
        let view = UIImageView(image: UIImage(named: "warningSign", in: .module, compatibleWith: nil))
        view.tintColor = .negativePrimary
        view.contentMode = .scaleAspectFit
        return view
    }()

    public lazy var button: StylingButton = {
        var button: StylingButton = StylingButton.button(with: .secondary)
        button.addTarget(self, action: #selector(Self.buttonPressed(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = margin
        return stack
    }()

    private var buttonActionBlock: (() -> ())?

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        stackView.addArrangedSubview(warningIcon)
        stackView.addArrangedSubview(locationLabel)
        stackView.addArrangedSubview(button)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        warningIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(warningIcon.heightAnchor.constraint(equalToConstant: 20))
        constraints.append(stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin))
        constraints.append(stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -margin))
        constraints.append(stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin / 2))
        constraints.append(stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -margin))
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func update(with location: String?) {
        locationLabel.text = location ?? "assistance.searchingGPS".localized
        warningIcon.isHidden = location != nil
        button.isHidden = true
    }

    public func updateActionButton(withTitle title: String? = nil, _ buttonAction: @escaping () -> ()) {
        if title == nil {
            let format = "assistance.needsPermissionCell.title".localized
            let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "NotFound"
            locationLabel.text = String(format: format, appName)
            button.titleLabel.text = "assistance.needsPermissionCell.button".localized
        } else {
            button.titleLabel.text = title
        }
        button.isHidden = false
        buttonActionBlock = buttonAction
        warningIcon.isHidden = true
    }

    @objc
private func buttonPressed(_ sender: Any) {
        buttonActionBlock?()
    }
}
