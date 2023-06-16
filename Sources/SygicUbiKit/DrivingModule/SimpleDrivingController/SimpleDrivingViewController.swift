import UIKit

public protocol SimpleDrivingViewControllerDelegate: AnyObject {
    func didChangeVehicleProfile()
}

// MARK: - SimpleDrivingViewController

public class SimpleDrivingViewController: UIViewController, InjectableType, SimpleDrivingViewDelegate {
    public weak var delegate: SimpleDrivingViewControllerDelegate?
    var resultViewController: DrivingResultViewController?
    var distractionAnimationEnable: Bool = true
    private var currentShownIntensity: Int = 0
    private var preparingResultView: Bool = false

    public var speedingSoundsEnabled: Bool = false

    public var presentingResults: Bool {
        return simpleView.presentingSummary
    }

    private var simpleView: SimpleDrivingView {
        guard let v = self.view as? SimpleDrivingView else {
            fatalError("The SimpleView wasn't initialized properly")
        }
        return v
    }

    public var viewModel: DrivingViewModel? {
        didSet {
            viewModel?.delegate = self
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else { return }
        viewModelUpdated(viewModel)
        // Do any additional setup after loading the view.
    }

    override public func loadView() {
        viewModel = DrivingViewModel(addToMultiCastDelegate: false)
        viewModel?.delegate = self
        let sv = SimpleDrivingView(viewDelegate: self, viewModel: viewModel)
        view = sv
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else {
            return
        }
        simpleView.setNeedsLayout()
        simpleView.layoutIfNeeded()
        DrivingManager.shared.add(delegate: viewModel)
        simpleView.updateStartStopButton(viewModel)
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let viewModel = viewModel else {
            return
        }
        DrivingManager.shared.remove(delegate: viewModel)
    }
    
    //MARK: - SimpleDrivingViewDelegate

    func displayVehiclePicker() {
        let chooserController = VehicleProfileCarSelectorViewController(with: .active)
        chooserController.delegate = self
//        var presentingController = self.parent != nil ? self.parent! : self
        chooserController.presentFrom(on: self, with: DrivingManager.shared.configuration?.drivingVehicleProfileListTitle ?? "")
    }
}

extension SimpleDrivingViewController {
    func closeButtonTap(_ sender: UITapGestureRecognizer) {
        //wtf?
        //guard viewModel == nil || !viewModel!.driving else { return }
        viewModel = nil
        dismiss(animated: true, completion: nil)
    }

    private func showTripResultViewControllerAnimated() {
        initResultView()
        simpleView.prepareForTripResult {
            self.addResultViewController()
            self.simpleView.presentingSummary = true
        }
    }

    private func addResultViewController() {
        guard let resultViewController = resultViewController else { return }
        resultViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(resultViewController)
        view.addSubview(resultViewController.view)
        resultViewController.didMove(toParent: self)
        simpleView.prepareContraints(for: resultViewController)
        preparingResultView = false
        guard let sumarizingConformance = self as? DrivingViewControllerSumarizing else { return }
        sumarizingConformance.willPresentSummaryScreen()
    }

    private func initResultView() {
        guard let viewModel = viewModel?.getResultViewModel() else { return }
        resultViewController = DrivingResultViewController(viewModel: viewModel)
        preparingResultView = true
    }
}

// MARK: DrivingViewModelDelegate

extension SimpleDrivingViewController: DrivingViewModelDelegate {
    public func viewModel(_ viewModel: DrivingViewModel, tripIsRunning: Bool) {
        simpleView.isTripRuning = tripIsRunning
        if !tripIsRunning {
            showTripResultViewControllerAnimated()
        }
    }

    public func viewModelUpdated(_ viewModel: DrivingViewModel) {
        let oldSpeedingIntensity = currentShownIntensity
        currentShownIntensity = viewModel.speedingIntensity
        simpleView.viewModelUpdated(viewModel)
        if speedingSoundsEnabled && viewModel.speedingIntensity == 2 && oldSpeedingIntensity < viewModel.speedingIntensity {
            //playSpeedingSound()
        }
    }
}

// MARK: VehicleProfileCarSelectionDelegate

extension SimpleDrivingViewController: VehicleProfileCarSelectionDelegate {
    public func vehicleProfileSelectorDidChangeSelectedVehicle(_ vehicle: VehicleProfileType) {
        guard let viewModel = self.viewModel else { return }
        viewModelUpdated(viewModel)
        if let sumarizingConformance = self as? DrivingViewControllerSumarizing {
            sumarizingConformance.updateControlIcon()
            sumarizingConformance.updateModel()
        }
        self.delegate?.didChangeVehicleProfile()
    }

    public func vehicleProfileSelectorIsOffSeason(for vehicle: VehicleProfileType) -> Bool {
        guard let viewModel = self.viewModel, vehicle.vehicleType == .motorcycle else { return true }
        return !viewModel.isInOffSeasson(for: vehicle.vehicleType)
    }
}
