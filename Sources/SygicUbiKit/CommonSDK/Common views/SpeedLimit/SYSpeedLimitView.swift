import Foundation
import UIKit

// MARK: - SYSpeedLimitView

public class SYSpeedLimitView: UIView {
    //MARK: -  Properties

    public private(set) lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var speedLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.7
        label.numberOfLines = 1
        label.text = "-"
        label.adjustsFontSizeToFitWidth = true //in case space rocket's speed  🚀
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .backgroundDriving
        label.font = UIFont.stylingFont(.bold, with: 26)
        return label
    }()

    private lazy var animatableSpeedLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.7
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.alpha = 0.0
        label.textColor = .backgroundDriving
        label.font = UIFont.stylingFont(.bold, with: 26)
        return label
    }()

    private lazy var stripeLayerPath: CAShapeLayer = {
        let stripe = CAShapeLayer()
        stripe.lineCap = .round
        stripe.fillColor = UIColor.clear.cgColor
        stripe.transform = CATransform3DRotate(stripe.transform, CGFloat(Math.deg2rad(Double(-90))), 0, 0, 1)
        stripe.strokeColor = UIColor.red2.cgColor
        stripe.lineWidth = 7
        return stripe
    }()

    private let speedChangeAnimationDuration: Double = 0.5
    private let margin: CGFloat = 3
    private var currentSpeedValue: Int = -1
    private var animatable: Bool = true

    //MARK: - LifeCycle

    public class func speedView() -> SYSpeedLimitView { //I am speed! 🏎
        let view = SYSpeedLimitView(frame: CGRect(x: 0, y: 0, width: 74, height: 74))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = false
        setupLayout()
        configureVisuals()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if stripeLayerPath.superlayer == nil {
            stripeLayerPath.frame = backgroundView.bounds
            stripeLayerPath.path = UIBezierPath(ovalIn: stripeLayerPath.bounds.inset(by: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))).cgPath
            layer.addSublayer(stripeLayerPath)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        cover(with: backgroundView)
        addSubview(speedLabel)
        addSubview(animatableSpeedLabel)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(speedLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(speedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constraints.append(speedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin))
        constraints.append(animatableSpeedLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(animatableSpeedLabel.leadingAnchor.constraint(equalTo: speedLabel.leadingAnchor, constant: 0))
        constraints.append(animatableSpeedLabel.trailingAnchor.constraint(equalTo: speedLabel.trailingAnchor, constant: 0))
        constraints.append(self.heightAnchor.constraint(equalToConstant: self.bounds.height))
        constraints.append(self.widthAnchor.constraint(equalToConstant: self.bounds.width))
        NSLayoutConstraint.activate(constraints)
        backgroundView.layer.cornerRadius = self.bounds.height / 2
    }

    /// Updates the speed label given the value
    /// - Parameter speedValue: the current speed to show
    public func updateSpeed(with speedValue: Int) {
        updateSpeed(with: speedValue, animated: animatable)
    }

    /// Update value with the view, animating or no
    /// - Parameters:
    ///   - speedValue: speed value
    ///   - animated: tells if it should animate
    ///   - forceAnim: no matter what animate value is, if forceAnim is true it will animate, this value should be passed only for testing purposes and shall not be used in prod
    public func updateSpeed(with speedValue: Int, animated: Bool, forceAnimation: Bool = false) {
        speedLabel.text = "\(speedValue)"
        if (currentSpeedValue != -1 && (speedValue != currentSpeedValue) && animated) {
            animateSpeedChange()
        }
        currentSpeedValue = speedValue
    }

    private func animateSpeedChange() {
        let growAnimation = CABasicAnimation(keyPath: "transform.scale")
        growAnimation.duration = speedChangeAnimationDuration
        growAnimation.fromValue = 1
        growAnimation.toValue = 1.2
        growAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        growAnimation.autoreverses = true
        growAnimation.fillMode = .forwards
        growAnimation.isRemovedOnCompletion = true
        backgroundView.layer.add(growAnimation, forKey: "scale")

        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = speedChangeAnimationDuration * 2
        pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pathAnimation.fillMode = .forwards
        pathAnimation.beginTime = CACurrentMediaTime()
        pathAnimation.isRemovedOnCompletion = true
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        stripeLayerPath.strokeEnd = 1
        stripeLayerPath.strokeStart = 0
        stripeLayerPath.add(pathAnimation, forKey: "stroke")

        animateLabel()
    }

    private func animateLabel() {
        animatableSpeedLabel.text = speedLabel.text
        self.animatableSpeedLabel.alpha = 1.0
        UIView.animate(withDuration: speedChangeAnimationDuration + 0.5,
                       delay: 0.0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.animatableSpeedLabel.alpha = 0.0
            self.speedLabel.alpha = 0.5
            self.animatableSpeedLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        } completion: { _ in
            self.animatableSpeedLabel.transform = CGAffineTransform.identity
            self.speedLabel.alpha = 1.0
        }
    }
    
    private func configureVisuals() {
//        speedLabel.font = styling.font
//        speedLabel.textColor = styling.textColor
//        animatableSpeedLabel.font = styling.font
//        animatableSpeedLabel.textColor = styling.textColor
//        backgroundView.backgroundColor = styling.bgColor
//        stripeLayerPath.lineWidth = styling.roundStripeWidth
//        stripeLayerPath.strokeColor = styling.roundStripeColor.cgColor
//        animatable = true
    }
    
}
