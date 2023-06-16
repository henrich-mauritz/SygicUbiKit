import UIKit

class ShortDrivingFloatingBar: DrivingFloatingBar {
    //MARK: - Class properties

    public static let barHeight: CGFloat = 100
    
    //MARK: - Properties

    private let circleHeightWidth: CGFloat = 70
    private var shouldAnimate: Bool = false

    private lazy var circleContainerView: UIView = {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.heightAnchor.constraint(equalToConstant: circleHeightWidth).isActive = true
        circleView.widthAnchor.constraint(equalToConstant: circleHeightWidth).isActive = true
        circleView.backgroundColor = .buttonBackgroundPrimary
        return circleView
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "carDriveBar", in: .module, with: nil)!
        button.setImage(image.scalePreservingAspectRatio(targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysTemplate), for: .normal)
        button.contentMode = .center
        button.imageEdgeInsets = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 0)
        button.tintColor = .buttonForegroundPrimary
        return button
    }()

    //MARK: - LifeCycle

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(tapAction: @escaping () -> ()) {
        super.init(tapAction: tapAction)
        setupLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let circleStyle: Styling.Style = .roundedWithDropShadowStyle(cornerRadius: circleHeightWidth / 2,
                                                                     shadowColor: Styling.shadowPrimary, shadowOffset: .zero,
                                                                     shadowRadius: 10.0)
        circleContainerView.apply(style: circleStyle)
    }

    override func setVehicleIcon(with image: UIImage?) {
        actionButton.setImage(image?.scalePreservingAspectRatio(targetSize: CGSize(width: 35, height: 35)).withRenderingMode(.alwaysTemplate), for: .normal)
    }

    private func setupLayout() {
        addSubview(circleContainerView)
        circleContainerView.addSubview(actionButton)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 100),
            widthAnchor.constraint(equalToConstant: 100),
            circleContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.topAnchor.constraint(equalTo: circleContainerView.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: circleContainerView.bottomAnchor),
            actionButton.leadingAnchor.constraint(equalTo: circleContainerView.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: circleContainerView.trailingAnchor),
        ])
        actionButton.addTarget(self, action: #selector(ShortDrivingFloatingBar.actionButtonTapped(sender:)), for: .touchUpInside)
    }

    @objc
private func actionButtonTapped(sender: Any) {
        guard let action = super.action else {
            return
        }
        action()
    }
    
    override func pulseAnimation(enable: Bool) {
        super.pulseAnimation(enable: enable)
        shouldAnimate = enable
        if enable {
            restartAnimation()
        }
        else {
            circleContainerView.layer.removeAllAnimations()
        }
        
    }
    
    override func resumeAnimation() {
        if shouldAnimate {
            restartAnimation()
        }
        else {
            circleContainerView.layer.removeAllAnimations()
        }
    }
    
    private func restartAnimation() {
        circleContainerView.layer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.6
        animation.repeatCount = .greatestFiniteMagnitude
        animation.autoreverses = true
        animation.fromValue = NSNumber(value: 1.0)
        animation.toValue = NSNumber(value: 1.15)
        circleContainerView.layer.add(animation, forKey: "pulse")
    }
}
