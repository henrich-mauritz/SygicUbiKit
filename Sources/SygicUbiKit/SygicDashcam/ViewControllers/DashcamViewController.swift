import AVFoundation
import UIKit

// MARK: - DashcamViewController

open class DashcamViewController: UIViewController, InjectableType, DashcamControlsViewDelegate {
    public let session: DashcamSession
    private let viewModel: DashcamViewModel
    open lazy var controlsView: DashcamControlsViewProtocol = {
        createControlView()
    }()

    private let autostartEnabled = UserDefaults.dashcamOneTap

    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var recBottomConstraint = NSLayoutConstraint()
    private var wasRecordingBeforeShowingSettings = false
    private var recordingOrientationMask: UIInterfaceOrientationMask = .all
    public var shouldShowCloseUponStopRecording: Bool = true //set from outside to configure behaviour
    private var onScreen: Bool = false
    public init(session: DashcamSession) {
        self.session = session
        let viewModel = DashcamViewModel(session: session)
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        UserDefaults.standard.register(defaults: [
            UserDefaults.Keys.dashcamShouldShowOverlay: false,
            UserDefaults.Keys.dashcamVideoQuality: VideoQuality.SD.rawValue,
            UserDefaults.Keys.dashcamVideoDuration: VideoDuration.min1.rawValue,
        ])

        isModalInPresentation = true
        wasRecordingBeforeShowingSettings = autostartEnabled
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard session.recording else { return .all }
        return recordingOrientationMask
    }
    
    override open var shouldAutorotate: Bool {
        return true
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        UserDefaults.setDashcamOnboardingComplete()
        controlsView.delegate = self
        controlsView.setRecordingUI(recording: session.recording)
        controlsView.setRecordAudioUI(audioEnabled: session.recordAudio)
        controlsView.setRecordingVideoDurationUI(videoDuration: UserDefaults.dashcamVideoDuration)
        view.cover(with: controlsView, toSafeArea: false)

        viewModel.isExportingClosure = { [weak self] exporting in
            DispatchQueue.main.async {
                self?.controlsView.setVideoExportingUI(exporting: exporting)
            }
        }
        viewModel.isRecordingClosure = { [weak self] recording in
            guard let self = self else {return}
            if !recording {
                if #available(iOS 16.0, *) {
                    self.setNeedsUpdateOfSupportedInterfaceOrientations()
                } else {
                    // Fallback on earlier versions is non existent. No idea what to do.
                }
            }
            DispatchQueue.main.async {
                if self.session.recording {
                    self.recordingOrientationMask = self.session.recordingOrientation.interfaceOrientationMask
                }
                self.controlsView.setRecordingUI(recording: recording)
            }
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //this we dont want, close should be visible always
//      controlsView.toggleOnOffCloseButton(isOn: viewModel.inTrip)
        onScreen = true
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.loadCameraPreviewLayer { [weak self] layer in
            guard let layer = layer else { return }
            DispatchQueue.main.async {
                self?.previewLayer = layer
                guard let viewLayer = self?.view else { return }
                layer.frame = viewLayer.layer.bounds
                layer.videoGravity = .resizeAspectFill
                viewLayer.layer.insertSublayer(layer, at: 0)
            }
        }
        session.provider.dashcamDidAppear()
        if autostartEnabled, !session.recording, wasRecordingBeforeShowingSettings {
            session.startRecording()
        }
        controlsView.setRecordAudioUI(audioEnabled: session.recordAudio)
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.dashcamShown, parameters: nil)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.pauseCameraPreviewLayer()
        onScreen = false
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let previewLayer = previewLayer {
            previewLayer.frame = view.layer.bounds
            if previewLayer.connection?.isVideoOrientationSupported ?? false {
                previewLayer.connection?.videoOrientation = DashcamHelpers.currentOrientationForAVCapture()
            }
        }
    }

    private func showSettingsAlert(forSound: Bool) {
        let modalVC = DashcamPermissionsModalViewController(soundPermisson: forSound)
        PopupManager.shared.presentModalPopup(modalVC, on: self)
    }

    open func createControlView() -> DashcamControlsViewProtocol {
        DashcamControlsView(provider: session.provider)
    }

    public func animateStartStopButton(to higherPosition: Bool) {
        if onScreen {
            controlsView.animateStartEndButton(to: higherPosition)
        }
    }
    
    open func didSelectSettings() {}
    
    open func didDismissSettings() {}
    
}

// MARK: DashcamControlsViewDelegate

public extension DashcamViewController {
    func dashcamControlRecordingPressed(_: DashcamControlsViewProtocol, sender _: Any) {
        if DashcamPermissionsModalViewController.shouldShowPermissionsPopup {
            showSettingsAlert(forSound: false)
            return
        }
        viewModel.toggleRecording()
    }

    func dashcamControlSoundRecordingPressed(_: DashcamControlsViewProtocol, sender _: Any) {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] access in
                UserDefaults.setDashcamSoundEnabled(access)
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.controlsView.setRecordAudioUI(audioEnabled: self.session.recordAudio)
                }
            }
            return
        case .authorized:
            UserDefaults.setDashcamSoundEnabled(!session.recordAudio)
        default:
            UserDefaults.setDashcamSoundEnabled(false)
            showSettingsAlert(forSound: true)
        }
        controlsView.setRecordAudioUI(audioEnabled: session.recordAudio)
        if session.recordAudio {
            session.provider.showToast(message: "dashcam.toast.soundOn".localized, icon: nil, error: nil)
        } else {
            session.provider.showToast(message: "dashcam.toast.soundOff".localized, icon: nil, error: nil)
        }
    }

    func dashcamControlClosePressed(_: DashcamControlsViewProtocol, sender _: Any) {
        try? AVAudioSession.sharedInstance().setActive(false)
        session.provider.dashcamWillDisappear()
        dismiss(animated: true)
    }

    func dashcamControlSettingsPressed(_: DashcamControlsViewProtocol, settingsDataSource: DashcamSettingsDatasouceType, sender _: Any) {
        didSelectSettings()
        let settings = DashcamSettingsViewController(settingsDataSource)
        let navigationWrapper = UINavigationController(rootViewController: settings)
        settings.addNavigationBarItems()
        navigationWrapper.setupStyling()
        present(navigationWrapper, animated: true)
        settings.willDismiss = { [weak self] in
            guard let self = self else { return }
            self.didDismissSettings()
            self.controlsView.setRecordAudioUI(audioEnabled: self.session.recordAudio)
            self.controlsView.setRecordingVideoDurationUI(videoDuration: UserDefaults.dashcamVideoDuration)
        }
        wasRecordingBeforeShowingSettings = session.recording
    }
}
