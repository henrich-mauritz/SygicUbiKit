import FloatingPanel
import Swinject
import UIKit

// MARK: - TripDetailPartialScoreViewController

class TripDetailPartialScoreViewController: UIViewController, InjectableType {
    var viewModel: TripDetailPartialScoreViewModelProtocol?

    override func loadView() {
        let partialView = container.resolve(TripDetailPartialScoreViewProtocol.self)
        partialView?.viewModel = viewModel
        partialView?.delegate = self
        view = partialView
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel?.eventType.formattedString()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let vehicle = viewModel?.currentFilteringVehicle, let parentController = parent?.parent else { return }
        let indicatorView = VPVehicleIndicatorView(frame: .zero)
        indicatorView.update(with: vehicle.name.uppercased(), textColor: .buttonForegroundTertiaryPassive, backgroundColor: .buttonBackgroundTertiaryPassive)
        parentController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: indicatorView)
    }
}

// MARK: TripDetailPartialScoreViewDelegate

extension TripDetailPartialScoreViewController: TripDetailPartialScoreViewDelegate {
    func shouldShowPartialEventDetail(eventType: EventType, event: TripDetailEvent) {
        guard let eventViewModel = viewModel?.getEventDetailViewModel(for: event),
            let destination = container.resolve(TriplogEventDetailViewController.self) else { return }
        eventViewModel.currentFilteringVehicle = self.viewModel?.currentFilteringVehicle
        destination.viewModel = eventViewModel
        guard let mapViewController = container.resolve(TriplogMapViewController.self) else { return }
        mapViewController.mapViewModel = eventViewModel.mapViewModel
        mapViewController.contentController = destination
        navigationController?.pushViewController(mapViewController, animated: true)
    }
}

// MARK: FloatingPanelContentController

extension TripDetailPartialScoreViewController: FloatingPanelContentController {
    public var trackableScrollView: UIScrollView? {
        guard let view = view as? TripDetailPartialScoreView else { return nil }
        return view.tableView
    }

    public var floatingPanelLayout: FloatingPanelLayout? { self }

    public var showGrabber: Bool {
        if let viewModel = viewModel, viewModel.isPerfectScore {
            return false
        }
        return true
    }
}

// MARK: FloatingPanelLayout

extension TripDetailPartialScoreViewController: FloatingPanelLayout {
    public var position: FloatingPanelPosition { .bottom }

    public var initialState: FloatingPanelState { .half }

    public var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        var middleAnchor = FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .superview)
        if viewModel?.isPerfectScore ?? false {
            middleAnchor = FloatingPanelLayoutAnchor(absoluteInset: CongratulationsViewCell.cellHeight + Self.defaultTopContentPadding, edge: .bottom, referenceGuide: .safeArea)
        }
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
            .half: middleAnchor,
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 44.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}
