import MapKit
import UIKit

// MARK: - TripDetailViewProtocol

public protocol TripDetailViewProtocol where Self: UIView {
    var delegate: TripDetailWithMapViewControllerDelegate? { get set }
    var viewModel: TripDetailViewModelProtocol? { get set }
    func replaceMapWithRenderedImage(image: UIImage)
}

// MARK: - TripDetailPartialScoreViewProtocol

public protocol TripDetailPartialScoreViewProtocol where Self: UIView {
    var delegate: TripDetailPartialScoreViewDelegate? { get set }
    var viewModel: TripDetailPartialScoreViewModelProtocol? { get set }
}

// MARK: - TriplogEventDetailViewProtocol

public protocol TriplogEventDetailViewProtocol where Self: UIView {
    var delegate: TriplogEventDetailViewDelegate? { get set }
    var viewModel: TriplogEventDetailViewModelProtocol? { get set }
}

// MARK: - TripDetailViewControllerDelegate

public protocol TripDetailViewControllerDelegate where Self: UIViewController {
    func shouldShowScoreDetail()
    func showAboutYourScore()
}

public typealias TripDetailWithMapViewControllerDelegate = TripDetailViewControllerDelegate & TriplogMapViewDelegate

// MARK: - TriplogMapViewDelegate

public protocol TriplogMapViewDelegate: AnyObject {
    func mapView(_ mapView: TriplogMapViewProtocol, didSelect event: TripDetailEvent, with type: EventType)
    func reportAnnotationPlaced(coord: CLLocationCoordinate2D)
    func mapRenderingFinished(image: UIImage)
}

// MARK: - TriplogMapViewProtocol

public protocol TriplogMapViewProtocol where Self: UIView {
    var delegate: TriplogMapViewDelegate? { get set }
    var isReportMap: Bool { get set }
    var viewModel: TripDetailReportViewModelProtocol? { get set }
    func addPolyline(with coordinates: [CLLocationCoordinate2D])
    func setVisibleArea(coordinates: [CLLocationCoordinate2D], margins: UIEdgeInsets, animated: Bool)
    func addStartEndPinsOnMap(coordinates: [CLLocationCoordinate2D]?)
    func addEventPins(with type: EventType, items: [TripDetailEvent], withPolyline: Bool, animated: Bool)
    func removeAllMapObjects()
}

// MARK: - TripDetailPartialScoreViewDelegate

public protocol TripDetailPartialScoreViewDelegate where Self: UIViewController {
    func shouldShowPartialEventDetail(eventType: EventType, event: TripDetailEvent)
}

// MARK: - TriplogEventDetailViewDelegate

public protocol TriplogEventDetailViewDelegate where Self: UIViewController {
    func shouldShowReportView()
}

// MARK: - TripDetailViewModelProtocol

/// Has to be passed by reference hence the class constraint
public protocol TripDetailViewModelProtocol: AnyObject {
    var tripID: String? { get set }
    var monthData: TriplogTripDataType? { get set }
    var delegate: TriplogViewModelDelegate? { get set }
    var loading: Bool { get }
    var fromLocationName: String { get }
    var toLocationName: String { get }
    var distanceTravelled: String { get }
    var tripDuration: String { get }
    var averageSpeed: String { get }
    var maxSpeed: String { get }
    var startTime: Date { get }
    var endTime: Date { get }
    var mapTableData: [(name: String, description: String)] { get }
    var coordinates: [CLLocationCoordinate2D]? { get }
    var mapViewModel: TriplogMapViewModelProtocol? { get }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    var vehicleId: String? { get set } //mutually exclusive with currentFilteringVehicle
    func loadData()

    // Score view
    var eventTableData: [TripDetailDataRow] { get }
    var overallScore: String { get }
    var isPerfectTrip: Bool { get }

    // Event
    func getEventsData(for type: EventType) -> TripDetailEventsGroup?
    func getPartialScoreViewModel(for type: EventType) -> TripDetailPartialScoreViewModelProtocol?
    func getCongratulationsViewModel() -> TripDetailCongratulationsViewModelProtocol
}

// MARK: - TripDetailPartialScoreViewModelProtocol

public protocol TripDetailPartialScoreViewModelProtocol: AnyObject {
    var tripCoordinates: [CLLocationCoordinate2D] { get }
    var eventType: EventType { get }
    var events: [TripDetailEvent] { get }
    var scoreDescription: String { get }
    var score: String { get }
    var isPerfectScore: Bool { get }
    var mapViewModel: TriplogMapViewModelProtocol? { get }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    func getCongratulationsViewModel() -> TripDetailCongratulationsViewModelProtocol
    func getEventDetailViewModel(for event: TripDetailEvent) -> TriplogEventDetailViewModelProtocol?
}

// MARK: - TriplogEventDetailViewModelProtocol

public protocol TriplogEventDetailViewModelProtocol: AnyObject {
    var tripCoordinates: [CLLocationCoordinate2D] { get }
    var eventType: EventType { get }
    var eventDetail: TripDetailEvent { get }
    var eventCanBeReported: Bool { get }
    var alreadyReported: Bool? { get }
    var mapViewModel: TriplogMapViewModelProtocol? { get }
    var currentFilteringVehicle: VehicleProfileType? { get set }
    func getEventReportViewModel() -> TripDetailReportViewModelProtocol?
}

// MARK: - TripDetailCongratulationsViewModelProtocol

public protocol TripDetailCongratulationsViewModelProtocol: AnyObject {
    var titleText: String { get }
    var score: String { get }
    var majorText: String { get }
}

// MARK: - TripDetailAddressCellProtocol

public protocol TripDetailAddressCellProtocol: UITableViewCell {
    var startAddress: UILabel { get }
    var startDate: UILabel { get }
    var endAddress: UILabel { get }
    var endDate: UILabel { get }
}

// MARK: - SegmentedControllCellProtocol

public protocol SegmentedControllCellProtocol: UITableViewCell {
    var delegate: SegmentedControllDelegate? { get set }
    var selectedSegmentIndex: Int { get set }
}

// MARK: - TripCongratulationsViewCellProtocol

public protocol TripCongratulationsViewCellProtocol: UITableViewCell {
    var viewModel: TripDetailCongratulationsViewModelProtocol? { get set }
}

// MARK: - TripDetailCellProtocol

public protocol TripDetailCellProtocol: UITableViewCell {
    var leftLabel: UILabel { get }
    var rightLabel: UILabel { get }
    var iconColor: UIColor? { get set }
    var separatorView: UIView { get }
}

// MARK: - TripDetailScoreCellProtocol

public protocol TripDetailScoreCellProtocol: TripDetailCellProtocol {
    func configure(with title: String, icon: UIImage?, margins: UIEdgeInsets)
}

// MARK: - TripDetailEventCellProtocol

public protocol TripDetailEventCellProtocol: UITableViewCell {
    var leftLabel: UILabel { get }
    var rightLabel: UILabel { get }
    var iconColor: UIColor? { get set }
}

// MARK: - TripDetailPartialScoreEventCellProtocol

public protocol TripDetailPartialScoreEventCellProtocol: UITableViewCell {
    func update(with eventString: String, severnity: SevernityLevel?, time: String?)
}

// MARK: - SevernityLevel

public enum SevernityLevel: String {
    case zero = "level0"
    case one = "level1"
    case two = "level2"
    case three = "level3"

    public func toColor() -> UIColor {
        switch self {
        case .one:
            return .negativeSeverityLow
        case .two:
            return .negativeSeverityMedium
        case .three:
            return .negativeSeverityHigh
        default:
            return .clear
        }
    }
}

public extension TripDetailEvent {
    var severityLevel: SevernityLevel? {
        guard let severityString = severity else { return nil }
        return SevernityLevel(rawValue: severityString)
    }
}
