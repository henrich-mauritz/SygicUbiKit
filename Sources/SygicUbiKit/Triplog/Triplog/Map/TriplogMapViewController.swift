import CoreLocation
import FloatingPanel
import Swinject
import UIKit

// MARK: - FloatingPanelContentController

public protocol FloatingPanelContentController: UIViewController {
    var trackableScrollView: UIScrollView? { get }
    var floatingPanelLayout: FloatingPanelLayout? { get }
    var showGrabber: Bool { get }
    var contentPadding: UIEdgeInsets { get }
}

public extension FloatingPanelContentController {
    static var defaultTopContentPadding: CGFloat { 30 }

    var trackableScrollView: UIScrollView? { nil }
    var floatingPanelLayout: FloatingPanelLayout? { nil }
    var showGrabber: Bool { true }
    var contentPadding: UIEdgeInsets { UIEdgeInsets(top: Self.defaultTopContentPadding, left: 0, bottom: 0, right: 0) }
}

// MARK: - TriplogMapViewModelProtocol

public protocol TriplogMapViewModelProtocol {
    var tripId: String { get }
    var animate: Bool { get set }
    var tripCoordinates: [CLLocationCoordinate2D] { get }
    var zoomCoordinates: [CLLocationCoordinate2D]? { get }
    var eventPins: [(items: [TripDetailEvent], type: EventType)] { get }
    var shouldSelectPins: Bool { get set }
    func getEventDetailViewModel(for event: TripDetailEvent, with type: EventType) -> TriplogEventDetailViewModelProtocol?
}

// MARK: - TriplogMapViewModel

public class TriplogMapViewModel: TriplogMapViewModelProtocol, InjectableType {
    public var animate: Bool = false
    public var tripId: String
    public var tripCoordinates: [CLLocationCoordinate2D]
    public var zoomCoordinates: [CLLocationCoordinate2D]?
    public var eventPins: [(items: [TripDetailEvent], type: EventType)]
    public var shouldSelectPins: Bool = true

    public init(with events: [(items: [TripDetailEvent], type: EventType)], tripId: String, tripCoordinates: [CLLocationCoordinate2D], zoomCoordinates: [CLLocationCoordinate2D]?) {
        eventPins = events
        self.tripId = tripId
        self.tripCoordinates = tripCoordinates
        self.zoomCoordinates = zoomCoordinates
    }

    public convenience init(with data: TripDetailDataProtocol, forVehicle type: VehicleType = .car) {
        var events: [(items: [TripDetailEvent], type: EventType)] = []
        for eventGroup in data.events {
            if type != .motorcycle {
                events.append((items: eventGroup.items ?? [], type: eventGroup.type))
            } else if eventGroup.type != .distraction {
                events.append((items: eventGroup.items ?? [], type: eventGroup.type))
            }
        }
        let coordinates = data.coordinates ?? []
        self.init(with: events, tripId: data.tripId, tripCoordinates: coordinates, zoomCoordinates: coordinates)
    }

    public func getEventDetailViewModel(for event: TripDetailEvent, with type: EventType) -> TriplogEventDetailViewModelProtocol? {
        let eventModel = TripEventDetailModel(tripId: tripId, eventType: type, eventDetail: event, tripCoordinates: tripCoordinates)
        return container.resolve(TriplogEventDetailViewModelProtocol.self, argument: eventModel as TriplogEventDetailModelProtocol)
    }
}

// MARK: - TriplogMapViewController

public class TriplogMapViewController: UIViewController, InjectableType {
    public var mapViewModel: TriplogMapViewModelProtocol?

    public var contentController: FloatingPanelContentController?

    public var mapView: TriplogMapViewProtocol?

    lazy var bottomSheet: FloatingPanelController = {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = Styling.cornerRadiusModalPopup
        appearance.backgroundColor = .backgroundModal
        let fpc = FloatingPanelController()
        fpc.surfaceView.appearance = appearance
        fpc.surfaceView.grabberHandlePadding = 11
        fpc.surfaceView.grabberHandleSize = CGSize(width: 50, height: 4)
        fpc.delegate = self
        return fpc
    }()

    override public func loadView() {
        view = UIView()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        if let content = contentController {
            if let customLayout = content.floatingPanelLayout {
                bottomSheet.layout = customLayout
            }
            bottomSheet.surfaceView.grabberHandle.isHidden = !content.showGrabber
            bottomSheet.surfaceView.contentPadding = content.contentPadding
            bottomSheet.set(contentViewController: content)
            if let scrollView = content.trackableScrollView {
                bottomSheet.track(scrollView: scrollView)
            }
            bottomSheet.addPanel(toParent: self)
            title = content.title
            
            navigationItem.leftItemsSupplementBackButton = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "backIconCircular", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backButtonTapped))
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let mapViewModel = self.mapViewModel, mapViewModel.animate == false else {
            return
        }
        initializeMap()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("::::DID APPEAR::::")
        guard let viewModel = mapViewModel else { return }
        initializeMap()
        mapView?.removeAllMapObjects()
        mapView?.addPolyline(with: viewModel.tripCoordinates)
        mapView?.addStartEndPinsOnMap(coordinates: viewModel.tripCoordinates)
        for events in viewModel.eventPins {
            mapView?.addEventPins(with: events.type, items: events.items, withPolyline: true, animated: false)
        }
        if !viewModel.animate {
         adjustMapVisibleArea()
        }
    }

    func adjustMapVisibleArea() {
        guard let viewModel = mapViewModel, let mapView = mapView, mapView.frame != .zero else { return }
        let mapMargin: CGFloat = 16
        let bottomMargin: CGFloat = mapView.frame.height - bottomSheet.surfaceLocation(for: .half).y - view.safeAreaInsets.bottom + mapMargin
        mapView.setVisibleArea(coordinates: viewModel.zoomCoordinates ?? viewModel.tripCoordinates,
                               margins: UIEdgeInsets(top: 0, left: mapMargin, bottom: bottomMargin, right: mapMargin), animated: viewModel.animate)
    }

    private func initializeMap() {
        guard mapView == nil, let map = container.resolve(TriplogMapViewProtocol.self) else {
            return
        }
        mapView = map
        mapView?.delegate = self
        mapView?.isUserInteractionEnabled = true
        view.cover(with: map, toSafeArea: false)
        view.sendSubviewToBack(map)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: TriplogMapViewDelegate

extension TriplogMapViewController: TriplogMapViewDelegate {
    public func mapView(_ mapView: TriplogMapViewProtocol, didSelect event: TripDetailEvent, with type: EventType) {
        guard let viewModel = mapViewModel,
            viewModel.shouldSelectPins,
            let eventViewModel = viewModel.getEventDetailViewModel(for: event, with: type),
            let destination = container.resolve(TriplogEventDetailViewController.self) else { return }
        destination.viewModel = eventViewModel
        guard let mapViewController = container.resolve(TriplogMapViewController.self) else { return }
        mapViewController.mapViewModel = eventViewModel.mapViewModel
        mapViewController.contentController = destination
        navigationController?.pushViewController(mapViewController, animated: true)
    }

    public func reportAnnotationPlaced(coord: CLLocationCoordinate2D) {}
    
    public func mapRenderingFinished(image: UIImage) {
        //do nothing
    }
}

// MARK: FloatingPanelControllerDelegate

extension TriplogMapViewController: FloatingPanelControllerDelegate {
    public func floatingPanelShouldBeginDragging(_ fpc: FloatingPanelController) -> Bool {
        !fpc.surfaceView.grabberHandle.isHidden
    }
}
