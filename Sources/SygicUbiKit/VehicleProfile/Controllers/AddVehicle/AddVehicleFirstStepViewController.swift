
import UIKit

// MARK: - AddVehicleFirstStepViewController

class AddVehicleFirstStepViewController: UIViewController {
    var viewModel: VehicleProfileAddViewModel = VehicleProfileAddViewModel()

    private lazy var stepView: AddVehicleStepView = {
        let view = AddVehicleStepView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.firstStepView.state = .highLighted
        view.secondStepView.state = .incomplete
        view.firstStepView.stepLabel.text = "1"
        view.secondStepView.stepLabel.text = "2"
        return view
    }()

    var firstStepView: AddVehicleFirstStepView {
        guard let v = view as? AddVehicleFirstStepView else { fatalError("The view is not AddVehicleFirstStepView") }
        return v
    }

    override func loadView() {
        let v = AddVehicleFirstStepView(frame: .zero)
        v.delegate = self
        v.viewModel = viewModel
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""
        //navigationItem.titleView = stepView //could return maybe
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.vehicle.vehicleType = .unknown
    }
}

// MARK: AddVehicleFirstStepViewDelegate

extension AddVehicleFirstStepViewController: AddVehicleFirstStepViewDelegate {
    func didSelectCar(with type: VehicleType) {
        viewModel.vehicle.vehicleType = type
        let nextController = AddVehicleSecondStepViewController(with: viewModel)
        navigationController?.pushViewController(nextController, animated: true)
    }
}
