import UIKit

public class VPVehicleIndicatorView: UIView {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 14)
        label.textColor = Styling.foregroundPrimary
        label.textAlignment = .center
        return label
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        isUserInteractionEnabled = false
        backgroundColor = Styling.backgroundSecondary.withAlphaComponent(0.7)
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        cover(with: titleLabel, insets: NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }

    public func update(with vehicleName: String, textColor: UIColor = Styling.foregroundPrimary, backgroundColor: UIColor = .backgroundSecondary.withAlphaComponent(0.7)) {
        self.backgroundColor = backgroundColor
        titleLabel.textColor = textColor
        titleLabel.text = vehicleName
    }
}
