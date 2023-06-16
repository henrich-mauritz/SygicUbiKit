import AudioToolbox
import UIKit

// MARK: - VisionCalibrationView

class VisionCalibrationView: UIView {
    var viewModel: VisionCalibrationViewViewModel

    private var isCalibrated: Bool = false
    private lazy var balancedView: BalanceView = {
        let balanceV = BalanceView(frame: .zero, isStatic: true)
        balanceV.translatesAutoresizingMaskIntoConstraints = false
        balanceV.widthAnchor.constraint(equalToConstant: 288).isActive = true
        balanceV.heightAnchor.constraint(equalToConstant: 74).isActive = true
        balanceV.alpha = 0
        return balanceV
    }()

    private lazy var yawableBalanceView: BalanceView = {
        let balanceV = BalanceView(frame: .zero, isStatic: false)
        balanceV.translatesAutoresizingMaskIntoConstraints = false
        balanceV.widthAnchor.constraint(equalToConstant: 288).isActive = true
        balanceV.heightAnchor.constraint(equalToConstant: 74).isActive = true
        balanceV.alpha = 0
        return balanceV
    }()

    private lazy var educationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if UIDevice.current.orientation.isLandscape {
            imageView.image = UIImage(named: "educationImage_landscape", in: .module, compatibleWith: nil)
        } else {
            imageView.image = UIImage(named: "educationImage", in: .module, compatibleWith: nil)
        }
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    private lazy var calibrationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "vision.calibration.notOk".localized
        label.textColor = .white
        label.font = UIFont.stylingFont(.bold, with: 16)
        return label
    }()

    private var animatedEdutcation: Bool = false
    private var animatingEducation: Bool = false
    private var calibrationCompletedTimer: Timer?
    override init(frame: CGRect) {
        self.viewModel = VisionCalibrationViewViewModel()
        super.init(frame: frame)
        self.viewModel.delegate = self
        isHidden = true
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        educationImageView.setAnchorPoint(CGPoint(x: 0.5, y: 1))
    }

    func setupLayout() {
        addSubview(balancedView)
        addSubview(yawableBalanceView)
        addSubview(educationImageView)
        addSubview(calibrationTitleLabel)
        var heightAspectRatio: CGFloat = 0
        var widthAspectRatio: CGFloat = 0
        var imageTitleverticalSpace: CGFloat = 32
        if UIDevice.current.orientation.isLandscape {
            heightAspectRatio = 0.32
            widthAspectRatio = 0.28
            imageTitleverticalSpace = 15
        } else {
            heightAspectRatio = 0.28
            widthAspectRatio = 0.32
        }

        var constraints: [NSLayoutConstraint] = []
        constraints.append(balancedView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(balancedView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20))
        constraints.append(yawableBalanceView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(yawableBalanceView.centerYAnchor.constraint(equalTo: balancedView.centerYAnchor))
        constraints.append(educationImageView.centerYAnchor.constraint(equalTo: balancedView.centerYAnchor))
        constraints.append(educationImageView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(calibrationTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(educationImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthAspectRatio, constant: 1))
        constraints.append(educationImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightAspectRatio, constant: 1))
        constraints.append(calibrationTitleLabel.topAnchor.constraint(equalTo: educationImageView.bottomAnchor, constant: imageTitleverticalSpace))
        NSLayoutConstraint.activate(constraints)
    }

    func yaw(to angle: Double) {
        guard animatingEducation == false else { return }
        let radsAngle = Double.deg2rad(angle)
        let newTransform: CGAffineTransform = CGAffineTransform(rotationAngle: CGFloat(radsAngle))
        yawableBalanceView.transform = newTransform
        yawableBalanceView.centerImageView.image = viewModel.arrowImage
        if yawableBalanceView.alpha == 0 {
            UIView.animate(withDuration: 0.1) {
                self.yawableBalanceView.alpha = 1
            }
        }
        isCalibrated = false
    }

    func calibrationCompleted() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.yawableBalanceView.alpha = 0
        }
        if !isCalibrated && !isHidden {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            calibrationCompletedTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                                             repeats: false, block: {[weak self] _ in
                                                                guard let self = self else { return }
                                                                UIView.animate(withDuration: 0.2, delay: 0,
                                                                               options: [.curveEaseOut, .beginFromCurrentState]) {
                                                                    self.alpha = 0
                                                                } completion: { _ in
                                                                    self.isHidden = true
                                                                    self.alpha = 1 //reseting alpha value
                                                                }
                                                                self.calibrationCompletedTimer?.invalidate()
                                                                self.calibrationCompletedTimer = nil
                                                             })
        }
        isCalibrated = true
    }

    func beginEducation() {
        self.viewModel.startCalibrating()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if UIDevice.current.orientation.isLandscape {
            educationImageView.image = UIImage(named: "educationImage_landscape", in: .module, compatibleWith: nil)
        } else {
            educationImageView.image = UIImage(named: "educationImage", in: .module, compatibleWith: nil)
        }
    }

    func showEducationViewIfNeeded() {
        guard viewModel.shouldEducate,
              animatedEdutcation == false,
              animatingEducation == false else {
            return
        }
        isHidden = false
        animatingEducation = true
        let animationDuration: Double = 3
        balancedView.transform = balancedView.transform.scaledBy(x: 0.001, y: 0.001)
        UIView.animateKeyframes(withDuration: animationDuration,
                                delay: 0,
                                options: [.calculationModeCubic]) {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 0.2) {
                                        self.educationImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.deg2rad(24)))
                                    }
                                    UIView.addKeyframe(withRelativeStartTime: 0.2,
                                                       relativeDuration: 0.4) {
                                        self.educationImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.deg2rad(-24)))
                                    }

                                    UIView.addKeyframe(withRelativeStartTime: 0.60,
                                                       relativeDuration: 0.2) {
                                        self.educationImageView.transform = CGAffineTransform(rotationAngle: 0)
                                    }

                                    UIView.addKeyframe(withRelativeStartTime: 0.8,
                                                       relativeDuration: 0.2) {
                                        self.educationImageView.alpha = 0
                                        self.calibrationTitleLabel.alpha = 0
                                    }

                                } completion: {[weak self] _ in
                                    guard let self = self else { return }
                                    self.animatedEdutcation = true
                                    self.animatingEducation = false
                                }

        UIView.animate(withDuration: 0.2,
                       delay: animationDuration - 0.5,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.1,
                       options: UIView.AnimationOptions.curveEaseOut) {
            self.balancedView.alpha = 1
            self.balancedView.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.yawableBalanceView.alpha = 1
            }
        }
    }
}

// MARK: VisionCalibrationViewViewModelDelegate

extension VisionCalibrationView: VisionCalibrationViewViewModelDelegate {
    func calibrationViewModelDidMatchHorizon() {
        calibrationCompleted()
    }

    func calibrationViewModelShouldRotate(at angle: Double) {
        showEducationViewIfNeeded()
//        print(angle)
        yaw(to: angle)
        self.calibrationCompletedTimer?.invalidate()
        self.calibrationCompletedTimer = nil
    }
}

// MARK: - BalanceView

class BalanceView: UIView {
    private let isStatic: Bool
    private let kCircleWith: CGFloat = 36 //half width only
    private let kLineWith: CGFloat = 92

    public lazy var centerImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: kCircleWith * 2).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: kCircleWith * 2).isActive = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .white
        return imageView
    }()

    private lazy var centerText: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 38)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: kCircleWith * 2).isActive = true
        label.widthAnchor.constraint(equalToConstant: kCircleWith * 2).isActive = true
        label.isHidden = true
        label.textAlignment = .center
        label.text = "vision.calibration.ok".localized.uppercased()
        return label
    }()

    init(frame: CGRect, isStatic: Bool) {
        self.isStatic = isStatic
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(centerImageView)
        addSubview(centerText)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(centerImageView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(centerImageView.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(centerText.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(centerText.centerYAnchor.constraint(equalTo: centerYAnchor))
        centerText.isHidden = !isStatic
        centerImageView.isHidden = isStatic
        NSLayoutConstraint.activate(constraints)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let strokeColor: UIColor = isStatic ? Styling.positivePrimary : Styling.negativePrimary
        let circlePath = UIBezierPath(ovalIn: CGRect(x: bounds.midX - kCircleWith,
                                                     y: bounds.midY - kCircleWith,
                                                     width: kCircleWith * 2,
                                                     height: kCircleWith * 2))
        let linePath = UIBezierPath()
        linePath.lineCapStyle = .round
        let initialPoint1 = CGPoint(x: bounds.midX - kCircleWith - 10 - kLineWith, y: bounds.midY)
        linePath.move(to: initialPoint1)
        linePath.addLine(to: CGPoint(x: initialPoint1.x + kLineWith, y: initialPoint1.y))
        let initialPoint2 = CGPoint(x: bounds.midX + kCircleWith + 10, y: bounds.midY)
        linePath.move(to: initialPoint2)
        linePath.addLine(to: CGPoint(x: initialPoint2.x + kLineWith, y: bounds.midY))
        linePath.lineWidth = 8
        strokeColor.set()
        linePath.stroke()
        circlePath.fill()
    }
}
