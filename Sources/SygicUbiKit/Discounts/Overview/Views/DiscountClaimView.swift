import Foundation
import UIKit

public class DiscountClaimView: UIView {
    public let button: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normal)
        button.titleLabel.text = "discounts.claimBubble.button".localized.uppercased()
        return button
    }()

    public let textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 20)
        label.textColor = .foregroundSecondary
        label.text = "discounts.claimBubble.description".localized + " "
        return label
    }()

    public let discountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 20)
        label.textColor = .foregroundSecondary
        label.text = "0 %"
        return label
    }()

    public let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .lastBaseline
        return stack
    }()

    private let insuranceForCarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.textColor = .foregroundPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var insurnaceForCarLabelContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = Styling.backgroundTertiary
        return containerView
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = Styling.cornerRadiusModalPopup
        layer.masksToBounds = true
        labelsStack.addArrangedSubview(textLabel)
        labelsStack.addArrangedSubview(discountLabel)

        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelsStack)
        addSubview(button)

        insurnaceForCarLabelContainerView.cover(with: insuranceForCarLabel, insets: NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16), toSafeArea: false)
        addSubview(insurnaceForCarLabelContainerView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(insurnaceForCarLabelContainerView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(insurnaceForCarLabelContainerView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(insurnaceForCarLabelContainerView.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(labelsStack.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(labelsStack.topAnchor.constraint(equalTo: insurnaceForCarLabelContainerView.bottomAnchor, constant: 16))
        constraints.append(labelsStack.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16))
        constraints.append(button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16))
        constraints.append(button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16))
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configureWithvehicle(with name: String) {
        insuranceForCarLabel.text = String(format: "discounts.claimBubble.title".localized, name).uppercased()
        insurnaceForCarLabelContainerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
}
