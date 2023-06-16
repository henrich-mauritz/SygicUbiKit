import SafariServices
import UIKit

// MARK: - DiscountCodesViewController

public class DiscountCodesViewController: UIViewController {
    public var viewModel: DiscountCodesViewModelProtocol? {
        didSet {
            if viewModel != nil {
                viewModel?.delegate = self
            }
        }
    }
    private var notificationsObservers = [NSObjectProtocol]()
    private var carPickerView: VPVehicleSelectorControl?

     public required init(with viewModel: DiscountCodesViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel?.delegate = self
         title = "discounts.yourCodes.title".localized
        observeNetworkChange()
     }

     required init?(coder: NSCoder) {
         super.init(coder: coder)
     }

    deinit {
        notificationsObservers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

     override public func loadView() {
         let discountView = DiscountCodesView()
        discountView.delegate = self
         discountView.viewModel = viewModel
         view = discountView
     }

     override public func viewDidLoad() {
         super.viewDidLoad()
         NotificationCenter.default.addObserver(self, selector: #selector(Self.didDeactivateVehicleNotification), name: .vehicleProfileDidToggleVehicleActivation, object: nil)
//         NotificationCenter.default.addObserver(self, selector: #selector(Self.didChangeSelectedVehicleNotification), name: .applicationDidChangeVehicleNotification, object: nil)
     }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = self.viewModel else { return }
        viewModel.reloadData(completion: {})
        if viewModel.hasMoreThanOneVehicle,
           let currentFilteringVehicle = viewModel.currentFilteringVehicle {
            carPickerView = VPVehicleSelectorControl(with: .bubble, controlSize: .big, icon: nil, title: currentFilteringVehicle.name.uppercased())
            carPickerView!.addTarget(self, action: #selector(DiscountsViewController.presentCarPicker), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: carPickerView!)
        }
        viewModel.registerCodesShown()
    }
    
    @objc func presentCarPicker() {
        guard let filteringVehicle = self.viewModel?.currentFilteringVehicle else {
            return
        }
        let controller = VehicleProfileCarSelectorViewController(with: .active)
        controller.delegate = self
        controller.setInitialSelection(with: filteringVehicle)
        controller.presentFrom(on: self, with: "discounts.presentCarPicker".localized)
    }
    
    @objc func didDeactivateVehicleNotification() {
        viewModel?.currentFilteringVehicle = nil
        navigationController?.popToRootViewController(animated: false)
    }
    
//    @objc func didChangeSelectedVehicleNotification() {
//        guard let drivingVehicle = VehicleProfileModule.currentDrivingVehicle() else { return }
//        handleVehicleChange(for: drivingVehicle)
//    }
    
    private func handleVehicleChange(for vehicle: VehicleProfileType) {
        guard let viewModel = self.viewModel else { return }
        viewModel.currentFilteringVehicle = vehicle
        carPickerView?.configure(with: vehicle)
        viewModel.reloadData {[weak self] in
            guard let self = self else { return }
            self.viewModelUpdated(self)
        }
    }
    
}

extension DiscountCodesViewController {
    func observeNetworkChange() {
        notificationsObservers.append(NotificationCenter.default.addObserver(forName: .flagsChanged,
                                                                             object: nil,
                                                                             queue: nil) {[weak self] _ in
                                                DispatchQueue.main.async {
                                                    switch ReachabilityManager.shared.status {
                                                    case .wwan, .wifi:
                                                        self?.viewModel?.reloadData(completion: {})
                                                    default:
                                                        print("no connection reached")
                                                    }
                                                }
        })
    }
}

// MARK: DiscountsViewModelDelegate

extension DiscountCodesViewController: DiscountsViewModelDelegate {
    public func viewModelUpdated(_ sender: Any) {
        dismissErrorView(from: self.view)
        guard let view = view as? DiscountCodesViewProtocol, let viewModel = viewModel else { return }
        view.prepareUIForGeneralError(value: false)
        view.viewModel = viewModel
    }

    public func viewModelDidFail(with error: Error) {
        guard /*let error = error as? NetworkError,*/ let view = view as? DiscountCodesViewProtocol else { return }
        let error = NetworkError.error(from: error as NSError)
        let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
        let messageViewModel = MessageViewModel.viewModel(with: style)
        view.prepareUIForGeneralError(value: true)
        presentErrorView(with: messageViewModel)
    }
}

// MARK: DiscountCodesViewDelegate

extension DiscountCodesViewController: DiscountCodesViewDelegate {
    func presentDiscountWebView(at url: URL) {
        let safariController = SFSafariViewController(url: url)
        safariController.preferredControlTintColor = .actionPrimary
        self.present(safariController, animated: true, completion: nil)
        guard let viewModel = self.viewModel else { return }
        viewModel.registerApplyOnlineAnalytics()
    }
}

// MARK: VehicleProfileCarSelectionDelegate

extension DiscountCodesViewController: VehicleProfileCarSelectionDelegate {
    public func vehicleProfileSelectorShouldChangeSelectedVehicle(_ vehicle: VehicleProfileType) -> Bool {
        handleVehicleChange(for: vehicle)
        return true
    }
}
