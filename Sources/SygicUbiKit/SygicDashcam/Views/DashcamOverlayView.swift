import UIKit

// MARK: - DashcamOverlayView

public final class DashcamOverlayView: UIView {
    enum State {
        case recording, saving, info
    }

    var state: State = .info {
        didSet {
            guard state != oldValue else { return }
            contentStackView.removeAll()
            updateInfoContentSize()
            recordButton.isEnabled = state != .saving
            if state == .info {
                recordButton.titleLabel.text = "dashcam.starRecordingButton".localized.uppercased()
                recordButton.backgroundColor = .buttonBackgroundPrimary
                recordButton.titleColor = .buttonForegroundPrimary
                contentStackView.addArrangedSubview(recordingInfoView)
            } else {
                recordButton.titleLabel.text = "dashcam.stopRecordingButton".localized.uppercased()
                recordButton.backgroundColor = .buttonBackgroundTertiaryActive
                recordButton.titleColor = .buttonForegroundTertiaryActive
                if state == .saving {
                    contentStackView.addArrangedSubview(activityIndicator)
                    activityIndicator.startAnimating()
                    self.shrinkAnimatorTimer?.invalidate()
                    self.shrinkAnimatorTimer = nil
                }
            }
            distanceLabel.isHidden = !viewModel.hasDataToPresent || state != .recording
            updateDrivingOverlayInfo(with: viewModel)
        }
    }

    lazy var recordButton: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.normal)
        button.titleLabel.text = "dashcam.starRecordingButton".localized.uppercased()
        button.titleLabel.font = UIFont.stylingFont(.bold, with: 20)
        button.layer.cornerRadius = Styling.driveSliderButtonCorenerRadius
        button.height = 60
        button.addTarget(self, action: #selector(prepareForRecordAnimation), for: .touchUpInside)
        return button
    }()

    lazy var stopRoundedRecording: StylingButton = {
        let button = StylingButton.button(with: StylingButton.ButtonStyle.circular)
        button.backgroundColor = .buttonBackgroundTertiaryActive
        button.iconView.image = UIImage(named: "dashcamStopShape", in: .module, compatibleWith: nil)
        button.iconView.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.height = roundedButtonWidth
        button.layoutIfNeeded()
        button.alpha = 0
        button.addTarget(self, action: #selector(stopRecordingSquarePressed), for: .touchUpInside)
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.contentMode = .center
        stack.alignment = .center
        stack.addArrangedSubview(recordingInfoView)
        return stack
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.tintColor = .buttonForegroundPrimary
        return activityIndicator
    }()

    private var viewModel: DashcamDrivingViewModel

    private lazy var recordingInfoView: UIView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.addArrangedSubview(durationLabel)
        stack.addArrangedSubview(settingsLabel)
        return stack
    }()
    
    private let settingsLabel: UILabel = {
        let settingsLabel = UILabel()
        settingsLabel.font = UIFont.stylingFont(.regular, with: 16)
        settingsLabel.textColor = .foregroundDriving
        settingsLabel.textAlignment = .center
        settingsLabel.text = "dashcam.durationSetupInfo".localized
        return settingsLabel
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.stylingFont(.bold, with: 16)
        label.textColor = .foregroundDriving
        label.textAlignment = .center
        return label
    }()

    public lazy var distanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .foregroundTertiary
        label.font = UIFont.stylingFont(.bold, with: 30)
        label.text = "0 km"
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let roundedButtonWidth: CGFloat = 60
    private let sideMargin: CGFloat = 16
    private let contentSpace: CGFloat = 106
    private let recordButtonWidth: CGFloat = 250
    private var animating: Bool = false
    private var shrinkAnimatorTimer: Timer?

    //Constraints
    private var contentSpaceConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var topStackViewConstraint: NSLayoutConstraint?
    private var bottomStackViewConstraint: NSLayoutConstraint?
    private var leadingStackViewConstraint: NSLayoutConstraint?
    private var centerXStackViewConstraint: NSLayoutConstraint?
    private var centerYStackViewRecordButtom: NSLayoutConstraint?
    private var centerXRecordButtonConstraint: NSLayoutConstraint?
    private var trailingRecordButtonConstraint: NSLayoutConstraint?
    private var recordButtonWithConstraint: NSLayoutConstraint?
    private var centerXDistanceConstriant: NSLayoutConstraint?
    private var trailingDistnaceConstraint: NSLayoutConstraint?

    init(viewModel: DashcamDrivingViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupUI()
        updateDrivingOverlayInfo(with: self.viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if UIWindow.isLandscape {
            durationLabel.textAlignment = .left
            settingsLabel.textAlignment = .left
        }
        else {
            durationLabel.textAlignment = .center
            settingsLabel.textAlignment = .center
        }
    }
}

//MARK: - Value Update

extension DashcamOverlayView {
    func updateDrivingOverlayInfo(with viewModel: DashcamDrivingViewModel) {
        self.viewModel = viewModel
        guard state == .recording else { return }
        updateInfoContentSize()
        if !viewModel.hasDataToPresent {
            distanceLabel.isHidden = true
            return
        } else {
            distanceLabel.text = viewModel.distanceWithUnits
            distanceLabel.isHidden = viewModel.distanceWithUnits == nil
        }
    }

    func updateDurationLabel(with duration: Int) {
        durationLabel.text = String(format: "dashcam.durationInfo".localized.uppercased(), "\(duration)")
    }
}

//MARK: - Animation

extension DashcamOverlayView {
    @objc private func prepareForRecordAnimation() {
        animating = true
        self.shrinkAnimatorTimer = Timer.scheduledTimer(withTimeInterval: 2,
                                                        repeats: false, block: { [weak self] _ in
            guard let self = self else { return }
            self.shrinkAnimatorTimer?.invalidate()
            self.shrinkAnimatorTimer = nil
            self.animateShrink()
        })
    }

    @objc private func stopRecordingSquarePressed() {
        stopRoundedRecording.isUserInteractionEnabled = false
        self.recordButtonWithConstraint?.constant = recordButtonWidth
        if !UIDevice.current.orientation.isLandscape {
            self.centerXRecordButtonConstraint?.constant = 0
        }
        self.recordButton.alpha = 1
        self.stopRoundedRecording.alpha = 0.0
        self.recordButton.titleColor = state == .recording ? .buttonForegroundTertiaryActive : .buttonForegroundPrimary
        UIView.animate(withDuration: 0.4,
                       animations: {
            self.layoutIfNeeded()
            self.recordButton.backgroundColor = self.state == .recording ? .buttonBackgroundTertiaryActive : .actionPrimary
            self.recordButton.layer.cornerRadius = Styling.driveSliderButtonCorenerRadius
        }, completion: {_ in
            UIView.animate(withDuration: 0.2) {
                self.recordButton.titleLabel.alpha = 1
                self.stopRoundedRecording.isUserInteractionEnabled = true
            }
        })
    }

    private func animateShrink() {
        guard self.state == .recording && UIDevice.current.orientation.isLandscape else { return }
        self.recordButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1) {
            self.recordButton.titleLabel.alpha = 0
        }
        
        self.recordButtonWithConstraint?.constant = self.roundedButtonWidth
        if !UIDevice.current.orientation.isLandscape {
            self.centerXRecordButtonConstraint?.constant = self.stopRoundedRecording.center.x - self.frame.size.width / 2
        }
        
        UIView.animate(withDuration: 0.4,
                       animations: {
            self.layoutIfNeeded()
            self.recordButton.backgroundColor = .buttonBackgroundTertiaryActive
            self.recordButton.layer.cornerRadius = self.roundedButtonWidth / 2
        }, completion: {_ in
            
            UIView.animate(withDuration: 0.2) {
                self.recordButton.alpha = 0
                self.stopRoundedRecording.alpha = 1.0
                self.recordButton.isUserInteractionEnabled = true
            } completion: { _ in
                self.animating = false
            }
        })
    }

    func animateRecordButtonGrow() {
        if !animating {
            stopRecordingSquarePressed()
            prepareForRecordAnimation()
        }
    }
}

//MARK: - Layout

public extension DashcamOverlayView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard state != .recording else {
            return
        }
        super.traitCollectionDidChange(previousTraitCollection)
        activateLayout()
    }

    private func activateLayout() {
        let isLandscape = UIWindow.isLandscape
        centerYStackViewRecordButtom?.isActive = isLandscape
        centerXStackViewConstraint?.isActive = !isLandscape
        topStackViewConstraint?.isActive = !isLandscape
        leadingStackViewConstraint?.isActive = isLandscape
        bottomStackViewConstraint?.isActive = !isLandscape
        centerXRecordButtonConstraint?.isActive = !isLandscape
        trailingRecordButtonConstraint?.isActive = isLandscape
        centerXDistanceConstriant?.isActive = !isLandscape
        trailingDistnaceConstraint?.isActive = isLandscape
    }
}

// MARK: - Private

private extension DashcamOverlayView {
    func updateInfoContentSize() {
        if state == .recording && !viewModel.hasDataToPresent {
            contentSpaceConstraint.constant = sideMargin * 2
        } else {
            contentSpaceConstraint.constant = contentSpace
        }
    }

    func setupUI() {
        backgroundColor = .clear
        addAutoLayoutSubviews(recordButton, contentStackView, stopRoundedRecording, distanceLabel)
        var constraints = [NSLayoutConstraint]()
        centerXRecordButtonConstraint = recordButton.centerXAnchor.constraint(equalTo: centerXAnchor)
        trailingRecordButtonConstraint = recordButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        recordButtonWithConstraint = recordButton.widthAnchor.constraint(equalToConstant: recordButtonWidth)
        centerXDistanceConstriant = distanceLabel.centerXAnchor.constraint(equalTo: recordButton.centerXAnchor)
        trailingDistnaceConstraint = distanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        constraints.append(centerXDistanceConstriant!)
        constraints.append(centerXRecordButtonConstraint!)
        constraints.append(recordButtonWithConstraint!)
        constraints.append(distanceLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -sideMargin))
        constraints.append(distanceLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: sideMargin))
        constraints.append(recordButton.bottomAnchor.constraint(equalTo: safeAreaBottomAnchor, constant: -sideMargin))
        leadingStackViewConstraint = contentStackView.leadingAnchor.constraint(equalTo: safeAreaLeadingAnchor, constant: sideMargin+20)
        topStackViewConstraint = contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: sideMargin)
        bottomStackViewConstraint = contentStackView.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -sideMargin)
        centerYStackViewRecordButtom = contentStackView.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor)
        centerXStackViewConstraint = contentStackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        constraints.append(topStackViewConstraint!)
        constraints.append(centerXStackViewConstraint!)
        constraints.append(bottomStackViewConstraint!)
        constraints.append(stopRoundedRecording.trailingAnchor.constraint(equalTo: trailingAnchor))
        constraints.append(stopRoundedRecording.centerYAnchor.constraint(equalTo: recordButton.centerYAnchor))
        NSLayoutConstraint.activate(constraints)
        activateLayout() //called in case this view starts up in landscape.
    }
}
