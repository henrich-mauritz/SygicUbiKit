import UIKit

// MARK: - VPTooltipViewDelegate

protocol VPTooltipViewDelegate: AnyObject {
    func didTapCarControl()
    func didTapUnderstand()
    func didTapOutterBounds()
}

// MARK: - VPTooltipView

class VPTooltipView: UIView, InjectableType {
    public weak var delegate: VPTooltipViewDelegate?
    private let maskLayer: CAShapeLayer = CAShapeLayer()

    private var animateOutCompletion: (() -> Void)?

    private lazy var carPicker: VPVehicleSelectorControl = {
        var control: VPVehicleSelectorControl!
        if let currentSelectedCar = container.resolveVehicleProfileRepo().storedVehicles.filter({ $0.isSelectedForDriving ?? false }).first {
            control = VPVehicleSelectorControl(with: .bubble, controlSize: .big, icon: currentSelectedCar.vehicleType.icon, title: currentSelectedCar.name.uppercased())
        } else {
            control = VPVehicleSelectorControl(with: .bubble, controlSize: .big, icon: VehicleType.car.icon, title: "VEHICLE")
        }
        control.addTarget(self, action: #selector(VPTooltipView.carPickerTap), for: .touchUpInside)
        return control
    }()

    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.regular, with: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "vehicleProfile.tooltip.text".localized
        return label
    }()

    private lazy var understandButton: StylingButton = {
        let button = StylingButton.button(with: .plain)
        button.titleLabel.text = "vehicleProfile.tooltip.button".localized
        button.addTarget(self, action: #selector(VPTooltipView.didTapUnderstand), for: .touchUpInside)
        return button
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 35
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var topContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Styling.backgroundOverlay.withAlphaComponent(0.9)
        view.alpha = 0.0
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        backgroundColor = .clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(VPTooltipView.gestureTap))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        addSubview(topContainerView)
        var topMargin: CGFloat = 0
        if let window = UIApplication.shared.windows.first {
            topMargin = window.safeAreaInsets.top
        }
        topContainerView.cover(with: mainStackView, insets: NSDirectionalEdgeInsets(top: topMargin, leading: 16, bottom: 60, trailing: 16))
        mainStackView.addArrangedSubview(carPicker)
        mainStackView.addArrangedSubview(tipLabel)
        mainStackView.addArrangedSubview(understandButton)
        var constraints: [NSLayoutConstraint] = []
        constraints.append(topContainerView.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(topContainerView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(topContainerView.trailingAnchor.constraint(equalTo: trailingAnchor))
        NSLayoutConstraint.activate(constraints)
    }

    func animateIn() {
        var initialFrame = carPicker.frame
        initialFrame = CGRect(x: initialFrame.origin.x + 15, y: initialFrame.origin.y + mainStackView.frame.origin.y, width: initialFrame.width, height: initialFrame.height)
        let initialPath: CGPath = UIBezierPath(ovalIn: initialFrame).cgPath
        maskLayer.frame = topContainerView.bounds
        var endframe = maskLayer.frame.insetBy(dx: -200, dy: -50)
        endframe.origin.y -= 50
        let endPath: CGPath = UIBezierPath(ovalIn: endframe).cgPath
        topContainerView.layer.mask = maskLayer
        animate(from: initialPath, to: endPath)
    }

    func animateOut(completion: @escaping (() -> Void)) {
        guard let initialPath = maskLayer.path else {
            completion()
            return
        }
        self.animateOutCompletion = completion
        var endframe = carPicker.frame
        endframe = CGRect(x: endframe.origin.x + 15, y: endframe.origin.y + mainStackView.frame.origin.y, width: endframe.width, height: endframe.height)
        let endPath: CGPath = UIBezierPath(ovalIn: endframe).cgPath
        animate(from: initialPath, to: endPath, delegate: self)
    }

    @objc
func carPickerTap() {
        delegate?.didTapCarControl()
    }

    @objc
func didTapUnderstand() {
        delegate?.didTapUnderstand()
    }

    @objc
func gestureTap() {
        delegate?.didTapOutterBounds()
    }
}

// MARK: UIGestureRecognizerDelegate

extension VPTooltipView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        return !topContainerView.frame.contains(location)
    }
}

// MARK: CAAnimationDelegate

//MARK: - Animation

extension VPTooltipView: CAAnimationDelegate {
    private func animate(from initialPath: CGPath, to endPath: CGPath, delegate: CAAnimationDelegate? = nil) {
        maskLayer.path = initialPath
        let animation = CABasicAnimation(keyPath: "path")
        animation.delegate = delegate
        animation.duration = 0.2
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fromValue = initialPath
        animation.toValue = endPath
        maskLayer.path = endPath
        maskLayer.add(animation, forKey: "growAnimation")
        topContainerView.alpha = 1.0
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let completion = animateOutCompletion else { return }
        completion()
    }
}
