import UIKit

public class MapExpandIndicator: UIView {
    public let iconView = UIImageView()

    public lazy var backgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .buttonBackgroundTertiaryPassive
        view.layer.cornerRadius = size / 2.0
        return view
    }()

    public let size: CGFloat = 70
    public let iconSize: CGFloat = 24

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor.shadowPrimary.cgColor
    }

    private func setupLayout() {
        backgroundColor = .clear

        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowColor = UIColor.shadowPrimary.cgColor
        layer.shadowOpacity = 1

        iconView.tintColor = .buttonForegroundPrimary
        iconView.translatesAutoresizingMaskIntoConstraints = false
        cover(with: backgroundView)
        backgroundView.addSubview(iconView)

        var constraints = [NSLayoutConstraint]()
        constraints.append(widthAnchor.constraint(equalToConstant: size))
        constraints.append(heightAnchor.constraint(equalToConstant: size))
        constraints.append(backgroundView.centerXAnchor.constraint(equalTo: iconView.centerXAnchor))
        constraints.append(backgroundView.centerYAnchor.constraint(equalTo: iconView.centerYAnchor))
        constraints.append(iconView.widthAnchor.constraint(equalToConstant: iconSize))
        constraints.append(iconView.heightAnchor.constraint(equalToConstant: iconSize))
        NSLayoutConstraint.activate(constraints)
    }
}
