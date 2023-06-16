import UIKit

// MARK: - DrivingControllerViewDelegate

@objc
protocol DrivingControllerViewDelegate where Self: UIViewController {
    var distractionAnimationEnable: Bool { get set }
    var resultViewController: DrivingResultViewController? { get set }
    func closeButtonTap(_ sender: UITapGestureRecognizer)
    func shareButtonPressed()
    func displayVehiclePicker()
}

// MARK: - DrivingView

class DrivingView: UIView {
    //MARK: - Private properties

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let spinny = UIActivityIndicatorView(style: .large)
        spinny.tintColor = .foregroundDriving
        spinny.startAnimating()
        return spinny
    }()

    private var debugTripsView: DebugView?
    private let speedLimitView = SpeedLimitView()
    private let statusHeight: CGFloat = 34
    private let statusBottom: CGFloat = 23
    private let labelMargin: CGFloat = 10
    private let arrowSize: CGFloat = 16
    private let arrowMargin: CGFloat = 24
    private let imageTop: CGFloat = 9
    private let imageBottom: CGFloat = 15
    private let buttonHeight: CGFloat = 76
    private let buttonMargin: CGFloat = 64
    private let buttonBottomMargin: CGFloat = 52
    private let textViewHeight: CGFloat = 102
    private let textViewMargin: CGFloat = 64
    private weak var delegate: DrivingControllerViewDelegate?
    private var distractionAnimating: Bool = false

    //MARK: Constraints

    private var portraitLayoutConstraints: [NSLayoutConstraint] = []
    private var landscapeLayoutConstraints: [NSLayoutConstraint] = []
    private var imageViewWidhtConstraint: NSLayoutConstraint?
    private var imageViewHeigthConstraint: NSLayoutConstraint?
    private var currentResultsConstraints: [NSLayoutConstraint] = []
    private var summaryImageTopConstraint: NSLayoutConstraint?

    //MARK: - Public Properties

    var presentationAnimating: Bool = false
    var isTripRuning: Bool = false {
        didSet {
            startStopButton.isOn = isTripRuning
        }
    }

    var currentShownIntensity: Int {
        return textViewContainer.speedingIntensity
    }

    public var viewModel: DrivingViewModel?

    public var imageView: UIImageView = UIImageView()
    //public var gradientViewContainer: GradientViewContainer!
    public var presentingSummary: Bool = false
    public var closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .buttonBackgroundTertiaryPassive
        button.tintColor = .buttonForegroundTertiaryPassive
        button.layer.cornerRadius = 56 / 2
        button.setImage(UIImage(named: "drivingDismissIcon", in: .module, compatibleWith: nil), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 56).isActive = true
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()

    public lazy var buttonBottomConstraint: NSLayoutConstraint? = {
        startStopButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -buttonBottomMargin)
    }()

    private lazy var imageViewTopContraint: NSLayoutConstraint = {
        imageView.topAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: imageTop)
    }()

    private lazy var imageViewBottomContraint: NSLayoutConstraint = {
        imageView.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -imageBottom)
    }()

    private var startStopButton: SliderButtonContainerView!

    private let textViewContainer: DrivingTextContainer = {
        let textViewContainer = DrivingTextContainer()
        textViewContainer.speedDimension = "km/h"
        textViewContainer.speed = "0"
        return textViewContainer
    }()

    private var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var selectedVehicleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        return label
    }()

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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DrivingView.showVehicleProfile))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.isHidden = true
        return view
    }()

    private var distractionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundDriving
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.textAlignment = .center
        label.text = "driving.distraction".localized
        label.minimumScaleFactor = 0.2
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        return label
    }()

    private lazy var eventsGradientView: DrivingEventsGradientView = {
        let view = DrivingEventsGradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //MARK: - LifeCycle

    required init(viewDelegate: DrivingControllerViewDelegate, viewModel: DrivingViewModel?) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        self.delegate = viewDelegate
        setupLayout()
        guard let vehicle = viewModel?.currentVehicle else {
            imageView.image = UIImage(named: "car", in: .module, compatibleWith: nil)
            return
        }
        if vehicle.vehicleType == .motorcycle {
            imageView.image = UIImage(named: "motorbikeDrivingVehicle", in: .module, compatibleWith: nil)
        } else {
            imageView.image = UIImage(named: "car", in: .module, compatibleWith: nil)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        addSubview(startStopButton)
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func initTextView() {
        addSubview(textViewContainer)
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
    }

    private func initArrowView() {
        guard let delegate = delegate else {
            return
        }
        closeButton.addTarget(delegate, action: #selector(delegate.closeButtonTap(_:)), for: .touchUpInside)
        addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
    }

    private func initImageView() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        if ADASDebug.enabled {
            let debugTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(initDebugView))
            debugTapRecognizer.numberOfTapsRequired = 3
            debugTapRecognizer.cancelsTouchesInView = false
            addGestureRecognizer(debugTapRecognizer)
        }
    }

    private func initStatusLabel() {
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        distractionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)
        addSubview(distractionLabel)
        distractionLabel.isHidden = true
    }

    private func initSpeedLimit() {
        speedLimitView.isHidden = true
        speedLimitView.translatesAutoresizingMaskIntoConstraints = false
        speedLimitView.widthAnchor.constraint(equalToConstant: 74).isActive = true
        speedLimitView.heightAnchor.constraint(equalToConstant: 74).isActive = true
        addSubview(speedLimitView)
    }

    private func setupLayout() {
        backgroundColor = .backgroundDriving
        layoutGradientView()
        initButtonView()
        initArrowView()
        initTextView()
        initImageView()
        initStatusLabel()
        initSpeedLimit()
        setupConstraintsForView()
        hideUIElements(true)
    }

    private func layoutGradientView() {
        eventsGradientView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(eventsGradientView)
        eventsGradientView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        eventsGradientView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        eventsGradientView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        eventsGradientView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    func setupActivityIndicatorIfNeeded() {
        guard let viewModel = viewModel, !viewModel.drivingLibInitialized else { return }
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        var constraints = [NSLayoutConstraint]()
        constraints.append(activityIndicator.centerXAnchor.constraint(equalTo: statusLabel.centerXAnchor))
        constraints.append(activityIndicator.bottomAnchor.constraint(equalTo: statusLabel.topAnchor, constant: -8))
        NSLayoutConstraint.activate(constraints)
    }

    func setupConstraintsForView() {
        startStopButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        var constraints: [NSLayoutConstraint] = []

        constraints.append(textViewContainer.centerXAnchor.constraint(equalTo: centerXAnchor))
        constraints.append(textViewContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 2 * arrowMargin))
        constraints.append(textViewContainer.heightAnchor.constraint(equalToConstant: textViewHeight))

        constraints.append(imageView.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(imageView.trailingAnchor.constraint(equalTo: trailingAnchor))

        constraints.append(imageViewTopContraint)
        constraints.append(imageViewBottomContraint)

        constraints.append(statusLabel.bottomAnchor.constraint(equalTo: startStopButton.topAnchor, constant: -statusBottom))
        constraints.append(statusLabel.heightAnchor.constraint(equalToConstant: statusHeight))
        constraints.append(statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: labelMargin))
        constraints.append(statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -labelMargin))
        constraints.append(statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor))

        constraints.append(distractionLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        constraints.append(distractionLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 50))
        constraints.append(distractionLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -50))

        constraints.append(startStopButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: buttonMargin))
        constraints.append(startStopButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -buttonMargin))
        constraints.append(buttonBottomConstraint!)

        constraints.append(closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -arrowMargin))
        constraints.append(closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: arrowMargin))

        constraints.append(speedLimitView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: arrowMargin))
        constraints.append(speedLimitView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: arrowMargin))
        constraints.append(speedLimitView.widthAnchor.constraint(equalToConstant: 74))
        constraints.append(speedLimitView.heightAnchor.constraint(equalToConstant: 74))

        addSubview(carPickerView)
        carPickerView.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor).isActive = true
        carPickerView.centerXAnchor.constraint(equalTo: statusLabel.centerXAnchor).isActive = true

        portraitLayoutConstraints = constraints
        NSLayoutConstraint.activate(constraints)
    }

    private func createLandscapeConstraints() {
        var constraints: [NSLayoutConstraint] = []
        //ImageView
        constraints.append(imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 36))
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
        constraints.append(textViewContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -88))
        constraints.append(textViewContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 4))
        constraints.append(textViewContainer.heightAnchor.constraint(equalToConstant: textViewHeight))

        //Speed limit
        constraints.append(speedLimitView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -245))
        constraints.append(speedLimitView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: arrowMargin))

        //close button
        constraints.append(closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -arrowMargin))
        constraints.append(closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: arrowMargin))
        
        landscapeLayoutConstraints = constraints
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let isLandscape = UIDevice.current.orientation.isLandscape
        var toActivate: [NSLayoutConstraint]!
        var toDeactivate: [NSLayoutConstraint]!
        if isLandscape {
            if landscapeLayoutConstraints.count == 0 {
                createLandscapeConstraints()
            }
            toActivate = landscapeLayoutConstraints
            toDeactivate = portraitLayoutConstraints
            if presentingSummary && imageViewHeigthConstraint != nil {
                toDeactivate.append(imageViewHeigthConstraint!)
                toDeactivate.append(imageViewWidhtConstraint!)
                toDeactivate.append(summaryImageTopConstraint!)
            }
        } else {
            toActivate = portraitLayoutConstraints
            toDeactivate = landscapeLayoutConstraints
        }
        NSLayoutConstraint.deactivate(toDeactivate)
        NSLayoutConstraint.activate(toActivate)
        if !isLandscape && presentingSummary {
            NSLayoutConstraint.deactivate([imageViewTopContraint, imageViewBottomContraint])
            summaryImageTopConstraint?.isActive = false
            summaryImageTopConstraint = imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            if imageViewWidhtConstraint == nil {
                imageViewWidhtConstraint = imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width)
                imageViewHeigthConstraint = imageView.heightAnchor.constraint(equalToConstant: imageView.frame.height)
            }
            NSLayoutConstraint.activate([summaryImageTopConstraint!, imageViewWidhtConstraint!, imageViewHeigthConstraint!])
        }
        guard let delegate = self.delegate, let resultController = delegate.resultViewController else { return }
        prepareContraints(for: resultController)
    }

    @objc
private func initDebugView(_ sender: UIGestureRecognizer?) {
            guard debugTripsView == nil else { return }
            if let recognizer = sender {
                removeGestureRecognizer(recognizer)
            }
            let debugView = DebugView(frame: .zero)
            debugView.shareButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
            debugView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(debugView)
            debugView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100).isActive = true
            debugView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
            debugView.heightAnchor.constraint(equalToConstant: 400).isActive = true
            debugTripsView = debugView
    }

    @objc
func shareButtonPressed() {
    guard let delegate = self.delegate else { return }
        delegate.shareButtonPressed()
    }

    public func viewModelUpdated(_ viewModel: DrivingViewModel) {
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

        startStopButton.enabled = viewModel.canStartOrStopTrip
        if !closeButton.isHidden {
            closeButton.isHidden = false //viewModel.driving
        }
        textViewContainer.speed = viewModel.currentSpeed
        textViewContainer.speedingIntensity = viewModel.speedingIntensity
        speedLimitView.speedLabel.text = viewModel.currentSpeedLimit
        speedLimitView.isHidden = (viewModel.currentSpeedLimit == nil) || !viewModel.driving
        eventsGradientView.changeGradientIntensity(group: .bottom, intensity: viewModel.accelerationIntensity)
        eventsGradientView.changeGradientIntensity(group: .top, intensity: viewModel.brakingIntensity)
        eventsGradientView.changeGradientIntensity(group: .left, intensity: viewModel.corneringLeftIntensity)
        eventsGradientView.changeGradientIntensity(group: .right, intensity: viewModel.corneringRightIntensity)
        if viewModel.distractionEvent && !distractionAnimating {
            animateDistraction(animateIn: true)
        } else if !viewModel.distractionEvent && distractionAnimating {
            animateDistraction(animateIn: false)
        }
        if viewModel.drivingLibInitialized {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        guard let debugView = debugTripsView else { return }
        debugView.debugInfoLabel.text = "STATUS INFO: accuracy:\(viewModel.debugAccuracy), position speed: \(viewModel.currentSpeed)"
    }

    @objc private func showVehicleProfile() {
        //the tap is on the status label so we get that rect
        //let origin = self.window?.convert(statusLabel.frame.origin, to: nil)
        delegate?.displayVehiclePicker()
    }
}

//MARK: - Animations & Transitions

extension DrivingView {
    func animateDistraction(animateIn: Bool) {
        guard let delegate = self.delegate, delegate.distractionAnimationEnable, !presentationAnimating else { return }
        guard (animateIn && !distractionAnimating) || (!animateIn && distractionAnimating) else { return }
        let distractionHiddenViews = [startStopButton, statusLabel, textViewContainer, speedLimitView]
        let animationDuration: TimeInterval = 0.3
        if animateIn {
            distractionAnimating = true
            distractionLabel.alpha = 0
            distractionLabel.isHidden = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseIn], animations: {
                self.imageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                self.distractionLabel.alpha = 1
                distractionHiddenViews.forEach { $0?.alpha = 0 }
            }, completion: { finished in
                guard finished else { return }
                self.imageView.isHidden = true
            })
        } else {
            distractionAnimating = false
            imageView.isHidden = false
            UIView.animate(withDuration: animationDuration, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
                self.imageView.transform = CGAffineTransform.identity
                self.distractionLabel.alpha = 0
                distractionHiddenViews.forEach { $0?.alpha = 1 }
            }, completion: { finished in
                guard finished else { return }
                self.distractionLabel.isHidden = true
            })
        }
    }

    func hideUIElements(_ hide: Bool, completion: (() -> ())? = nil) {
        guard !distractionAnimating else { return }
        presentationAnimating = true
        // filter out the imageview, because it needs to be handled differently due to the animation
        let animatableViews = subviews.filter {
            $0 != imageView &&
            $0 != closeButton &&
            $0 != speedLimitView &&
            $0 != distractionLabel &&
            $0 != carPickerView &&
            $0 != statusLabel
        }
        if hide {
            animatableViews.forEach { view in
                view.alpha = 0
                view.isHidden = true
            }
            completion?()
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                animatableViews.forEach { view in
                    view.isHidden = false
                    view.alpha = 1
                }
            }) { _ in
                self.presentationAnimating = false
                completion?()
            }
        }
    }

    func prepareForTripResult(completion: @escaping () -> ()) {
        if !UIDevice.current.orientation.isLandscape {
            if imageViewWidhtConstraint == nil {
                imageViewWidhtConstraint = imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width)
                imageViewHeigthConstraint = imageView.heightAnchor.constraint(equalToConstant: imageView.frame.height)
            }
            imageViewWidhtConstraint?.isActive = true
            imageViewHeigthConstraint?.isActive = true
            NSLayoutConstraint.deactivate([imageViewTopContraint, imageViewBottomContraint])
            summaryImageTopConstraint = imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
            summaryImageTopConstraint?.isActive = true
        }
        let keepViews: [UIView] = [imageView]
        let discardViews = subviews.filter { !keepViews.contains($0) }
        UIView.animate(withDuration: 0.4, animations: {
            discardViews.forEach { view in
                view.alpha = 0
            }
            self.layoutIfNeeded()
        }, completion: {
            (_: Bool) in
            self.buttonBottomConstraint = nil
            completion()
        })
    }
}

//MARK: Results view layout

extension DrivingView {
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
}
