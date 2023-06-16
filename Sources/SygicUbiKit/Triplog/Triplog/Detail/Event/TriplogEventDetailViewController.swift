import FloatingPanel
import Swinject
import UIKit

// MARK: - TriplogEventDetailViewController

public class TriplogEventDetailViewController: UIViewController, InjectableType {
    public var viewModel: TriplogEventDetailViewModelProtocol?

    override public func loadView() {
        let partialEventView = container.resolve(TriplogEventDetailViewProtocol.self)
        partialEventView?.viewModel = viewModel
        partialEventView?.delegate = self
        view = partialEventView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel?.eventType.formattedString()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let vehicle = viewModel?.currentFilteringVehicle, let parentController = parent?.parent else { return }
        let indicatorView = VPVehicleIndicatorView(frame: .zero)
        indicatorView.update(with: vehicle.name.uppercased())
        parentController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
    }
}

// MARK: TriplogEventDetailViewDelegate

extension TriplogEventDetailViewController: TriplogEventDetailViewDelegate {
    public func shouldShowReportView() {
        guard let destination = container.resolve(TriplogReportMapViewController.self) else { return }
        destination.viewModel = viewModel?.getEventReportViewModel()
        destination.viewModel?.delegate = destination
        destination.delegate = self
        let navigationController = UINavigationController(rootViewController: destination)
        navigationController.setupStyling()
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.delegate = self
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: FloatingPanelContentController

extension TriplogEventDetailViewController: FloatingPanelContentController {
    public var trackableScrollView: UIScrollView? {
        guard let view = view as? TriplogEventDetailView else { return nil }
        return view.tableView
    }

    public var floatingPanelLayout: FloatingPanelLayout? { self }

    public var showGrabber: Bool {
        if let viewModel = viewModel, viewModel.eventType == .speeding {
            return true
        }
        return false
    }
}

// MARK: TriplogReportMapViewControllerDelegate

extension TriplogEventDetailViewController: TriplogReportMapViewControllerDelegate {
    func didReportEvent(reported: Bool) {
        guard let view = view as? TriplogEventDetailView else { return }
        view.viewModel = self.viewModel
    }
}

// MARK: FloatingPanelLayout

extension TriplogEventDetailViewController: FloatingPanelLayout {
    public var position: FloatingPanelPosition { .bottom }

    public var initialState: FloatingPanelState { .half }

    public var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        var middleAnchor = FloatingPanelLayoutAnchor(absoluteInset: BasicTableViewCell.cellHeight + Self.defaultTopContentPadding, edge: .bottom, referenceGuide: .safeArea)
        if let viewModel = viewModel, viewModel.eventType == .speeding {
            middleAnchor = FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .superview)
        }
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: middleAnchor,
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}

// MARK: UINavigationControllerDelegate

extension TriplogEventDetailViewController: UINavigationControllerDelegate {
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        .portrait
    }
}
