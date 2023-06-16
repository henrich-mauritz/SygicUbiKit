import CoreLocation
import Foundation
import Swinject

// MARK: - TriplogEventDetailModelProtocol

public protocol TriplogEventDetailModelProtocol {
    var tripId: String { get }
    var eventType: EventType { get }
    var eventDetail: TripDetailEvent { get }
    var tripCoordinates: [CLLocationCoordinate2D] { get }
}

// MARK: - TripEventDetailModel

public struct TripEventDetailModel: TriplogEventDetailModelProtocol {
    public let tripId: String
    public let eventType: EventType
    public let eventDetail: TripDetailEvent
    public let tripCoordinates: [CLLocationCoordinate2D]
}

// MARK: - TriplogEventDetailViewModel

public class TriplogEventDetailViewModel: TriplogEventDetailViewModelProtocol {
    public var eventType: EventType { model.eventType }

    public var eventDetail: TripDetailEvent { model.eventDetail }

    public var tripCoordinates: [CLLocationCoordinate2D] { model.tripCoordinates }

    public var currentFilteringVehicle: VehicleProfileType?

    public var eventCanBeReported: Bool { eventType == .speeding && eventDetail.canBeReported && TripLogSettingsManager.shared.currentSettings.eventReportingEnabled }

    public var alreadyReported: Bool? { eventDetail.alreadyReported }

    public var mapViewModel: TriplogMapViewModelProtocol? {
        let mapViewModel = TriplogMapViewModel(with: [(items: [model.eventDetail],
                                                       type: model.eventType)],
                                               tripId: model.tripId,
                                               tripCoordinates: model.tripCoordinates,
                                               zoomCoordinates: eventDetail.coordinates)
        mapViewModel.shouldSelectPins = false
        mapViewModel.animate = true
        return mapViewModel
    }

    public var container: Container?

    private let model: TriplogEventDetailModelProtocol

    public required init(model: TriplogEventDetailModelProtocol) {
        self.model = model
    }

    public func getEventReportViewModel() -> TripDetailReportViewModelProtocol? {
        guard eventDetail.canBeReported else { return nil }
        var reportViewModel = container?.resolve(TripDetailReportViewModelProtocol.self)
        reportViewModel?.model = eventDetail.reportSpeedLimitModel()
        reportViewModel?.speedLimit = model.eventDetail.speedLimit ?? 0
        reportViewModel?.eventNumber = eventDetail.eventNumber
        reportViewModel?.tripId = model.tripId
        reportViewModel?.tripCoordinates = tripCoordinates
        reportViewModel?.eventDetail = eventDetail
        reportViewModel?.currentFilteringVehicle = self.currentFilteringVehicle
        return reportViewModel
    }
}
