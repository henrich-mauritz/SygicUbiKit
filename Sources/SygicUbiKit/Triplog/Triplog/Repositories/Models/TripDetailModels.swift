import CoreLocation
import UIKit

// MARK: - TripDetailDataProtocol

public protocol TripDetailDataProtocol {
    var tripId: String { get }
    var fromLocationName: String { get }
    var toLocationName: String { get }
    var distanceTravelled: Double { get }
    var averageSpeed: Double { get }
    var maxSpeed: Double { get }
    var startTime: Date { get }
    var endTime: Date { get }
    var coordinates: [CLLocationCoordinate2D]? { get }
    var overallScore: Double { get }
    var events: [TripDetailEventsGroup] { get }
}

// MARK: - EventDetail

public protocol EventDetail {
    var tripId: String { get }
    var eventNumber: Int { get }
    var route: [EventRoute] { get }
}

// MARK: - EventRoute

public protocol EventRoute {
    var coordinates: CLLocationCoordinate2D { get }
    var speedKmH: Double { get }
    var speedLimitKmH: Double { get }
}

// MARK: - TripDetailReportModelProtocol

public protocol TripDetailReportModelProtocol {
    func getEventDetail(_ tripId: String, eventNumber: Int, _ completion: @escaping (Result<EventDetail, Error>) -> ())
    func reportSpeedLimit(reason text: String, suggestedSpeedLimit: Int, tripId: String, eventNumber: Int, reportPoint: CLLocationCoordinate2D, _ completion: @escaping (Result<Bool, Error>) -> ())
}

// MARK: - TripDetailEventsGroup

public protocol TripDetailEventsGroup {
    var type: EventType { get }
    var score: Double { get }
    var items: [TripDetailEvent]? { get }
}

// MARK: - TripDetailEvent

public protocol TripDetailEvent: AnyObject {
    var eventNumber: Int { get }
    var timestamp: Date { get }
    var durationInSeconds: Double { get }
    var severity: String? { get }
    var coordinates: [CLLocationCoordinate2D] { get }
    var speedLimit: Double? { get }
    var actualSpeed: Double? { get }
    var averageSpeed: Double? { get }
    var maxSpeed: Double? { get }
    var canBeReported: Bool { get set }
    var alreadyReported: Bool? { get set }
    func reportSpeedLimitModel() -> TripDetailReportModelProtocol
}

// MARK: - NetworkTripData

public class NetworkTripData: Codable {
    struct ContainerData: Codable {
        class Event: Codable, TripDetailEvent {
            var alreadyReported: Bool?
            var speedLimitKmH: Double?
            var speedKmH: Double?
            var avgSpeedKmH: Double?
            var maxSpeedKmH: Double?
            var timestamp: Date
            var durationInSeconds: Double
            var severity: String?
            var route: String
            var canBeReported: Bool
            var eventNumber: Int

            lazy var polyline: GooglePolyline? = {
                GooglePolyline(encodedPolyline: route)
            }()

            var coordinates: [CLLocationCoordinate2D] { polyline?.coordinates ?? [] }
        }

        struct Events: Codable, TripDetailEventsGroup {
            var type: EventType
            var score: Double
            var events: [Event]
            var items: [TripDetailEvent]? { events }
        }

        struct Coordinate: Codable {
            var latitude: Double
            var longitude: Double
        }

        var id: String
        var startLocation: NetworkLocation
        var endLocation: NetworkLocation
        var averageSpeedKmH: Double
        var maximumSpeedKmH: Double
        var distanceKm: Double
        var totalScore: Double
        var startTime: Date
        var endTime: Date
        var status: String
        var scores: [Events]
        var route: String
    }

    var data: ContainerData

    lazy var polyline: GooglePolyline? = {
        GooglePolyline(encodedPolyline: data.route)
    }()
}

// MARK: - TripEventReportReason

enum TripEventReportReason: String, Codable {
    case speedLimit = "incorrectSpeedLimit"
    case other
}

// MARK: - TripDetailRequestReportData

public struct TripDetailRequestReportData: Codable {
    struct Coordinate: Codable {
        var latitude: Double
        var longitude: Double
    }

    var text: String
    var suggestedSpeedLimit: Int
    var position: Coordinate
}

// MARK: - NetworkEventDetail

public class NetworkEventDetail: Codable {
    struct ContainerData: Codable {
        struct Route: Codable {
            struct Coordinate: Codable {
                var latitude: Double
                var longitude: Double
            }

            var position: Coordinate
            var speedKmH: Double
            var speedLimitKmH: Double
        }

        var tripId: String
        var eventNumber: Int
        var route: [Route]
    }

    var data: ContainerData
}

// MARK: - NetworkEventDetail.ContainerData.Route + EventRoute

extension NetworkEventDetail.ContainerData.Route: EventRoute {
    var coordinates: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: position.latitude, longitude: position.longitude) }
}

// MARK: - NetworkEventDetail + EventDetail

extension NetworkEventDetail: EventDetail {
    public var tripId: String { data.tripId }
    public var eventNumber: Int { data.eventNumber }
    public var route: [EventRoute] { data.route }
}

// MARK: - NetworkTripData.ContainerData.Event + TripDetailReportModelProtocol

extension NetworkTripData.ContainerData.Event: TripDetailReportModelProtocol {
    var speedLimit: Double? { speedLimitKmH }

    var actualSpeed: Double? { speedKmH }

    var maxSpeed: Double? { maxSpeedKmH }

    var averageSpeed: Double? { avgSpeedKmH }

    private struct SomeResult: Codable {}

    func reportSpeedLimitModel() -> TripDetailReportModelProtocol {
        self
    }

    func getEventDetail(_ tripId: String, eventNumber: Int, _ completion: @escaping (Result<EventDetail, Error>) -> ()) {
        NetworkManager.shared.requestAPI(ApiRouterTriplog.triplogEventDetail(tripId, eventNumber)) { (result: Result<NetworkEventDetail, Error>) in
            switch result {
            case let .success(data):
                completion(.success(data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    func reportSpeedLimit(reason text: String, suggestedSpeedLimit: Int, tripId: String, eventNumber: Int, reportPoint: CLLocationCoordinate2D, _ completion: @escaping (Result<Bool, Error>) -> ()) {
        let position = TripDetailRequestReportData.Coordinate(latitude: reportPoint.latitude, longitude: reportPoint.longitude)
        let data = TripDetailRequestReportData(text: text, suggestedSpeedLimit: suggestedSpeedLimit, position: position)
        NetworkManager.shared.requestAPI(ApiRouterTriplog.triplogEventReport(tripId, eventNumber), postData: data) { (result: Result<SomeResult?, Error>) in
            switch result {
            case .success:
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - NetworkTripData + TripDetailDataProtocol

extension NetworkTripData: TripDetailDataProtocol {
    public var tripId: String { data.id }
    // Map view
    public var fromLocationName: String { data.startLocation.fullAddress }
    public var toLocationName: String { data.endLocation.fullAddress }
    public var distanceTravelled: Double { data.distanceKm }
    public var averageSpeed: Double { data.averageSpeedKmH }
    public var maxSpeed: Double { data.maximumSpeedKmH }
    public var startTime: Date { data.startTime }
    public var endTime: Date { data.endTime }
    public var coordinates: [CLLocationCoordinate2D]? { polyline?.coordinates }
    public var overallScore: Double { data.totalScore }

    // Events
    public var events: [TripDetailEventsGroup] { data.scores }
}
