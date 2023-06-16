import UIKit

// MARK: - VehicleProfileListViewController

public class VehicleProfileListViewController: UIViewController, InjectableType {
    public var viewModel: VehicleListViewModel?
    private var listView: VehicleProfileListView {
        guard let v = view as? VehicleProfileListView else { fatalError("The view is not a listView") }
        return v
    }

    override public func loadView() {
        let v = VehicleProfileListView()
        v.delegate = self
        view = v
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "vehicleProfile.overview.title".localized
        viewModel = VehicleListViewModel()
        viewModel?.delegate = self
        listView.toggleActivityIndicator(animating: true)
        viewModel?.loadVehicles(cleanCache: true)
        navigationItem.backButtonTitle = ""
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listView.reloadTableView()
    }
}

// MARK: VehicleListViewModelDelegate

extension VehicleProfileListViewController: VehicleListViewModelDelegate {
    public func didUpdate(viewModel: VehicleListViewModel) {
        listView.toggleActivityIndicator(animating: false)
        listView.viewModel = viewModel
    }

    public func didFailUpdate(viewModel: VehicleListViewModel, with error: Error) {
        //TODO: present error
        listView.toggleActivityIndicator(animating: false)
    }
}

// MARK: VehicleProfileListDelegate

extension VehicleProfileListViewController: VehicleProfileListDelegate {
    func shouldPresentDetail(for vehicle: NetworkVehicle) {
        let detail = VehicleProfileDetailViewController(with: VehicleProfileEditViewModel(with: vehicle))
        navigationController?.pushViewController(detail, animated: true)
    }

    func shouldPresentAddVehicle() {
        let controller = AddVehicleFirstStepViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
