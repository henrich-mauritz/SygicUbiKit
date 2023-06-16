import UIKit

// MARK: - MonthlyStatsBarView

class MonthlyStatsBarView: UIView {
    var viewModel: MonthlyStatDayBarType? {
        didSet {
            guard let viewModel = self.viewModel else {
                return
            }
            barShapeLayer.strokeColor = viewModel.barColor.cgColor
            set(value: viewModel.value, animated: true, isMax: viewModel.isMax)
        }
    }

    private lazy var barShapeLayer: CAShapeLayer = {
        let barLayer = CAShapeLayer()
        barLayer.strokeColor = Styling.positivePrimary.cgColor
        barLayer.backgroundColor = UIColor.clear.cgColor
        barLayer.lineCap = .round
        return barLayer
    }()

    private lazy var maxIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 12).isActive = true
        view.heightAnchor.constraint(equalToConstant: 12).isActive = true
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 6
        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.widthAnchor.constraint(equalToConstant: 6).isActive = true
        innerCircle.heightAnchor.constraint(equalToConstant: 6).isActive = true
        innerCircle.backgroundColor = .foregroundPrimary
        innerCircle.layer.cornerRadius = 3
        view.addSubview(innerCircle)
        innerCircle.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        innerCircle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.alpha = 0
        return view
    }()

    private let kBarWidth: CGFloat = 6
    private var topLayoutConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: kBarWidth, height: 107))
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        widthAnchor.constraint(equalToConstant: kBarWidth).isActive = true
        layoutIfNeeded()
        transform = CGAffineTransform(scaleX: 1, y: -1)
        layer.addSublayer(barShapeLayer)
        addSubview(maxIndicator)
        maxIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        topLayoutConstraint = maxIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        topLayoutConstraint?.isActive = true
    }

    private func animateGrow() {
            let growAnimation = CABasicAnimation(keyPath: "strokeEnd")
            growAnimation.autoreverses = false
            growAnimation.fillMode = .forwards
            growAnimation.fromValue = 0
            growAnimation.toValue = 1
            growAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            growAnimation.duration = 0.4
            growAnimation.delegate = self
            growAnimation.isRemovedOnCompletion = true
            self.barShapeLayer.strokeEnd = 1
            self.barShapeLayer.add(growAnimation, forKey: "grow")
    }

    /// Convineice method to set the value without all fancy animation and timing function.
    /// - Parameters:
    ///   - value: value between 1-100
    ///   - animated: flag if it should animate or no
    public func set(value: Int, animated: Bool, isMax: Bool) {
        var heightValue = CGFloat(value) * frame.height / 100
        if value == 0 {
            heightValue = 0.5
            barShapeLayer.strokeColor = Styling.buttonOnboardingSecondaryBackground.cgColor
        }

        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.midX, y: 0))
        path.addLine(to: CGPoint(x: bounds.midX, y: heightValue))
        barShapeLayer.path = path.cgPath
        barShapeLayer.strokeStart = 0
        barShapeLayer.strokeEnd = 0
        barShapeLayer.lineWidth = bounds.width
        topLayoutConstraint?.constant = heightValue
        if !animated {
            CATransaction.begin()
            CATransaction.setDisableActions(!animated)
            barShapeLayer.strokeEnd = 1.0
            maxIndicator.alpha = isMax ? 1 : 0
            CATransaction.commit()
        } else {
            animateGrow()
        }
    }

    func prepareForAnimation() {
        barShapeLayer.strokeEnd = 0.0
        maxIndicator.alpha = 0
    }
}

// MARK: CAAnimationDelegate

extension MonthlyStatsBarView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let viewModel = self.viewModel else {
            return
        }
        if flag && viewModel.isMax {
            maxIndicator.alpha = 1.0
        }
    }
}
