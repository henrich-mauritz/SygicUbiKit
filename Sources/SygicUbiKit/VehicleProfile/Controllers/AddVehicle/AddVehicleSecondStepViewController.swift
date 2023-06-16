import AVFAudio
import UIKit

// MARK: - AddVehicleSecondStepViewController

class AddVehicleSecondStepViewController: UIViewController {
    var viewModel: VehicleProfileAddViewModel

    private var _view: AddVehicleSecondStepView {
        guard let v = self.view as? AddVehicleSecondStepView else {
            fatalError("Nope this can't happen")
        }
        return v
    }

    private lazy var stepView: AddVehicleStepView = {
        let view = AddVehicleStepView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.firstStepView.stepLabel.text = "1"
        view.secondStepView.stepLabel.text = "2"
        view.firstStepView.state = .completed
        view.secondStepView.state = .highLighted
        view.highLightDivider(value: true)
        return view
    }()

    init(with viewModel: VehicleProfileAddViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let v = AddVehicleSecondStepView()
        v.viewModel = viewModel
        v.delegate = self
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        //navigationItem.titleView = stepView //could return maybe
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let view = self.view as? AddVehicleSecondStepView else { return }
        view.textField.becomeFirstResponder()
    }
}

// MARK: AddVehicleSecondStepViewDelegate

extension AddVehicleSecondStepViewController: AddVehicleSecondStepViewDelegate {
    func saveChanges() {
        viewModel.addVehile {[weak self] error in
            guard let self = self else { return }
            self._view.activityIndicator.stopAnimating()
            guard let error = error, let view = self.view as? AddVehicleSecondStepView else {
                ToastMessage.shared.present(message: ToastViewModel(title: "vehicleProfile.toast.created".localized), completion: nil)
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
}
