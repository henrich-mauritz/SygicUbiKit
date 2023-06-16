import SafariServices
import UIKit

// MARK: - MonthlyStatsViewController

public class MonthlyStatsViewController: UIViewController, InjectableType {
    //MARK: - Properties

    private var vehiclePicker: VPVehicleSelectorControl?
    public var viewModel: MonthlyStatsViewModelType? {
        didSet {
            guard let view = view as? MonthlyStatsViewType else { return }
            view.viewModel = viewModel
        }
    }

    //MARK: - Lifecycle

    override public func loadView() {
        guard let statsView = container.resolve(MonthlyStatsViewType.self) else {
            fatalError("MonthlyStatsViewController has not registered a MonthlyStatsViewType view")
        }
        statsView.toggleLoadingIndicator(value: true)
        statsView.delegate = self
        self.view = statsView
        guard title == nil, let dateMonth = self.viewModel?.currentMonthName else {
            return
        }
        title = dateMonth
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if let navigationController = navigationController, navigationController.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "monthlyStats.closeButton".localized, style: .plain, target: self, action: #selector(closeButtonPressed(_:)))
            navigationController.delegate = self
        }
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override public var shouldAutorotate: Bool {
        false
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel == nil {
            guard let vm = container.resolve(MonthlyStatsViewModelType.self) else {
                fatalError("MonthlyStatsViewController has not registered a MonthlyStatsViewModelType viewModel")
            }
            viewModel = vm
        }
        viewModel?.delegate = self
        viewModel?.loadData(clearCache: true)
        if let navigationController = navigationController, navigationController.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "monthlyStats.closeButton".localized, style: .plain, target: self, action: #selector(closeButtonPressed(_:)))
        }
        guard let viewModel = viewModel else {
            return
        }
        if viewModel.showCalendarIcon {
            let calendarItem = UIBarButtonItem(image: UIImage(named: "iconsTriglavCalendar", in: .module, compatibleWith: nil), style: .plain, target: self, action: #selector(calendarButtonPressed(_:)))
            calendarItem.tintColor = .foregroundPrimary

            if let filteringVehicle = configureVehcilePicker() {
                navigationItem.rightBarButtonItems = [calendarItem, filteringVehicle]
            } else {
                navigationItem.rightBarButtonItem = calendarItem
            }
        } else if let filteringVehicle = viewModel.currentFilteringVehicle, viewModel.hasMoreThanOneVehicle {
            let indicatorView = VPVehicleIndicatorView(frame: .zero)
            indicatorView.update(with: filteringVehicle.name.uppercased())
            let pickerItem = UIBarButtonItem(customView: indicatorView)
            navigationItem.rightBarButtonItem = pickerItem
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let analiticRegistering = container.resolve(AnalyticsRegistering.self) else { return }
        analiticRegistering.registerAnalytic(with: AnalyticsKeys.didShowMonthlyStatsOverview, parameters: nil)
    }

    private func configureVehcilePicker() -> UIBarButtonItem? {
        guard let viewModel = viewModel else {
            return nil
        }

        if let filteringVehicle = viewModel.currentFilteringVehicle, viewModel.hasMoreThanOneVehicle {
            vehiclePicker = VPVehicleSelectorControl(with: .bubble, controlSize: .big, icon: nil, title: filteringVehicle.name.uppercased())
            vehiclePicker!.addTarget(self, action: #selector(MonthlyStatsViewController.presentCarPicker), for: .touchUpInside)
            let pickerItem = UIBarButtonItem(customView: vehiclePicker!)
            return pickerItem
        }
        return nil
    }

    @objc
private func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc
private func calendarButtonPressed(_ sender: Any) {
    let nextController = MonthlyStatsMonthSelectorViewController(with: viewModel?.currentFilteringVehicle)
        nextController.delegate = self
        navigationController?.pushViewController(nextController, animated: true)
    }

    @objc public func presentCarPicker() {
        guard let filteringVehicle = self.viewModel?.currentFilteringVehicle else {
            return
        }
        let controller = VehicleProfileCarSelectorViewController(with: .active)
        controller.delegate = self
        controller.setInitialSelection(with: filteringVehicle)
        controller.presentFrom(on: self, with: "monthlyStats.selectVehicle".localized)
    }
}

// MARK: VehicleProfileCarSelectionDelegate

extension MonthlyStatsViewController: VehicleProfileCarSelectionDelegate {
    public func vehicleProfileSelectorDidChangeSelectedVehicle(_ vehicle: VehicleProfileType) {
        viewModel?.currentFilteringVehicle = vehicle
        vehiclePicker?.configure(with: vehicle)
        viewModel?.loadData(clearCache: true)
    }
}

// MARK: MonthlyStatsViewModelDelegate

extension MonthlyStatsViewController: MonthlyStatsViewModelDelegate {
    public func viewModelDidUpdate(viewModel: MonthlyStatsViewModelType) {
        guard let view = self.view as? MonthlyStatsViewType else { return }
        dismissErrorView(from: view.errorView)
        view.viewModel = viewModel
        view.toggleLoadingIndicator(value: false)
        title = viewModel.currentMonthName
    }

    public func viewModelDidFail(viewModel: MonthlyStatsViewModelType, error: Error) {
        guard let view = self.view as? MonthlyStatsViewType /*, let error = error as? NetworkError*/ else { return }
        let error = NetworkError.error(from: error as NSError)
        let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
        let messageViewModel = MessageViewModel.viewModel(with: style)
        presentErrorView(with: messageViewModel, in: view.errorView)
        view.stopRefreshing(fromError: true)
        view.toggleLoadingIndicator(value: false)
    }
}

// MARK: MonthlyStatsMonthSelectorViewControllerDelegate

extension MonthlyStatsViewController: MonthlyStatsMonthSelectorViewControllerDelegate {
    func monthSelectorDidSelectMonth(with monthDate: Date, monthId: String) {
        guard let view = self.view as? MonthlyStatsViewType else { return }
        view.toggleLoadingIndicator(value: true)

        guard var vm = container.resolve(MonthlyStatsViewModelType.self, argument: monthId) else {
            fatalError("MonthlyStatsViewController has not registered a MonthlyStatsViewModelType viewModel")
        }
        let nextController = MonthlyStatsViewController()
        nextController.title = monthDate.monthAndYearFormatter(fullMonthName: true)
        vm.showCalendarIcon = false
        vm.currentFilteringVehicle = self.viewModel?.currentFilteringVehicle
        nextController.viewModel = vm
        navigationController?.pushViewController(nextController, animated: true)
    }
}

// MARK: MonthlyStatsViewDelegate

extension MonthlyStatsViewController: MonthlyStatsViewDelegate {
    public func shouldOpenSafariController(with url: URL) {
        let safariController = SFSafariViewController(url: url)
        safariController.preferredControlTintColor = .actionPrimary
        present(safariController, animated: true, completion: nil)
    }

    public func monthlyStatsViewDidScroll(with scrollView: UIScrollView) {
        guard let navcontroller = navigationController else { return }
        vehiclePicker?.alpha = navcontroller.navigationBar.bounds.height <= 50 ? 0 : 1
    }
}

// MARK: UINavigationControllerDelegate

extension MonthlyStatsViewController: UINavigationControllerDelegate {
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        .portrait
    }
}
