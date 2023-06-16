import Foundation
import UIKit

public class CheckBox: UIView {
    public let size: CGFloat = 19
    public let backgroundSize: CGFloat = 16

    override public var backgroundColor: UIColor? {
        get {
            backgroundView.backgroundColor
        }
        set {
            backgroundView.backgroundColor = newValue
        }
    }

    let backgroundView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()

    lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "combinedShape", in: .module, compatibleWith: nil))
        imageView.tintColor = .buttonForegroundTertiaryActive
        imageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        return imageView
    }()

    public required init(checked: Bool) {
        super.init(frame: .zero)
        widthAnchor.constraint(equalToConstant: size).isActive = true
        heightAnchor.constraint(equalToConstant: size).isActive = true
        setupBackground(checked: checked)
        if checked {
            setupCheckmarkImage()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupBackground(checked: Bool) {
        backgroundView.backgroundColor = checked ? .actionPrimary : .backgroundSecondary
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(backgroundView.widthAnchor.constraint(equalToConstant: backgroundSize))
        constraints.append(backgroundView.heightAnchor.constraint(equalToConstant: backgroundSize))
        NSLayoutConstraint.activate(constraints)
    }

    private func setupCheckmarkImage() {
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(checkmarkImageView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(checkmarkImageView.centerXAnchor.constraint(equalTo: centerXAnchor))
        NSLayoutConstraint.activate(constraints)
    }
}
