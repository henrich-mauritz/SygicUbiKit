import UIKit

// MARK: - SimpleDrivingViewDelegate

@objc
protocol SimpleDrivingViewDelegate where Self: UIViewController {
    var distractionAnimationEnable: Bool { get set }
    var resultViewController: DrivingResultViewController? { get set }
    func closeButtonTap(_ sender: UITapGestureRecognizer)
    func displayVehiclePicker()
}

// MARK: - SimpleDrivingView

class SimpleDrivingView: UIView {
    weak var delegate: SimpleDrivingViewDelegate?

    public var viewModel: DrivingViewModel?
    public var presentationAnimating: Bool = false
    public var presentingSummary: Bool = false

    private let speedLimitView = SpeedLimitView()
    private let margin: CGFloat = 24
    private let buttonBottomMargin: CGFloat = 52
    private let statusBottom: CGFloat = 23
    private let statusHeight: CGFloat = 34
    private let buttonMargin: CGFloat = 64
    private let buttonHeight: CGFloat = 76
    private var distractionAnimating: Bool = false

    private var currentResultsConstraints: [NSLayoutConstraint] = []
    private var portraitLayoutConstraints: [NSLayoutConstraint] = []
    private var landscapeLayoutConstraints: [NSLayoutConstraint] = []

    var isTripRuning: Bool = false {
        didSet {
            startStopButton.isOn = isTripRuning
        }
    }

    public var imageView: UIImageView = UIImageView()

//MARK: - Lazy properties

    public lazy var buttonBottomConstraint: NSLayoutConstraint? = {
        startStopButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -buttonBottomMargin)
    }()

    public lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .buttonBackgroundTertiaryPassive
        button.tintColor = .buttonForegroundTertiaryPassive
        button.layer.cornerRadius = 56 / 2
        button.setImage(UIImage(named: "drivingDismissIcon", in: .module, compatibleWith: nil), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 56).isActive = true
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        if let delegate = self.delegate {
            button.addTarget(delegate, action: #selector(delegate.closeButtonTap(_:)), for: .touchUpInside)
        }
        return button
    }()
    
    private lazy var selectedVehicleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        label.text = "driving.statusGetReady".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var startStopButton: SliderButtonContainerView!

    private lazy var speedMetricLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        label.text = "driving.velocityMetric".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var currentSpeedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = UIFont.stylingFont(.bold, with: 120)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0"
        return label
    }()

    private lazy var eventsGradientView: DrivingEventsGradientView = {
        let view = DrivingEventsGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var middleViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentSpeedLabel)
        view.addSubview(speedMetricLabel)
        return view
    }()

    private lazy var distractionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        label.text = "driving.distraction".localized
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    //MARK: - initializers

    required init(viewDelegate: SimpleDrivingViewDelegate, viewModel: DrivingViewModel?) {
        self.viewModel = viewModel
        self.delegate = viewDelegate
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var carPickerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5
        view.cover(with: stackView)
        stackView.addArrangedSubview(selectedVehicleLabel)
        let arrowButtonImage = UIImage(named: "carSelectorControlArrow", in: .module, compatibleWith: nil)
        let arrowimageView = UIImageView(image: arrowButtonImage)
        arrowimageView.tintColor = Styling.foregroundDriving
        stackView.addArrangedSubview(arrowimageView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SimpleDrivingView.showVehicleProfile))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.isHidden = true
        return view
    }()

    private func initImageView() {
        imageView.image = UIImage(named: "car", in: .module, compatibleWith: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0
        addSubview(imageView)
    }

    private func initButtonView() {
        guard let viewModel = self.viewModel else { return }
        startStopButton = SliderButtonContainerView(
            canContinueBlock: {
                guard let vehicleType = viewModel.currentVehicle?.vehicleType else {
                    return true
                }
                let shouldContinue = !viewModel.isInOffSeasson(for: vehicleType)
                defer {
                    if !shouldContinue {
                        VehicleProfileModule.presentOffSeasonPopUp(on: self.delegate!)
                    }
                }
                return shouldContinue
            },
            startBlock: { [weak self] in
                guard let self = self,
                        let viewModel = self.viewModel,
                        !viewModel.driving,
                        let delegate = self.delegate else { return }
                if DrivingPermissionsPopupViewController.shouldShowPermissionsPopup(automaticTripDetection: false) {
                    self.startStopButton.setOn(false, animated: true)
                    PopupManager.shared.presentModalPopup(DrivingPermissionsPopupViewController(requireLocationAlwaysPermisson: false), on: delegate)
                } else {
                    viewModel.startTrip()
                }
                AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.drivingStartButtonSwipe, parameters: nil)
            },
            stopBlock: { [weak self] in
                guard let self = self,
                      let viewModel = self.viewModel,
                      viewModel.driving else { return }
                viewModel.stopTrip()
            }
        )
        startStopButton.isOn = viewModel.driving
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        startStopButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        addSubview(startStopButton)
    }

    private func initSpeedLimit() {
        speedLimitView.translatesAutoresizingMaskIntoConstraints = false
        speedLimitView.widthAnchor.constraint(equalToConstant: 110).isActive = true
        speedLimitView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        speedLimitView.speedLabel.font = UIFont.stylingFont(.bold, with: 39)
        speedLimitView.strokeWidth = 10
        speedLimitView.isHidden = true
        addSubview(speedLimitView)
    }

    private func setupLayout() {
        cover(with: eventsGradientView, toSafeArea: false)
        initImageView()
        initButtonView()
        initSpeedLimit()
        addSubview(closeButton)
        addSubview(middleViewContainer)
        addSubview(statusLabel)
        addSubview(distractionLabel)

        var constraints: [NSLayoutConstraint] = []
        constraints.append(speedLimitView.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(speedLimitView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margin))
        constraints.append(closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin))
        constraints.append(closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margin))
        constraints.append(middleViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(middleViewContainer.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(middleViewContainer.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30))
        constraints.append(startStopButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: buttonMargin))
        constraints.append(startStopButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -buttonMargin))
        constraints.append(buttonBottomConstraint!)
        constraints.append(statusLabel.bottomAnchor.constraint(equalTo: startStopButton.topAnchor, constant: -statusBottom))
        constraints.append(statusLabel.heightAnchor.constraint(equalToConstant: statusHeight))
        constraints.append(statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin))
        constraints.append(statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin))
        constraints.append(distractionLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(distractionLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 50))
        constraints.append(distractionLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -50))
        constraints.append(imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 70))
        constraints.append(imageView.heightAnchor.constraint(equalToConstant: 280))
        constraints.append(imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2 * margin))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2 * margin))
        
        addSubview(carPickerView)
        carPickerView.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor).isActive = true
        carPickerView.centerXAnchor.constraint(equalTo: statusLabel.centerXAnchor).isActive = true
        
        portraitLayoutConstraints = constraints
        activateConstraints()

        constraints = [] //the follwoing constriants shall not change
        constraints.append(currentSpeedLabel.leadingAnchor.constraint(equalTo: middleViewContainer.leadingAnchor))
        constraints.append(currentSpeedLabel.trailingAnchor.constraint(equalTo: middleViewContainer.trailingAnchor))
        constraints.append(currentSpeedLabel.topAnchor.constraint(equalTo: middleViewContainer.topAnchor))
        constraints.append(speedMetricLabel.leadingAnchor.constraint(equalTo: middleViewContainer.leadingAnchor))
        constraints.append(speedMetricLabel.trailingAnchor.constraint(equalTo: middleViewContainer.trailingAnchor))
        constraints.append(speedMetricLabel.bottomAnchor.constraint(equalTo: middleViewContainer.bottomAnchor))
        constraints.append(currentSpeedLabel.bottomAnchor.constraint(equalTo: speedMetricLabel.topAnchor, constant: 5))
        NSLayoutConstraint.activate(constraints)
    }

    private func createLandscapeConstraints() {
        var constraints: [NSLayoutConstraint] = []
        //ImageView
        constraints.append(imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16))
        constraints.append(imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16))
        constraints.append(imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16))
        constraints.append(imageView.trailingAnchor.constraint(lessThanOrEqualTo: startStopButton.leadingAnchor, constant: -16))

        //StartStopButton
        constraints.append(startStopButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32))
        constraints.append(startStopButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -25))
        constraints.append(startStopButton.widthAnchor.constraint(equalToConstant: 250))

        //InfoLabel
        constraints.append(statusLabel.bottomAnchor.constraint(equalTo: startStopButton.topAnchor, constant: -12))
        constraints.append(statusLabel.centerXAnchor.constraint(equalTo: startStopButton.centerXAnchor))
        constraints.append(statusLabel.widthAnchor.constraint(equalTo: startStopButton.widthAnchor))

        //DistractionLabel
        constraints.append(distractionLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(distractionLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 50))
        constraints.append(distractionLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -50))

        //TextViewContainer *Current speed and units*
        constraints.append(middleViewContainer.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(middleViewContainer.trailingAnchor.constraint(equalTo: startStopButton.leadingAnchor, constant: -40))
        constraints.append(middleViewContainer.centerYAnchor.constraint(equalTo: centerYAnchor))

        //Speed limit
        constraints.append(speedLimitView.centerXAnchor.constraint(equalTo: startStopButton.centerXAnchor, constant: 0))
        constraints.append(speedLimitView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margin))

        //close button
        constraints.append(closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -margin))
        constraints.append(closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: margin))

        landscapeLayoutConstraints = constraints
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        activateConstraints()
        guard let delegate = self.delegate, let resultController = delegate.resultViewController else { return }
        prepareContraints(for: resultController)
    }

    private func activateConstraints() {
        var toActivate: [NSLayoutConstraint]!
        var toDeactivate: [NSLayoutConstraint]!
        if UIWindow.isLandscape {
            if landscapeLayoutConstraints.count == 0 {
                createLandscapeConstraints()
            }
            toActivate = landscapeLayoutConstraints
            toDeactivate = portraitLayoutConstraints
        } else {
            toActivate = portraitLayoutConstraints
            toDeactivate = landscapeLayoutConstraints
        }
        NSLayoutConstraint.deactivate(toDeactivate)
        NSLayoutConstraint.activate(toActivate)
    }

    public func viewModelUpdated(_ viewModel: DrivingViewModel) {
        statusLabel.text = viewModel.lastEventTitle
        startStopButton.enabled = viewModel.canStartOrStopTrip
        closeButton.isHidden = false //viewModel.driving
        currentSpeedLabel.text = viewModel.currentSpeed
        currentSpeedLabel.textColor = UIColor.speedingColor(with: viewModel.speedingIntensity)
        speedLimitView.speedLabel.text = viewModel.currentSpeedLimit
        speedLimitView.isHidden = viewModel.currentSpeedLimit == nil || !viewModel.driving
        eventsGradientView.changeGradientIntensity(group: .bottom, intensity: viewModel.accelerationIntensity)
        eventsGradientView.changeGradientIntensity(group: .top, intensity: viewModel.brakingIntensity)
        eventsGradientView.changeGradientIntensity(group: .left, intensity: viewModel.corneringLeftIntensity)
        eventsGradientView.changeGradientIntensity(group: .right, intensity: viewModel.corneringRightIntensity)
        if viewModel.distractionEvent && !distractionAnimating {
            animateDistraction(animateIn: true)
        } else if !viewModel.distractionEvent && distractionAnimating {
            animateDistraction(animateIn: false)
        }
        if let currentVehicle = viewModel.currentVehicle {
            if viewModel.driving {
                statusLabel.isHidden = false
                statusLabel.text = viewModel.lastEventTitle
                carPickerView.isHidden = true
            } else {
                let hasMoreThanOneVehicle = viewModel.hasMoreThanOneVehicle
                statusLabel.isHidden = hasMoreThanOneVehicle
                statusLabel.text = viewModel.lastEventTitle
                carPickerView.isHidden = !hasMoreThanOneVehicle
            }
            selectedVehicleLabel.text = currentVehicle.name.uppercased()

        } else {
            statusLabel.isHidden = false
            statusLabel.text = viewModel.lastEventTitle
            carPickerView.isHidden = true
        }
    }

    /// Just update the position of the start stop button outsid of the loop when the viewModel updates
    /// - Parameter viewModel: viemwode
    func updateStartStopButton(_ viewModel: DrivingViewModel) {
        if !startStopButton.isOn && viewModel.driving {
            startStopButton.setOn(viewModel.driving, animated: false)
        }
    }

    func animateDistraction(animateIn: Bool) {
        guard let delegate = self.delegate, delegate.distractionAnimationEnable, !presentationAnimating else { return }
        guard (animateIn && !distractionAnimating) || (!animateIn && distractionAnimating) else { return }
        let distractionHiddenViews = [startStopButton, statusLabel, middleViewContainer, speedLimitView]
        let animationDuration: TimeInterval = 0.3
        if animateIn {
            distractionAnimating = true
            distractionLabel.alpha = 0
            distractionLabel.isHidden = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
                self.distractionLabel.alpha = 1
                distractionHiddenViews.forEach { $0?.alpha = 0 }
            }, completion: { _ in})
        } else {
            distractionAnimating = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
                self.distractionLabel.alpha = 0
                distractionHiddenViews.forEach { $0?.alpha = 1 }
            }, completion: { finished in
                guard finished else { return }
                self.distractionLabel.isHidden = true
            })
        }
    }
    
    @objc private func showVehicleProfile() {
        //the tap is on the status label so we get that rect
        //let origin = self.window?.convert(statusLabel.frame.origin, to: nil)
        delegate?.displayVehiclePicker()
    }
    
}

extension SimpleDrivingView {
    func prepareContraints(for resultViewController: DrivingResultViewController) {
        guard resultViewController.view.superview == self else { return }
        var constraints = [NSLayoutConstraint]()
        if UIWindow.isPortrait {
            constraints.append(resultViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor))
            constraints.append(resultViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor))
            buttonBottomConstraint = resultViewController.view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            constraints.append(buttonBottomConstraint!)
            constraints.append(resultViewController.view.topAnchor.constraint(equalTo: imageView.bottomAnchor))
        } else {
            constraints.append(resultViewController.view.leadingAnchor.constraint(equalTo: startStopButton.leadingAnchor, constant: 0))
            constraints.append(resultViewController.view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor))
            constraints.append(resultViewController.view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor))
            constraints.append(resultViewController.view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor))
        }

        NSLayoutConstraint.deactivate(currentResultsConstraints)
        NSLayoutConstraint.activate(constraints)
        currentResultsConstraints = constraints
    }

    func prepareForTripResult(completion: @escaping () -> ()) {
        let keepViews: [UIView] = [imageView]
        let discardViews = subviews.filter { !keepViews.contains($0) }
        UIView.animate(withDuration: 0.4, animations: {
            discardViews.forEach { view in
                view.alpha = 0
            }
            keepViews.forEach { $0.alpha = 1 }
            self.layoutIfNeeded()
        }, completion: {
            (_: Bool) in
            self.buttonBottomConstraint = nil
            completion()
        })
    }
}
