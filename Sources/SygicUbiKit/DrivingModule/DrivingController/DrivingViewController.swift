import AVFoundation
import UIKit

// MARK: - DrivingViewControllerSumarizing

public protocol DrivingViewControllerSumarizing {
    func willPresentSummaryScreen()
    func updateControlIcon()
    func updateModel()
}

// MARK: - DrivingViewController

public class DrivingViewController: UIViewController, DrivingControllerViewDelegate {
    public var viewModel: DrivingViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }

//    public var interactionController: SwipeInteractionController!
    public var drivingAnimationsEnabled: Bool = true {
        didSet {
            animations.animationsEnabled = drivingAnimationsEnabled
        }
    }

    /// Use this property if you need to access the controller's view instead
    var drivingView: DrivingView {
        guard let view = self.view as? DrivingView else {
            fatalError("The view wasn't initialized as a DrivingControllerView, this is a mistake")
        }
        return view
    }

    public var speedingSoundsEnabled: Bool = false

    public var distractionAnimationEnable: Bool = true

    public var presentingResults: Bool {
        return drivingView.presentingSummary
    }

    public lazy var buttonBottomConstraint: NSLayoutConstraint? = {
        drivingView.buttonBottomConstraint
    }()

    private lazy var animations: DrivingAnimationsManager = {
        let manager = DrivingAnimationsManager()
        manager.imageView = drivingView.imageView
        manager.defaultAnimations = DrivingAnimations()
        return manager
    }()

    var resultViewController: DrivingResultViewController?
    private var debugTripsView: DebugView?
    private var preparingResultView: Bool = false

    //MARK: - Lifecycle

    public required init(drivingCarAnimations: Bool = true) {
        drivingAnimationsEnabled = drivingCarAnimations
        viewModel = DrivingViewModel()
        super.init(nibName: nil, bundle: nil)
        viewModel?.delegate = self
    }

    override public func loadView() {
        let controllerView = DrivingView(viewDelegate: self, viewModel: viewModel)
        self.view = controllerView
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        print(":::DEINIT DRIVING CONTROLLER:::")
    }

    private lazy var speedingSoundPlayer: AVAudioPlayer? = {
        guard let url = Bundle.module.url(forResource: "pulsar", withExtension: "mp3") else { return nil }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: .duckOthers)
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player.delegate = self
            return player
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else { return }
        viewModelUpdated(viewModel)
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let _ = self.viewModel else {
            return .portrait
        }
        return .allButUpsideDown
    }

    override public var shouldAutorotate: Bool { true }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.drivingScreenShown, parameters: nil)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        drivingView.hideUIElements(false) { [weak self] in
            guard let self = self else { return }
            self.drivingView.setupActivityIndicatorIfNeeded()
            self.checkRequiredPermissions()
        }
        guard let viewModel = viewModel, viewModel.driving else {
            return
        }
        animations.resumeAnimations()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        debugTripsView?.stopTripPlayback()
        super.viewWillDisappear(animated)
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        animations.pauseAnimations()
    }

    private func hideUIElements(_ hide: Bool, completion: (() -> ())? = nil) {
        drivingView.hideUIElements(hide, completion: completion)
    }

    private func checkRequiredPermissions() {
        if DrivingPermissionsPopupViewController.shouldShowPermissionsPopup(automaticTripDetection: false) {
            PopupManager.shared.presentModalPopup(DrivingPermissionsPopupViewController(requireLocationAlwaysPermisson: false), on: self)
        }
    }
    
    private func processTripFromBackground() {
        dismiss(animated: true)
    }

    private func showTripResultViewControllerAnimated() {
        initResultView()
        if let sumarizingConformance = self as? DrivingViewControllerSumarizing {
            sumarizingConformance.willPresentSummaryScreen()
        }
        self.drivingView.presentingSummary = true
        drivingView.prepareForTripResult {
            self.addResultViewController()
        }
    }

    private func addResultViewController() {
        guard let resultViewController = resultViewController else { return }
        resultViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(resultViewController)
        view.addSubview(resultViewController.view)
        resultViewController.didMove(toParent: self)
        drivingView.prepareContraints(for: resultViewController)
        preparingResultView = false
        if let viewModel = viewModel {
            DrivingManager.shared.remove(delegate: viewModel)
        }
    }

    @objc
func closeButtonTap(_ sender: UITapGestureRecognizer) {
        //co to kurwa je?!
        //guard viewModel == nil || !viewModel!.driving else { return }
        viewModel = nil
        dismiss(animated: true, completion: nil)
    }

    private func initResultView() {
        guard let viewModel = viewModel?.getResultViewModel(), resultViewController == nil else { return }
        resultViewController = DrivingResultViewController(viewModel: viewModel)
        preparingResultView = true
    }

    //MARK: - DrivingControllerViewDelegate

    func displayVehiclePicker() {
        let chooserController = VehicleProfileCarSelectorViewController(with: .active)
        chooserController.delegate = self
//        var presentingController = self.parent != nil ? self.parent! : self
        chooserController.presentFrom(on: self, with: DrivingManager.shared.configuration?.drivingVehicleProfileListTitle ?? "")
    }

//    @objc
private func initDebugView(_ sender: UIGestureRecognizer?) {
        guard debugTripsView == nil else { return }
        if let recognizer = sender {
            view.removeGestureRecognizer(recognizer)
        }
        let debugView = DebugView(frame: .zero)
        debugView.shareButton.addTarget(self, action: #selector(shareButtonPressed), for: .touchUpInside)
        debugView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(debugView)
        debugView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        debugView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        debugView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        debugTripsView = debugView
    }

    private func playSpeedingSound() {
        guard speedingSoundsEnabled, let player = speedingSoundPlayer, !player.isPlaying else { return }
        try? AVAudioSession.sharedInstance().setActive(true)
        player.play()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let p = presentedViewController {
            dismiss(animated: false) {
                self.present(p, animated: true, completion: nil)
            }
        }
    }
}

// MARK: DrivingViewModelDelegate

extension DrivingViewController: DrivingViewModelDelegate {
    public func viewModel(_ viewModel: DrivingViewModel, tripIsRunning: Bool) {
        drivingView.isTripRuning = tripIsRunning
        if drivingAnimationsEnabled {
            if tripIsRunning {
                animations.play(nil, for: viewModel.currentVehicle?.vehicleType ?? .car)
            } else {
                animations.stopAnimations(animated: true, for: viewModel.currentVehicle?.vehicleType ?? .car)
            }
        }
        if !tripIsRunning {
            if UIApplication.shared.applicationState == .background {
                processTripFromBackground()
            } else {
                showTripResultViewControllerAnimated()
            }
        }
    }

    public func viewModelUpdated(_ viewModel: DrivingViewModel) {
        let oldSpeedingIntensity = drivingView.currentShownIntensity
        drivingView.viewModelUpdated(viewModel)
        if speedingSoundsEnabled && viewModel.speedingIntensity == 2 && oldSpeedingIntensity < viewModel.speedingIntensity {
            playSpeedingSound()
        }

        if drivingAnimationsEnabled, viewModel.shouldPlayAnimations {
            animations.play(viewModel.eventToPlay, for: viewModel.currentVehicle?.vehicleType ?? .car)
        }
    }
    
}

// MARK: InteractionControllerDelegate

extension DrivingViewController: InteractionControllerDelegate {
    public func shouldDismiss() -> Bool {
        return true // always allowed by https://jira.sygic.com/browse/TRIG-880
//        guard let viewModel = viewModel else { return true }
//        return !viewModel.driving && viewModel.canStartOrStopTrip
    }
}

// MARK: AVAudioPlayerDelegate

extension DrivingViewController: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

// MARK: VehicleProfileCarSelectionDelegate

extension DrivingViewController: VehicleProfileCarSelectionDelegate {
    public func vehicleProfileSelectorShouldChangeSelectedVehicle(_ vehicle: VehicleProfileType) -> Bool {
        guard let view = self.view as? DrivingView else { return true }

        if vehicle.vehicleType == .motorcycle {
            view.imageView.image = UIImage(named: "motorbikeDrivingVehicle", in: .module, compatibleWith: nil)
        } else {
            view.imageView.image = UIImage(named: "car", in: .module, compatibleWith: nil)
        }
        return true
    }

    public func vehicleProfileSelectorDidChangeSelectedVehicle(_ vehicle: VehicleProfileType) {
        guard let viewModel = self.viewModel else { return }
        viewModelUpdated(viewModel)
        if let sumarizingConformance = self as? DrivingViewControllerSumarizing {
            sumarizingConformance.updateControlIcon()
            sumarizingConformance.updateModel()
        }
    }

    public func vehicleProfileSelectorIsOffSeason(for vehicle: VehicleProfileType) -> Bool {
        guard let viewModel = self.viewModel, vehicle.vehicleType == .motorcycle else { return true }
        return !viewModel.isInOffSeasson(for: vehicle.vehicleType)
    }
}

extension DrivingViewController: SimpleDrivingViewControllerDelegate {
    public func didChangeVehicleProfile() {
        guard let view = self.view as? DrivingView,
              let viewModel = self.viewModel,
              let currentVehicle = viewModel.currentVehicle else { return }

        if currentVehicle.vehicleType == .motorcycle {
            view.imageView.image = UIImage(named: "motorbikeDrivingVehicle", in: .module, compatibleWith: nil)
        } else {
            view.imageView.image = UIImage(named: "car", in: .module, compatibleWith: nil)
        }
    }
}
