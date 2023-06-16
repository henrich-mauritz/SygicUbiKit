import UIKit

class LabelContainer: UIView {
    public let staticLabel: UILabel = {
        let staticLabel = UILabel()
        staticLabel.textColor = .foregroundDriving
        staticLabel.textAlignment = .center
        staticLabel.font = UIFont.itemTitleFont()
        return staticLabel
    }()

    public let activeLabel: UILabel = {
        let activeLabel = UILabel()
        activeLabel.textColor = .foregroundDriving
        activeLabel.textAlignment = .center
        activeLabel.font = UIFont.stylingFont(.bold, with: 80)
        activeLabel.adjustsFontSizeToFitWidth = true
        return activeLabel
    }()

    public let dimensionLabel: UILabel = {
        let dimensionLabel = UILabel()
        dimensionLabel.textColor = .foregroundDriving
        dimensionLabel.textAlignment = .center
        dimensionLabel.font = UIFont.stylingFont(.bold, with: 16)
        return dimensionLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
        initActiveLabel()
        initDimensionLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initDimensionLabel() {
        addSubview(dimensionLabel)
        initConstraintsForDimensionLabel()
    }

    private func initConstraintsForDimensionLabel() {
        dimensionLabel.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()

        constraints.append(dimensionLabel.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(dimensionLabel.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(dimensionLabel.topAnchor.constraint(equalTo: activeLabel.bottomAnchor))
        constraints.append(dimensionLabel.bottomAnchor.constraint(equalTo: bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }

    private func initActiveLabel() {
        addSubview(activeLabel)
        initConstraintsForActiveLabel()
    }

    private func initConstraintsForActiveLabel() {
        activeLabel.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()

        constraints.append(activeLabel.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(activeLabel.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(activeLabel.topAnchor.constraint(equalTo: topAnchor))

        NSLayoutConstraint.activate(constraints)
    }
}
