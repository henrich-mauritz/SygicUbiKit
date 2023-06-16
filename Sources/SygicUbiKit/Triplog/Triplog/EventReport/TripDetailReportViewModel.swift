import Foundation
import MapKit

public class TripDetailReportViewModel: TripDetailReportViewModelProtocol {
    public var tripCoordinates: [CLLocationCoordinate2D]?
    public var eventDetail: TripDetailEvent?
    public var tripId: String?
    public var eventNumber: Int?
    public var model: TripDetailReportModelProtocol?
    public var speedLimit: Double?
    public var reportPoint: CLLocationCoordinate2D?
    public var route: [EventRoute]? { data?.route }
    public var currentFilteringVehicle: VehicleProfileType?

    public weak var delegate: TripDetailReportViewModelDelegate?

    private var data: EventDetail? {
        didSet {
            delegate?.viewModelUpDated()
        }
    }

    public func getEventDetail() {
        guard let tripId = tripId, let eventNumber = eventNumber else { return }
        model?.getEventDetail(tripId, eventNumber: eventNumber) { result in
            switch result {
                case let .success(data):
                    self.data = data
                case let .failure(e):
                    print("error in getting event detail: \(e.localizedDescription)")
            }
        }
    }

    public func reportSpeedLimit(_ reason: String, speedLimit: Int, completion: @escaping (Result<Bool, Error>) -> ()) {
        guard let model = model, let tripId = tripId, let eventNumber = eventNumber, let reportPoint = reportPoint else { return }
        let eventPoint = getClosestReportPoint(point: reportPoint)?.coordinates ?? reportPoint
        model.reportSpeedLimit(reason: reason, suggestedSpeedLimit: speedLimit, tripId: tripId, eventNumber: eventNumber, reportPoint: eventPoint) {[weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(reported):
                self.eventDetail?.alreadyReported = reported
            case let .failure(error):
                print(":::There was some error in the response \(error.localizedDescription)")
            }
            completion(result)
        }
    }

    public func getClosestReportPoint(point: CLLocationCoordinate2D) -> EventRoute? {
        guard let route = route else { return nil }
        var closest: EventRoute?
        var minDistance = MAXFLOAT
        for routePoint: EventRoute in route {
            let distance = Float(MKMapPoint(point).distance(to: MKMapPoint(routePoint.coordinates)))
            if distance < minDistance {
                minDistance = distance
                closest = routePoint
            }
        }
        return closest
    }
}
