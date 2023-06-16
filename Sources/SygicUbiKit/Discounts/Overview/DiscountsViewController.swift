import SafariServices
import Swinject
import UIKit

// MARK: - DiscountsViewController

public class DiscountsViewController: UIViewController, InjectableType {
    private var viewModel: DiscountsViewModelType? {
        didSet {
            if viewModel != nil {
                viewModel?.delegate = self
            }
        }
    }

    private var carPickerView: VPVehicleSelectorControl?

    override public func loadView() {
        guard let discountsView = container.resolve(DiscountsViewProtocol.self) else {
            view = UIView()
            return
        }
        discountsView.delegate = self
        view = discountsView
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "discounts.title".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        if viewModel == nil, let viewModel = container.resolve(DiscountsViewModelType.self) {
            update(with: viewModel)
        }
        navigationItem.backButtonTitle = ""
        NotificationCenter.default.addObserver(self, selector: #selector(Self.didDeactivateVehicleNotification), name: .vehicleProfileDidToggleVehicleActivation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Self.didChangeSelectedVehicleNotification), name: .applicationDidChangeVehicleNotification, object: nil)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = viewModel else {
            return
        }
        if let currentFiltereingVehicle = viewModel.currentFilteringVehicle, viewModel.hasMoreThanOneVehicle {
            carPickerView = VPVehicleSelectorControl(with: .bubble, controlSize: .big, icon: nil, title: currentFiltereingVehicle.name.uppercased())
            carPickerView!.addTarget(self, action: #selector(DiscountsViewController.presentCarPicker), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: carPickerView!)
        }
        viewModel.reloadData(completion: { _ in
        })
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.discountShown, parameters: nil)
    }

    private func presentEditProfile() {
        let webViewController = EditProfileWebViewController()
        webViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: webViewController)
        navigationController.setupStyling()
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }

    @objc
func presentCarPicker() {
        guard let filteringVehicle = self.viewModel?.currentFilteringVehicle else {
            return
        }
    let controller = VehicleProfileCarSelectorViewController(with: .active)
        controller.delegate = self
        controller.setInitialSelection(with: filteringVehicle)
    controller.presentFrom(on: self, with: "discounts.presentCarPicker".localized)
    }

    @objc
func didDeactivateVehicleNotification() {
        viewModel?.currentFilteringVehicle = nil
        navigationController?.popToRootViewController(animated: false)
    }

    @objc
func didChangeSelectedVehicleNotification() {
        guard let drivingVehicle = VehicleProfileModule.currentDrivingVehicle() else { return }
        handleVehicleChange(for: drivingVehicle)
    }

    func handleVehicleChange(for vehicle: VehicleProfileType) {
        guard let viewModel = self.viewModel else { return }
        viewModel.currentFilteringVehicle = vehicle
        carPickerView?.configure(with: vehicle)
        viewModel.reloadData {[weak self] _ in
            guard let self = self else { return }
            self.update(with: viewModel)
        }
    }
}

// MARK: VehicleProfileCarSelectionDelegate

extension DiscountsViewController: VehicleProfileCarSelectionDelegate {
    public func vehicleProfileSelectorShouldChangeSelectedVehicle(_ vehicle: VehicleProfileType) -> Bool {
        handleVehicleChange(for: vehicle)
        return true
    }
}

// MARK: ReloadableViewController

extension DiscountsViewController: ReloadableViewController {
    public func reloadViewData() {
        viewModel?.reloadData {_ in }
    }
}

// MARK: EditProfileWebViewControllerDelegate

extension DiscountsViewController: EditProfileWebViewControllerDelegate {
    public func editSuccessFul() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: DiscountsViewModelDelegate

extension DiscountsViewController: DiscountsViewModelDelegate {
    public func viewModelDidBegingUpdating() {
        guard let view = self.view as? DiscountsViewProtocol else {
            return
        }
        view.toggleActivityIndicator(value: true)
    }

    public func update(with viewModel: DiscountsViewModelType) {
        self.viewModel = viewModel
        viewModelUpdated(self)
    }

    public func viewModelUpdated(_ sender: Any) {
        guard let view = view as? DiscountsViewProtocol, let viewModel = viewModel else { return }
        view.update(with: viewModel)
        dismissErrorView(from: view.errorViewContainer)
        if viewModel.maxDiscountAvailable {
            NotificationCenter.default.post(name: .discountMaxValueReached, object: nil)
        }
    }

    public func viewModelError(_ message: String, error: DiscountError) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        if error == .incompleteProfile {
            alert.addAction(UIAlertAction(title: "discounts.discountError.closeButton".localized,
                                          style: .default,
                                          handler: nil))
            alert.addAction(UIAlertAction(title: "discounts.discountError.editProfileButton".localized,
                                          style: .cancel,
                                          handler: { [weak self] _ in
                guard let self = self else { return }
                self.presentEditProfile()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "discounts.discountError.okButton".localized.uppercased(),
                                          style: .cancel,
                                          handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }

    //TODO: This method is repeated among the modules. we shall create Common module and add this there.
    public func viewModelDidFail(with error: Error) {
        guard /*let error = error as? NetworkError,*/ let view = view as? DiscountsViewProtocol else {
            return
        }
        let error = NetworkError.error(from: error as NSError)
        view.update(with: nil)
        //TODO: Not found

        let style: MessageViewModel.MessageViewModelStyle = error == .noInternetConnection ? .noInternet : .error
        let messageViewModel = MessageViewModel.viewModel(with: style)
        presentErrorView(with: messageViewModel, in: view.errorViewContainer)
    }
}

// MARK: DiscountsViewDelegate

extension DiscountsViewController: DiscountsViewDelegate {
    public func presentDiscountWebView(at url: URL) {
        let safariController = SFSafariViewController(url: url)
        safariController.preferredControlTintColor = .actionPrimary
        self.present(safariController, animated: true, completion: nil)
    }

    public func discountsViewWantsShowProgress(_ view: DiscountsViewProtocol) {
        guard let vehicle = self.viewModel?.currentFilteringVehicle, let viewController = container.resolve(DiscountProgressViewController.self, argument: vehicle) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }

    public func discountsViewWantsShowInfo(_ view: DiscountsViewProtocol) {
        guard let vehicle = self.viewModel?.currentFilteringVehicle,
              let viewController = container.resolve(DiscountHowToViewController.self, argument: vehicle) else { return }
        navigationController?.pushViewController(viewController, animated: true)
    }

    public func discountsViewWantsShowCodes(_ view: DiscountsViewProtocol) {
        guard let vehicle = self.viewModel?.currentFilteringVehicle,
              let controller = container.resolve(DiscountCodesViewController.self, argument: vehicle) else { return }
        navigationController?.pushViewController(controller, animated: true)
    }

    public func discountsView(_ view: DiscountsViewProtocol, wantsClaimDiscount completion: @escaping ((Bool) -> ())) {
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.discountClaimedTap, parameters: nil)
        let controller = StylingCheckMarkPopUpViewController()
        let viewModel = StylingCheckMarkPopUpViewModel(title: "discounts.claimAlert.title".localized, subtitle: "discounts.claimAlert.description".localized,
                                                       actionTitle: "discounts.claimAlert.claim".localized.uppercased(),
                                                       cancelTitle: "discounts.claimAlert.cancel".localized.uppercased(),
                                                       image: UIImage(named: "question", in: .module,
                                                                      compatibleWith: nil))
        viewModel.cancelButonAction = {
            controller.dismiss(animated: true, completion: nil)
            completion(false)
        }
        viewModel.actionButtonAction = { [weak self] in
            controller.dismiss(animated: true, completion: nil)
            guard let view = self?.view as? DiscountsViewProtocol else {
                return
            }
            view.toggleActivityIndicator(value: true)
            self?.viewModel?.claimDiscount(completion: { claimed in
                view.toggleActivityIndicator(value: false)
                if claimed {
                    self?.viewModelUpdated(viewModel)
                    AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.discountClaimSuccess, parameters: nil)
                }
                completion(claimed)
            })
        }
        controller.configure(with: viewModel)
        PopupManager.shared.presentModalPopup(controller, on: self)
    }
}
