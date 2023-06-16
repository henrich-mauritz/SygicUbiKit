import Swinject
import UIKit

// MARK: - TriplogMonthViewController

public class TriplogMonthViewController: UIViewController, InjectableType {
    public var viewModel: TriplogCardViewModelProtocol? {
        didSet {
            viewModel?.delegate = self
        }
    }

    @objc private var toggleListGroupBarButton: UIBarButtonItem = {
        let image = UIImage(named: "triplogListIcon", in: .module, compatibleWith: nil)
        let barButton = UIBarButtonItem(image: image,
                                        style: .plain,
                                        target: nil,
                                        action: nil) //can't use self here yet
        barButton.tintColor = .foregroundPrimary
        return barButton
    }()

    private var monthView: TriplogMonthViewProtocol?

    override public func loadView() {
        monthView = container.resolve(TriplogMonthViewProtocol.self)
        monthView?.delegate = self
        view = monthView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel, let view = self.view as? TriplogMonthViewProtocol else { return }
        title = viewModel.monthTitle
        view.toggleActivityIndicator(value: true)

        viewModel.reloadTrips(purgeData: viewModel.isCurrentMonth) { _ in
            view.toggleActivityIndicator(value: false)
        }
        var barbuttomItems: [UIBarButtonItem] = []
        if let vehicle = viewModel.currentFilteringVehicle {
            let indicatorView = VPVehicleIndicatorView(frame: .zero)
            indicatorView.update(with: vehicle.name.uppercased())
            barbuttomItems.append(UIBarButtonItem(customView: indicatorView))
        }

        if let layoutToggler = setupToggableLayoutBarButton() {
            barbuttomItems.insert(layoutToggler, at: 0)
        }
        navigationItem.rightBarButtonItems = barbuttomItems
        //registering on viewDidLoad so when navigating back and forth on details wont get registered over and over
        let monthVal = viewModel.model?.monthNumber
        let yearVal = viewModel.model?.yearNumber
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.monthlyCardShown,
                                                    parameters: [
                                                        AnalyticsKeys.Parameters.monthKey: monthVal == nil ? "-" : String(monthVal!),
                                                        AnalyticsKeys.Parameters.yearKey: yearVal == nil ? "-" : String(yearVal!),
                                                    ])
    }

    private func setupToggableLayoutBarButton() -> UIBarButtonItem? {
        guard let viewModel = viewModel else { return nil }
        if TripLogSettingsManager.shared.currentSettings.toggalbleLayouts == true {
            toggleListGroupBarButton.target = self
            toggleListGroupBarButton.action = #selector(TriplogMonthViewController.toggleListGroup)
            var buttonImage: UIImage?
            if viewModel.listingType == .grid {
                buttonImage = UIImage(named: "triplogListIcon", in: .module, compatibleWith: nil)
            } else {
                buttonImage = UIImage(named: "triplogGroupIcon", in: .module, compatibleWith: nil)
            }
            toggleListGroupBarButton.image = buttonImage
            return toggleListGroupBarButton
        }

        return nil
    }
}

// MARK: ReloadableViewController

extension TriplogMonthViewController: ReloadableViewController {
    public func reloadViewData() {
        viewModel?.reloadTrips(purgeData: true, completion: { _ in })
    }
}

// MARK: TriplogViewModelDelegate

extension TriplogMonthViewController: TriplogViewModelDelegate {
    public func viewModelUpdated(_ sender: Any) {
        guard let viewModel = sender as? TriplogCardViewModelProtocol, let monthView = monthView else { return }
        monthView.update(with: viewModel)
        dismissErrorView(from: self.view)
    }

    public func viewModelDidFail(with error: Error) {
        guard /*let error = error as? NetworkError,*/ let view = self.view as? TriplogMonthViewProtocol, let viewModel = self.viewModel else {
            return
        }
        let error = NetworkError.error(from: error as NSError)
        let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
        let messageViewModel = MessageViewModel.viewModel(with: style)
        view.update(with: viewModel)
        presentErrorView(with: messageViewModel, in: view)
    }
}

// MARK: TriplogMonthViewDelegate

extension TriplogMonthViewController: TriplogMonthViewDelegate {
    public func triplogMonthViewReloadTrips(_ view: TriplogMonthViewProtocol) {
        //view.toggleActivityIndicator(value: true)
        viewModel?.reloadTrips(purgeData: true) { _ in
            view.toggleActivityIndicator(value: false)
        }
    }

    public func triplogMonthViewLoadMoreTrips(_ view: TriplogMonthViewProtocol) {
        viewModel?.loadMoreTrips()
    }

    public func triplogMonthViewDidSelect(_ view: TriplogMonthViewProtocol, trip: TriplogTripCardViewModelProtocol) {
        guard let detailViewModel = viewModel?.tripDetailViewModel(for: trip),
            let detailController = container.resolve(TripDetailViewController.self) else { return }
        detailViewModel.currentFilteringVehicle = self.viewModel?.currentFilteringVehicle
        detailController.viewModel = detailViewModel
        navigationController?.pushViewController(detailController, animated: true)
    }
}

public extension TriplogMonthViewController {
    @objc
func toggleListGroup() {
        var buttonImage: UIImage?
        if self.monthView?.viewModel?.listingType == .grid {
            buttonImage = UIImage(named: "triplogGroupIcon", in: .module, compatibleWith: nil)
            monthView?.viewModel?.listingType = .list
        } else {
            buttonImage = UIImage(named: "triplogListIcon", in: .module, compatibleWith: nil)
            monthView?.viewModel?.listingType = .grid
        }
        toggleListGroupBarButton.image = buttonImage
    }
}
