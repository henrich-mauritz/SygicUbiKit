import UIKit

/// SliderButtonContrainerView is a Container primarly designed for the slider button
/// Usage: SliderButtonContainerView.init( startBlock, stopBlock); addSubview()
class SliderButtonContainerView: UIView {
    public var isOn: Bool {
        get {
            button.buttonPosition == .stop
        }
        set {
            guard newValue != isOn else { return }
            if newValue {
                leadingButtonConstraint.constant = endingConstant
                button.buttonPosition = .stop
                animateStateChange()
            } else {
                leadingButtonConstraint.constant = startingConstant
                button.buttonPosition = .start
            }
        }
    }

    public var enabled: Bool = true {
        didSet {
            button.alpha = enabled ? 1 : Styling.disabledStateAlpha
        }
    }

    public var textColor: UIColor? {
        set {
            button.label.textColor = newValue
        }

        get {
            return button.label.textColor
        }
    }

    public var buttonColor: UIColor? {
        set {
            button.backgroundColor = newValue
        }

        get {
            return button.backgroundColor
        }
    }

    public var startString: String {
        set {
            button.startString = newValue
        }

        get {
            return button.startString
        }
    }

    public var stopString: String {
        set {
            button.stopString = newValue
        }

        get {
            return button.stopString
        }
    }

    private let cornerRadius: CGFloat = Styling.driveSliderKnowCornerRadious
    private let innerMargin: CGFloat = 8.0
    private let buttonHeight: CGFloat = 60.0
    private let buttonWidth: CGFloat = 120.0
    private let velocity: CGFloat = 230.0
    private let startingConstant: CGFloat = 8.0
    private let animationDuration: Double = 0.2
    private var endingConstant: CGFloat = 120.0 {
        didSet {
            if oldValue != endingConstant && isOn {
                leadingButtonConstraint.constant = endingConstant
            }
        }
    }

    private var minimumLeftPosition: CGFloat = 68.0
    private var maximumRightPosition: CGFloat = 178.0

    private var leadingButtonConstraint = NSLayoutConstraint()
    private let button: SliderButtonView = SliderButtonView()
    private var canContinueBlock: (() -> Bool)?
    /// This init method is used to init the SliderButtonContainerView view blocks of code to do when
    /// when you press start/stop
    /// - Parameter startBlock: block to execute when button switches to strating position
    /// - Parameter stopBlock: block to execute when button switches to ending position
    init(canContinueBlock: (() -> Bool)? = nil, startBlock: @escaping () -> Void, stopBlock: @escaping () -> Void) {
        super.init(frame: .zero)
        initSetup()
        self.canContinueBlock = canContinueBlock
        button.startBlock = startBlock
        button.stopBlock = stopBlock
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setOn(_ turnOn: Bool, animated: Bool) {
        guard turnOn != isOn else { return }
        if animated {
            if turnOn {
                animateToEndPosition()
            } else {
                animateToStartingPosition()
            }
        } else {
            isOn = turnOn
        }
    }

    private func initSetup() {
        backgroundColor = UIColor.backgroundOverlay.withAlphaComponent(0.5)
        layer.cornerRadius = cornerRadius
        autoresizesSubviews = true
        addSubview(button)
        setupConstraintsForButton()
        setupTapGesture()
        setupPanGesture()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        initPositionConstants()
    }

    private func initPositionConstants() {
        minimumLeftPosition = buttonWidth / 2 + innerMargin
        maximumRightPosition = frame.width - buttonWidth / 2 - innerMargin
        endingConstant = frame.width - buttonWidth - innerMargin
    }

    private func setupConstraintsForButton() {
        button.translatesAutoresizingMaskIntoConstraints = false
        leadingButtonConstraint = button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: innerMargin)
        let bottomConstraint = button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -innerMargin)
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: buttonWidth)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: buttonHeight)

        let constraints = [ leadingButtonConstraint, bottomConstraint, widthConstraint, heightConstraint ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        button.addGestureRecognizer(tap)
    }

    private func setupPanGesture() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
        button.addGestureRecognizer(gestureRecognizer)
    }

    @objc
private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard enabled else { return }
        if button.center.x != minimumLeftPosition {
            return
        }
        leadingButtonConstraint.constant = 40
        UIView.animate(withDuration: animationDuration, delay: 0, options: [], animations: {
            self.layoutIfNeeded()
        }, completion: { val in
            if val {
                self.secondAnimation()
            }
        })
    }

    private func secondAnimation() {
        leadingButtonConstraint.constant = innerMargin
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [.curveEaseOut, .beginFromCurrentState], animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }

    private func animateToStartingPosition() {
        leadingButtonConstraint.constant = startingConstant
        UIView.animate(withDuration: animationDuration, delay: 0, options: [], animations: {
            self.layoutIfNeeded()
        }, completion: {_ in
            self.button.buttonPosition = .start
        })
    }

    private func animateToEndPosition() {
        leadingButtonConstraint.constant = endingConstant
        UIView.animate(withDuration: animationDuration, delay: 0, options: [], animations: {
            self.layoutIfNeeded()
            let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedbackgenerator.prepare()
            impactFeedbackgenerator.impactOccurred()
        }, completion: {[weak self] _ in
            guard let self = self else { return }
            if let canContinueBlock = self.canContinueBlock {
                let canContinue = canContinueBlock()
                if canContinue == false {
                    self.button.buttonPosition = .start
                    self.leadingButtonConstraint.constant = self.startingConstant
                    return
                }
            }
            self.button.buttonPosition = .stop
            self.animateStateChange()
        })
    }

    @objc
private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard enabled else { return }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            panGestureBeginChanged(gestureRecognizer: gestureRecognizer)
        } else if gestureRecognizer.state == .ended {
            panGestureEnded(gestureRecognizer: gestureRecognizer)
        }
    }

    private func panGestureBeginChanged(gestureRecognizer: UIPanGestureRecognizer) {
        guard let recognizerView = gestureRecognizer.view else { return }
        let translation = gestureRecognizer.translation(in: button)
        if recognizerView.center.x + translation.x < minimumLeftPosition {
            leadingButtonConstraint.constant = startingConstant
        } else if recognizerView.center.x + translation.x > maximumRightPosition {
            leadingButtonConstraint.constant = endingConstant
        } else {
            leadingButtonConstraint.constant = leadingButtonConstraint.constant + translation.x
        }
        gestureRecognizer.setTranslation(CGPoint.zero, in: button)
    }

    private func panGestureEnded(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.velocity(in: button).x > velocity {
            animateToEndPosition()
            return
        }
        if gestureRecognizer.velocity(in: button).x < -velocity {
            animateToStartingPosition()
            return
        }
        if button.center.x >= minimumLeftPosition && button.center.x < maximumRightPosition * 2 / 3 {
            animateToStartingPosition()
        } else {
            animateToEndPosition()
        }
    }

    private func animateStateChange() {
        guard let config = DrivingManager.shared.configuration, config.animateDriveStateChange == true else {
            return
        }

        let begingColor: UIColor? = backgroundColor
        let endColor: UIColor? = Styling.foregroundPrimary.darker(amount: 0.7)
        let easeOutAnimation = KeyframeAnimationOptions(rawValue: UIView.AnimationOptions.curveEaseOut.rawValue)

        UIView.animateKeyframes(withDuration: 1,
                                delay: 0.0,
                                options: [easeOutAnimation], animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 0.35) {
                                        self.backgroundColor = endColor
                                    }
                                    UIView.addKeyframe(withRelativeStartTime: 0.65,
                                                       relativeDuration: 0.35) {
                                        self.backgroundColor = begingColor
                                    }
                                })
    }
}
