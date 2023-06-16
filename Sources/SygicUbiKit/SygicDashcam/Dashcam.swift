import UIKit

// MARK: - DashcamCloseButtonBehaviour

public enum DashcamCloseButtonBehaviour {
    case showUponStopRecording
    case hideUponStopRecording
}

// MARK: - Dashcam

open class Dashcam: UIViewController {
    public var dismiss: ((_ recording: Bool) -> Void)?
    public let session: DashcamSession
    private var onboarding: UIViewController?
    private var showAlert: VoidBlock?
    private var _closeButtonBehaviour: Bool = true
    public lazy var currentDashcamController: DashcamViewController = {
        createDashcamController()
    }()

    public init(session: DashcamSession,
                isDarkTheme: Bool) {
        self.session = session
        DashcamColorManager.shared.setTheme(dark: isDarkTheme)
        DashcamModule.injectDefaults()
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        modalPresentationStyle = .fullScreen
        modalPresentationCapturesStatusBarAppearance = true
        handleStart()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override public var prefersStatusBarHidden: Bool {
        true
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        children.first?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    open func createDashcamController() -> DashcamViewController {
        return DashcamViewController(session: self.session)
    }

    open func resolvedOnboarding() -> DashcamOnboardingSortable {
        guard let orderSteps = container.resolve(DashcamOnboardingSortable.self) else {
            fatalError("The default sortable weren't injected yet")
        }
        return orderSteps
    }
}

// MARK: DashcamOnboardingDelegate

extension Dashcam: DashcamOnboardingDelegate {
    public func automaticTripDetectionEnabled() -> Bool {
        session.provider.automaticTripTracking
    }

    public func dashcamOnboardingCompleted() {
        startDashcam()
    }

    public func dashcamOpensAppSettings() {
        session.provider.showApplicationSettings()
    }
}

// MARK: - Private

extension Dashcam: InjectableType {
    private func handleStart() {
        if UserDefaults.dashcamOnboardingComplete {
            startDashcam()
        } else {
            startOnboarding()
        }
    }

    private func startDashcam() {
        onboarding?.remove()
        currentDashcamController.shouldShowCloseUponStopRecording = _closeButtonBehaviour
        add(currentDashcamController)
        currentDashcamController.didMove(toParent: self)
    }

    private func startOnboarding() {
        let resolvedSteps = resolvedOnboarding()
        guard let firstOrder = resolvedSteps.orderedSteps.first else {
            fatalError("The default sortable weren't injected yet")
        }
        let onboardingVC = resolvedSteps.controllerFor(step: firstOrder)
        onboardingVC.delegate = self
        onboarding = UINavigationController(rootViewController: onboardingVC)
        add(onboarding)
        onboarding?.didMove(toParent: self)
    }

    private func close() {
        dismiss(animated: true)
        dismiss?(session.recording)
    }

    public func configureCloseToggleButtonBehaviour(with value: Bool) {
        currentDashcamController.shouldShowCloseUponStopRecording = value
    }
    
}
