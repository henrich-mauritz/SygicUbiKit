import Swinject
import UIKit

// MARK: - TriplogOverviewViewController

/// Triplog rootViewController.
/// Should be presented inside UINavigationViewController
public class TriplogOverviewViewController: UIViewController, InjectableType {
    private var viewModel: TriplogOverviewViewModelProtocol?
    private var triplogView: TriplogOverviewViewProtocol?
    private var vehiclePicker: VPVehicleSelectorControl?
    private var presentingStats: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func loadView() {
        additionalSafeAreaInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        triplogView = container.resolve(TriplogOverviewViewProtocol.self)
        triplogView?.monthsDelegate = self
        view = triplogView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if self.viewModel == nil {
            self.viewModel = container.resolve(TriplogOverviewViewModelProtocol.self)
        }
        self.viewModel?.delegate = self
        title = "triplog.overview.title".localized
        guard let viewModel = viewModel else {
            return
        }
        if let viewModel = viewModel as? TriplogArchivePeriodOverViewModel {
            title = viewModel.titleForPeriod()
        } else if let _ = viewModel as? TriplogArchiveViewModel {
            title = "triplog.tripArchive.title".localized
        }

        NotificationCenter.default.addObserver(self, selector: #selector(Self.didDeactivateVehicleNotification), name: .vehicleProfileDidToggleVehicleActivation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Self.didChangeSelectedVehicleNotification), name: .applicationDidChangeVehicleNotification, object: nil)
    }

    override public func viewWillAppear(_ animated: Bool) {
        navigationItem.largeTitleDisplayMode = .always
        super.viewWillAppear(animated)
        viewModel?.reloadData(clearCache: nil, completion: { _ in })
        guard let viewModel = self.viewModel else {
            return
        }
        AnalyticsRegisterer.shared.registerAnalytic(with: viewModel.analyticKey, parameters: nil)
        if let filteringVehicle = viewModel.currentFilteringVehicle, viewModel.hasMoreThanOneVehicle {
            vehiclePicker = VPVehicleSelectorControl(with: .bubble, controlSize: .big, icon: nil, title: filteringVehicle.name.uppercased())
            vehiclePicker!.addTarget(self, action: #selector(TriplogOverviewViewController.presentCarPicker), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: vehiclePicker!)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        presentingStats = false
    }

    @objc func didDeactivateVehicleNotification() {
        viewModel?.currentFilteringVehicle = nil
        navigationController?.popToRootViewController(animated: false)
    }

    @objc func didChangeSelectedVehicleNotification() {
        guard let drivingVehicle = VehicleProfileModule.currentDrivingVehicle() else { return }
        handleVehicleChange(for: drivingVehicle)
        if !presentingStats {
            navigationController?.popToRootViewController(animated: false)
        }
    }

    func handleVehicleChange(for vehicle: VehicleProfileType) {
        guard var viewModel = self.viewModel else { return }
        viewModel.currentFilteringVehicle = vehicle
        vehiclePicker?.configure(with: vehicle)
        reloadViewData()
    }
}

// MARK: ReloadableViewController

extension TriplogOverviewViewController: ReloadableViewController {
    public func reloadViewData() {
        viewModel?.reloadData(clearCache: true, completion: { _ in })
    }

    @objc public func presentCarPicker() {
        guard let filteringVehicle = self.viewModel?.currentFilteringVehicle else {
            return
        }
        let controller = VehicleProfileCarSelectorViewController(with: .active)
        controller.delegate = self
        controller.setInitialSelection(with: filteringVehicle)
        controller.presentFrom(on: self, with: "triplog.overview.selectVehicle".localized)
    }
}

// MARK: VehicleProfileCarSelectionDelegate

extension TriplogOverviewViewController: VehicleProfileCarSelectionDelegate {
    public func vehicleProfileSelectorShouldChangeSelectedVehicle(_ vehicle: VehicleProfileType) -> Bool {
        handleVehicleChange(for: vehicle)
        return true
    }
}

// MARK: TriplogViewModelDelegate

extension TriplogOverviewViewController: TriplogViewModelDelegate {
    public func viewModelUpdated(_ sender: Any) {
        guard let viewModel = sender as? TriplogOverviewViewModelProtocol, let triplogView = triplogView else { return }
        triplogView.viewModel = viewModel
        dismissErrorView(from: self.view)
    }

    public func viewModelDidFail(with error: Error) {
        guard /*let error = error as? NetworkError,*/ let view = self.view as? TriplogOverviewViewProtocol else { return }
        let error = NetworkError.error(from: error as NSError)
        view.reloadTripsData(fromFail: true)
        let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
        let messageViewModel = MessageViewModel.viewModel(with: style)
        presentErrorView(with: messageViewModel, in: view)
    }
}

// MARK: TriplogMonthCardViewDelegate

extension TriplogOverviewViewController: TriplogMonthCardViewDelegate {
    public func triplogMonthCardDidSelect(_ item: TriplogOverviewCardViewModelProtocol) {
        switch item.model?.cardType {
        case .archive:
            guard let viewModel = viewModel as? TriplogOverviewViewModel,
                var archiveViewModel = viewModel.archiveViewModel(),
                let archiveOverviewController = container.resolve(TriplogOverviewViewController.self) else { return }
            archiveViewModel.delegate = archiveOverviewController
            archiveOverviewController.viewModel = archiveViewModel
            navigationController?.pushViewController(archiveOverviewController, animated: true)
        case .archivedPeriod:
            guard let viewModel = viewModel as? TriplogArchiveViewModel,
                let periodViewModel = viewModel.archivedPeriodViewModel(for: item),
                let archivePeriodOverviewController = container.resolve(TriplogOverviewViewController.self) else { return }
            periodViewModel.delegate = archivePeriodOverviewController
            archivePeriodOverviewController.viewModel = periodViewModel
            navigationController?.pushViewController(archivePeriodOverviewController, animated: true)
        default:
            guard let viewModel = viewModel else { return }
            guard item.canBeClicked() else {
                ToastMessage.shared.present(message: ToastViewModel(title: "triplog.overview.cannotOpenToast".localized), completion: nil)
                return
            }
            guard let detailViewModel = viewModel.monthDetailViewModel(for: item),
                let monthController = container.resolve(TriplogMonthViewController.self) else { return }
            monthController.viewModel = detailViewModel
            navigationController?.pushViewController(monthController, animated: true)
        }
    }

    public func presentMonthlyStatsTapped() {
        presentingStats = true
        let statsController = MonthlyStatsModule.rootViewController()
        navigationController?.pushViewController(statsController, animated: true)
    }
}
