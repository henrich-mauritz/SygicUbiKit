import UIKit

// MARK: - VehicleProfileDetailViewController

class VehicleProfileDetailViewController: UIViewController {
    public var viewModel: VehicleProfileEditViewModel

    init(with viewModel: VehicleProfileEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.name.uppercased()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let v = VehicleProfileDetailView(frame: .zero)
        v.viewModel = self.viewModel
        v.delegate = self
        view = v
    }
}

// MARK: VehicleProfileDetailViewDelegate

extension VehicleProfileDetailViewController: VehicleProfileDetailViewDelegate {
    func didSelectEditNameVehicle() {
        let editController = VehicleProfileEditViewController(with: viewModel)
        navigationController?.pushViewController(editController, animated: true)
    }

    func presentError(with error: VehicleProfileDetailError) {
        let popupController = StylingPopupViewController()
        let popoverViewModel: StylingPopUpViewModel = StylingPopUpViewModel(title: error.errorTitle, subtitle: error.errorDescription ?? "",
                                                                            actionTitle: "vehicleProfile.edit.errorDeactivate.changeButton".localized.uppercased(),
                                                                            cancelTitle: "vehicleProfile.edit.errorDeactivate.cancelButton".localized.uppercased(), image: error.icon)
        popoverViewModel.actionButtonAction = {[weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true) {
                let controller = VehicleProfileCarSelectorViewController(with: .active)
                controller.delegate = self
                controller.presentFrom(on: self, with: "vehicleProfile.vehiclePicker.title".localized)
            }
        }
        popoverViewModel.cancelButonAction = {
            self.dismiss(animated: true, completion: nil)
        }
        popupController.configure(with: popoverViewModel)
        present(popupController, animated: true, completion: nil)
    }
}

// MARK: VehicleProfileCarSelectionDelegate

extension VehicleProfileDetailViewController: VehicleProfileCarSelectionDelegate {
    func vehicleProfileSelectorShouldChangeSelectedVehicle(_ vehicle: VehicleProfileType) -> Bool {
        return true
    }
}
