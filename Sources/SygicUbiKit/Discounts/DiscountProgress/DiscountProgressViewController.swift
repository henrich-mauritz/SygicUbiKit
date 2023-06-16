import UIKit

// MARK: - DiscountProgressViewController

class DiscountProgressViewController: UIViewController {
    public var viewModel: DiscountProgressViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "discounts.monthlyProgress.title".localized
    }

    public required init(with vehicle: VehicleProfileType) {
        super.init(nibName: nil, bundle: nil)
        let viewModel = DiscountProgressViewModel(with: vehicle)
        viewModel.delegate = self
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func loadView() {
        let progressView = DiscountProgressView()
        progressView.viewModel = viewModel
        view = progressView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.reloadData()
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.monthlyProgressShown, parameters: nil)
        guard let viewModel = viewModel else {
            return
        }
        if viewModel.hasMoreThanOneVehicle {
            let indicatorView = VPVehicleIndicatorView(frame: .zero)
            indicatorView.update(with: viewModel.currentFilteringVehicle.name.uppercased())
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
        }
    }
}

// MARK: DiscountProgressViewModelDelegate

extension DiscountProgressViewController: DiscountProgressViewModelDelegate {
    func viewModelUpdated(_ sender: Any) {
        guard let view = view as? DiscountProgressViewProtocol, let viewModel = viewModel else { return }
        view.viewModel = viewModel
    }
}
