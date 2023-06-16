import UIKit

// MARK: - VehicleProfileEditViewController

class VehicleProfileEditViewController: UIViewController {
    var viewModel: VehicleProfileEditViewModel
    init(with vehicleViewModel: VehicleProfileEditViewModel) {
        self.viewModel = vehicleViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let v = VehicleProfileEditView()
        v.delegate = self
        v.viewModel = self.viewModel
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let view = self.view as? VehicleProfileEditView else { return }
        view.textField.becomeFirstResponder()
    }

    func parseResponse(with error: VehicleProfileAddEditError?) {
        guard let error = error, let view = self.view as? VehicleProfileEditView else {
            ToastMessage.shared.present(message: ToastViewModel(title: "vehicleProfile.toast.nameChanged".localized), completion: nil)
            if let listController = self.navigationController?.viewControllers.first(where: { $0 is VehicleProfileListViewController}) {
                self.navigationController?.popToViewController(listController, animated: true)
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        view.saveChangesButton.isEnabled = true

        if error == .vehicleWithThisNameAlreadyExists {
            view.configureForError(error: error)
            return
        }

        let modalController = StylingPopupViewController()
        let modalViewModel = StylingPopUpViewModel(title: error.localizedTitle,
                                                   subtitle: error.localizedDescription,
                                                   actionTitle: "vehicleProfile.edit.error.okButton".localized, cancelTitle: nil, image: error.errorIcon)
        modalViewModel.actionButtonAction = { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }

        modalController.configure(with: modalViewModel)
        self.present(modalController, animated: true, completion: nil)
    }
}

// MARK: VehicleProfileEditViewProtocol

extension VehicleProfileEditViewController: VehicleProfileEditViewProtocol {
    func saveChanges() {
        viewModel.editVehcile {[weak self] error in
            guard let self = self else { return }
            self.parseResponse(with: error)
        }
    }
}
