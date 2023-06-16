import UIKit

class LongDrivingFloatingBar: DrivingFloatingBar {
    //MARK: - Class properties

    public static let barHeight: CGFloat = 72

    private let cornerRadius: CGFloat = Styling.cornerRadius
    private let shadowRadius: CGFloat = 16
    private let fontSize: CGFloat = 30
    private let labelSpacing: CGFloat = 85
    private let arrowMargin: CGFloat = 20
    private let arrowHeight: CGFloat = 40

    private lazy var driveLabel: UILabel = {
        let driveLabel = UILabel()
        driveLabel.text = "driving.longSlideButtonFloatingBarTitle".localized
        driveLabel.font = UIFont.stylingFont(.thin, with: fontSize)
        driveLabel.textColor = .foregroundDriving
        driveLabel.minimumScaleFactor = 0.6
        driveLabel.adjustsFontSizeToFitWidth = true
        return driveLabel
    }()

    private lazy var arrowButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .buttonBackgroundPrimary
        button.tintColor = .buttonForegroundPrimary
        button.setImage(UIImage(named: "drivingDismissIcon", in: .module, compatibleWith: nil), for: .normal)
        button.transform = CGAffineTransform(rotationAngle: .pi)
        button.heightAnchor.constraint(equalToConstant: arrowHeight).isActive = true
        button.widthAnchor.constraint(equalToConstant: arrowHeight).isActive = true
        button.layer.cornerRadius = arrowHeight / 2
        return button
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(tapAction: @escaping () -> ()) {
        super.init(tapAction: tapAction)
        setupUI()
        setupCarImage()
        setupDriveLabel()
        setupArrowView()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor.shadowPrimary.cgColor
    }

    private func setupUI() {
        backgroundColor = .floatingBarBackground
        layer.shadowRadius = shadowRadius
        layer.shadowColor = UIColor.shadowPrimary.cgColor
        layer.shadowOpacity = 1
        layer.cornerRadius = cornerRadius
        addTapGestureRecognizer()
    }

    private func setupDriveLabel() {
        addSubview(driveLabel)
        driveLabel.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()
        constraints += [driveLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: labelSpacing)]
        constraints += [driveLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupArrowView() {
        arrowButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        addSubview(arrowButton)
        arrowButton.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.layer.opacity = 0

        var constraints = [NSLayoutConstraint]()
        constraints += [arrowButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -arrowMargin)]
        constraints += [arrowButton.centerYAnchor.constraint(equalTo: centerYAnchor)]
        NSLayoutConstraint.activate(constraints)

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [.curveEaseInOut], animations: {
            self.arrowButton.layer.opacity = 1
        }, completion: { _ in
            self.setNeedsLayout()
        })
    }

    private func addTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    @objc
private func didTap() {
        guard let action = super.action else { return }
        arrowButton.removeFromSuperview()
        action()
    }

    private func setupCarImage() {
        imageView = UIImageView(image: UIImage(named: "car", in: .module, compatibleWith: nil))
        addSubview(imageView)
        imageView.transform = CGAffineTransform(rotationAngle: .pi / 2).concatenating(CGAffineTransform(scaleX: 0.7, y: 0.7))
        imageView.layer.opacity = 0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: [.curveEaseInOut], animations: {
            self.imageView.layer.opacity = 1
            self.imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2).concatenating(CGAffineTransform(rotationAngle: .pi / 2))
        }, completion: { _ in
            self.setNeedsLayout()
        })
    }

    override public func resetUI() {
        super.resetUI()
        setupCarImage()
        setupArrowView()
    }
}
