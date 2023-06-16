import UIKit

// MARK: - DiscountHowToViewController

public class DiscountHowToViewController: UIViewController {
    public var viewModel: DiscountHowToViewModelProtocol?

    public required init(with viewModel: DiscountHowToViewModel) {
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func loadView() {
        let howToView = DiscountHowToView()
        howToView.viewModel = viewModel
        view = howToView
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.reloadData()
        AnalyticsRegisterer.shared.registerAnalytic(with: AnalyticsKeys.howToGet25Shown, parameters: nil)
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

// MARK: DiscountsViewModelDelegate

extension DiscountHowToViewController: DiscountsViewModelDelegate {
    public func viewModelUpdated(_ sender: Any) {
        guard let view = view as? DiscountHowToViewProtocol, let viewModel = viewModel else { return }
        view.viewModel = viewModel
        title = viewModel.title
    }

    public func viewModelDidFail(with error: Error) {} //TODO: Not specified in UX/UI
}
