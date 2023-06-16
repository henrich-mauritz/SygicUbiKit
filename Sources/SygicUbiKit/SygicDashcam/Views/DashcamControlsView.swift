import Foundation
import UIKit

// MARK: - DashcamControlsViewDelegate

public protocol DashcamControlsViewDelegate: AnyObject {
    var shouldShowCloseUponStopRecording: Bool { get set }
    func dashcamControlRecordingPressed(_ view: DashcamControlsViewProtocol, sender: Any)
    func dashcamControlClosePressed(_ view: DashcamControlsViewProtocol, sender: Any)
    func dashcamControlSoundRecordingPressed(_ view: DashcamControlsViewProtocol, sender: Any)
    func dashcamControlSettingsPressed(_ view: DashcamControlsViewProtocol, settingsDataSource: DashcamSettingsDatasouceType, sender: Any)
}

// MARK: - DashcamControlsViewProtocol

public protocol DashcamControlsViewProtocol: UIView {
    var delegate: DashcamControlsViewDelegate? { get set }
    func setRecordingButton(hidden: Bool)
    func setRecordingUI(recording: Bool)
    func setVideoExportingUI(exporting: Bool)
    func setRecordAudioUI(audioEnabled: Bool)
    func setRecordingVideoDurationUI(videoDuration: Int)
    func toggleOnOffCloseButton(isOn value: Bool)
    func animateStartEndButton(to higherPositon: Bool)
}

// MARK: - DashcamControlsView

open class DashcamControlsView: UIView, DashcamControlsViewProtocol, DashcamDrivingViewModelDelegate {
    public static let topMargin: CGFloat = 20
    public static let sideMargin: CGFloat = 28
    public static let speedLimitSize: CGFloat = 74
    public weak var delegate: DashcamControlsViewDelegate?
    private let provider: DashcamProviderProtocol

    private lazy var drivingDataViewModel: DashcamDrivingViewModel = {
        let viewModel = DashcamDrivingViewModel(provider: provider)
        viewModel.delegate = self
        return viewModel
    }()

    public lazy var overlayView: DashcamOverlayView = {
        let view = DashcamOverlayView(viewModel: drivingDataViewModel)
        view.recordButton.addTarget(self, action: #selector(recordPressed(_:)), for: .touchUpInside)
        view.stopRoundedRecording.addTarget(self, action: #selector(recordPressed(_:)), for: .touchUpInside)
        return view
    }()

    public let recIndicatorView = DashcamRecordingIndicatorView()

    public lazy var closeButton: DashcamActionButton = {
        let button = DashcamActionButton(image: UIImage(named: "icn-dashcam-cancel", in: .module, compatibleWith: nil))
        button.addTarget(self, action: #selector(closePressed(_:)), for: .touchUpInside)
        return button
    }()

    public lazy var settingsButton: DashcamActionButton = {
        let button = DashcamActionButton(image: UIImage(named: "icn-dashcam-settings", in: .module, compatibleWith: nil))
        button.addTarget(self, action: #selector(settingsPressed(_:)), for: .touchUpInside)
        return button
    }()

    public lazy var soundButton: DashcamActionButton = {
        let button = DashcamActionButton()
        button.addTarget(self, action: #selector(recordSoundPressed(_:)), for: .touchUpInside)
        return button
    }()

    public let topBackgroundGradient: GradientDrawView = {
        let gradient = GradientDrawView()
        gradient.colors = [UIColor.backgroundOverlay.withAlphaComponent(0.7), UIColor.backgroundOverlay.withAlphaComponent(0)]
        return gradient
    }()

    public let bottomBackgroundGradient: GradientDrawView = {
        let gradient = GradientDrawView()
        gradient.colors = [UIColor.backgroundOverlay.withAlphaComponent(0), UIColor.backgroundOverlay.withAlphaComponent(0.7)]
        return gradient
    }()

    private var soundRecordingAvailable: Bool {
        return true
    }

    private lazy var settingsButtonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = buttonMargin
        stack.addArrangedSubview(settingsButton)
        if soundRecordingAvailable {
            stack.addArrangedSubview(soundButton)
        }
        return stack
    }()

    private lazy var speedLimitView: SpeedLimitView = {
        let view = SpeedLimitView()
        view.strokeWidth = 8
        view.speedLabel.font = UIFont.stylingFont(.bold, with: 26)
        view.heightAnchor.constraint(equalToConstant: Self.speedLimitSize).isActive = true
        view.widthAnchor.constraint(equalToConstant: Self.speedLimitSize).isActive = true
        return view
    }()

    private lazy var speedStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.addArrangedSubview(speedLabel)
        stack.addArrangedSubview(speedUnitsStackView)
        return stack
    }()

    private lazy var speedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundTertiary
        label.font = UIFont.stylingFont(.bold, with: 80)
        label.textAlignment = .center
        return label
    }()

    private lazy var speedUnitsStackView: UIStackView = {
        let stackView = UIStackView()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.layoutMargins = UIEdgeInsets(top: -8, left: 0, bottom: 0, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.addArrangedSubview(speedUnitsLabel)
        stack.addArrangedSubview(UIView())
        return stack
    }()

    private lazy var speedUnitsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundTertiary
        label.font = UIFont.stylingFont(.regular, with: 20)
        label.textAlignment = .center
        return label
    }()

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDetected(_:)))
        gesture.delegate = self
        return gesture
    }()

    private var closeButtonHeightConstraint: NSLayoutConstraint?
    private var soundButtonHeightConstraint: NSLayoutConstraint?
    private var settingsButtonHeightConstraint: NSLayoutConstraint?
    private var speedStackCenterXConstraint: NSLayoutConstraint?
    private var speedStackTrialingConstriant: NSLayoutConstraint?
    private var speedStackCenterYConstraint: NSLayoutConstraint?
    private var speedStackTopConstraint: NSLayoutConstraint?
    public var overlayBottomConstraint: NSLayoutConstraint?

    private var topMargin: CGFloat { Self.topMargin }
    private var sideMargin: CGFloat { Self.sideMargin }
    private let buttonMargin: CGFloat = 20
    private let buttonHeight: CGFloat = 56
    private let buttonHeightLandscape: CGFloat = 40
    private let buttonIconSize: CFloat = 24
    private let gradientHeight: CGFloat = 280

    public required init(provider: DashcamProviderProtocol) {
        self.provider = provider
        super.init(frame: .zero)
        addGestureRecognizer(tapGesture)
        setupLayout()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setRecordingButton(hidden: Bool) {
        overlayView.stopRoundedRecording.isHidden = hidden
        overlayView.recordButton.isHidden = hidden
    }

    public func setRecordingUI(recording: Bool) {
        recIndicatorView.isHidden = !recording
        speedLimitView.isHidden = !recording || drivingDataViewModel.speedLimit == nil
        settingsButton.isHidden = recording
        if !recording {
            if let delegate = delegate {
                if !delegate.shouldShowCloseUponStopRecording && !self.provider.inTrip {
                    closeButton.isHidden = false
                } else if self.provider.inTrip {
                    closeButton.isHidden = false
                } else {
                    closeButton.isHidden = recording
                }
            } else {
                closeButton.isHidden = recording
            }
        } else {
            closeButton.isHidden = recording
        }
        overlayView.updateDrivingOverlayInfo(with: drivingDataViewModel)
        overlayView.state = recording ? .recording : .info
        settingsButtonStack.isHidden = recording
        speedStack.isHidden = !recording
        
        activateLayout()
    }

    public func setVideoExportingUI(exporting: Bool) {
        overlayView.state = exporting ? .saving : .info
    }

    public func setRecordAudioUI(audioEnabled: Bool) {
        soundButton.buttonImageView.image = audioEnabled ? UIImage(named: "icn-dashcam-mic-small", in: .module, compatibleWith: nil) : UIImage(named: "icn-dashcam-micMute", in: .module, compatibleWith: nil)
    }

    public func setRecordingVideoDurationUI(videoDuration: Int) {
        overlayView.updateDurationLabel(with: videoDuration)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        activateLayout()
    }

    private func setupLayout() {
        recIndicatorView.isHidden = true
        addAutoLayoutSubviews(topBackgroundGradient,
                              bottomBackgroundGradient,
                              overlayView,
                              recIndicatorView,
                              speedStack,
                              speedLimitView,
                              closeButton,
                              settingsButtonStack)
        var constraints = [NSLayoutConstraint]()
        constraints.append(closeButton.trailingAnchor.constraint(equalTo: safeAreaTrailingAnchor, constant: -sideMargin))
        constraints.append(closeButton.topAnchor.constraint(equalTo: safeAreaTopAnchor, constant: topMargin))
        closeButtonHeightConstraint = closeButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        constraints.append(closeButtonHeightConstraint!)
        constraints.append(closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor))

        settingsButtonHeightConstraint = settingsButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        constraints.append(settingsButtonHeightConstraint!)
        constraints.append(settingsButton.widthAnchor.constraint(equalTo: settingsButton.heightAnchor))
        if soundRecordingAvailable {
            soundButtonHeightConstraint = soundButton.heightAnchor.constraint(equalToConstant: buttonHeight)
            constraints.append(soundButtonHeightConstraint!)
            constraints.append(soundButton.widthAnchor.constraint(equalTo: soundButton.heightAnchor))
        }
        constraints.append(settingsButtonStack.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: buttonMargin))
        constraints.append(settingsButtonStack.trailingAnchor.constraint(equalTo: safeAreaTrailingAnchor, constant: -sideMargin))

        constraints.append(overlayView.leadingAnchor.constraint(equalTo: safeAreaLeadingAnchor, constant: sideMargin))
        constraints.append(overlayView.trailingAnchor.constraint(equalTo: safeAreaTrailingAnchor, constant: -sideMargin))
        overlayBottomConstraint = overlayView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -52)
        constraints.append(overlayBottomConstraint!)
        constraints.append(topBackgroundGradient.topAnchor.constraint(equalTo: topAnchor))
        constraints.append(topBackgroundGradient.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(topBackgroundGradient.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(topBackgroundGradient.bottomAnchor.constraint(equalTo: safeAreaTopAnchor, constant: gradientHeight))
        constraints.append(bottomBackgroundGradient.bottomAnchor.constraint(equalTo: bottomAnchor))
        constraints.append(bottomBackgroundGradient.leadingAnchor.constraint(equalTo: leadingAnchor))
        constraints.append(bottomBackgroundGradient.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(bottomBackgroundGradient.topAnchor.constraint(equalTo: safeAreaBottomAnchor, constant: -gradientHeight))
        constraints.append(recIndicatorView.leadingAnchor.constraint(equalTo: safeAreaLeadingAnchor, constant: sideMargin))
        constraints.append(recIndicatorView.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor))
        speedStackCenterXConstraint = speedStack.centerXAnchor.constraint(equalTo: centerXAnchor)
        speedStackTrialingConstriant = speedStack.trailingAnchor.constraint(equalTo: speedLimitView.leadingAnchor, constant: -16)
        speedStackCenterYConstraint = speedStack.centerYAnchor.constraint(equalTo: speedLimitView.centerYAnchor)
        speedStackTopConstraint = speedStack.topAnchor.constraint(equalTo: closeButton.centerYAnchor, constant: 16)
        constraints.append(speedStackCenterXConstraint!)
        constraints.append(speedStackTopConstraint!)
        constraints.append(speedLimitView.trailingAnchor.constraint(equalTo: safeAreaTrailingAnchor, constant: -sideMargin))
        constraints.append(speedLimitView.topAnchor.constraint(equalTo: safeAreaTopAnchor, constant: topMargin))
        NSLayoutConstraint.activate(constraints)
        //Ghost view to fix some scrolling whne contained inside a pageview contorller or scroll view
        //The bug appears only when user tries to swupe on the middle poriton of the view, where there are no subviews.
        //so clearly some configuration on this view itself is preventing the swipes.
        //TODO: Investigate thea above behaviour and remove the ghost view if necesary
        let ghostView = UIView()
        ghostView.backgroundColor = .clear
        ghostView.translatesAutoresizingMaskIntoConstraints = false
        cover(with: ghostView)
        sendSubviewToBack(ghostView)
        activateLayout() //called again in case the view initialize in landscapemode directly, hence traitCollectionDidChagne wont get called first time
    }

    private func activateLayout() {
        if UIWindow.isLandscape {
            closeButtonHeightConstraint?.constant = buttonHeightLandscape
            soundButtonHeightConstraint?.constant = buttonHeightLandscape
            settingsButtonHeightConstraint?.constant = buttonHeightLandscape
//            settingsButtonStack.spacing = 8
            speedStackCenterXConstraint?.isActive = false
            speedStackTrialingConstriant?.isActive = true
            speedStackTopConstraint?.isActive = false
            speedStackCenterYConstraint?.isActive = true
            speedStack.spacing = 5
            speedUnitsLabel.textAlignment = .right
            overlayBottomConstraint?.constant = -16

        } else/* if UIApplication.shared.statusBarOrientation.isPortrait*/ {
            closeButtonHeightConstraint?.constant = buttonHeight
            soundButtonHeightConstraint?.constant = buttonHeight
            settingsButtonHeightConstraint?.constant = buttonHeight
//            settingsButtonStack.spacing = buttonMargin
            speedStackCenterXConstraint?.isActive = true
            speedStackTrialingConstriant?.isActive = false
            speedStackTopConstraint?.isActive = true
            speedStackCenterYConstraint?.isActive = false
            speedStack.spacing = 0
            speedUnitsLabel.textAlignment = .center
            if overlayView.state == .recording {
                overlayBottomConstraint?.constant = 0
            }
            else {
                overlayBottomConstraint?.constant = -52
            }
        }
        topBackgroundGradient.isHidden = UIDevice.current.orientation.isLandscape
        bottomBackgroundGradient.isHidden = UIDevice.current.orientation.isLandscape
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }

    /// Animation of the start stop button ONLY if its on portrait mode
    /// - Parameter higherPositon: to higher pos or lower
    public func animateStartEndButton(to higherPositon: Bool) {
        if UIWindow.isPortrait {
            overlayBottomConstraint?.constant = higherPositon == true ? -52 : -8
            UIView.animate(withDuration: 0.35,
                           delay: 0.0,
                           options: [.curveEaseOut, .beginFromCurrentState],
                           animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }

    @objc func recordPressed(_ sender: UIButton) {
        delegate?.dashcamControlRecordingPressed(self, sender: sender)
    }

    @objc func recordSoundPressed(_ sender: UIButton) {
        delegate?.dashcamControlSoundRecordingPressed(self, sender: sender)
    }

    @objc func closePressed(_ sender: UIButton) {
        delegate?.dashcamControlClosePressed(self, sender: sender)
    }

    @objc open func settingsPressed(_ sender: UIButton) {
        delegate?.dashcamControlSettingsPressed(self, settingsDataSource: DashcamSettingsDataSource(), sender: sender)
    }

    @objc func tapGestureDetected(_: UIGestureRecognizer) {
        overlayView.animateRecordButtonGrow()
    }

    public func toggleOnOffCloseButton(isOn value: Bool) {
        closeButton.isHidden = value
    }

    open func dashcamViewModel(_ viewModel: DashcamDrivingViewModel, didUpdateData _: DashcamDataProtocol) {
         overlayView.updateDrivingOverlayInfo(with: viewModel)
         speedLabel.text = viewModel.speed
         speedLabel.textColor = viewModel.speedingColor
         speedUnitsLabel.text = viewModel.speedUnits
         speedLimitView.speedLabel.text = viewModel.speedLimit
         speedLimitView.isHidden = viewModel.speedLimit == nil
     }
}

// MARK: UIGestureRecognizerDelegate

extension DashcamControlsView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isControlTapped = touch.view is UIControl
        return !isControlTapped
    }

    override public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        // can't use device orientation for this. Device could be physically rotated, but interface is not
        let orientation = UIApplication.shared.windowInterfaceOrientation?.isLandscape == true
        return overlayView.state == .recording && orientation
    }
}
