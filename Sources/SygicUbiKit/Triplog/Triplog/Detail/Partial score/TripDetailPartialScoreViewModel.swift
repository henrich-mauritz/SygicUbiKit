import CoreLocation
import Foundation
import Swinject

// MARK: - TripDetailPartialScoreModelProtocol

public protocol TripDetailPartialScoreModelProtocol {
    var tripId: String { get }
    var data: TripDetailEventsGroup { get }
    var tripCoordinates: [CLLocationCoordinate2D] { get }
}

// MARK: - TripPartialScoreModel

public struct TripPartialScoreModel: TripDetailPartialScoreModelProtocol {
    public let tripId: String
    public let data: TripDetailEventsGroup
    public let tripCoordinates: [CLLocationCoordinate2D]
}

// MARK: - TripDetailSelectionViewModel

public class TripDetailSelectionViewModel: TripDetailPartialScoreViewModelProtocol, InjectableType {
    public var currentFilteringVehicle: VehicleProfileType?
    public var events: [TripDetailEvent] { eventData.items ?? [] }
    public var scoreDescription: String { eventData.type.formattedScoreString() }

    public var score: String {
        let score = eventData.score
        return Format.scoreFormatted(value: score)
    }

    public var eventType: EventType { eventData.type }

    public var tripCoordinates: [CLLocationCoordinate2D] { model.tripCoordinates }

    public var mapViewModel: TriplogMapViewModelProtocol? {
        let eventCoordinates = events.flatMap {$0.coordinates}
        let zoomCoordinates = eventCoordinates.isEmpty ? model.tripCoordinates : eventCoordinates
        let mapViewModel = TriplogMapViewModel(with: [(items: model.data.items ?? [],
                                                       type: model.data.type)],
                                               tripId: model.tripId,
                                               tripCoordinates: model.tripCoordinates,
                                               zoomCoordinates: zoomCoordinates)
        mapViewModel.animate = true
        return mapViewModel
    }

    private var eventData: TripDetailEventsGroup { model.data }

    private var model: TripDetailPartialScoreModelProtocol

    public required init(with model: TripDetailPartialScoreModelProtocol) {
        self.model = model
    }

    public var isPerfectScore: Bool {
        return eventData.score == 100 && events.count == 0
    }

    public func getCongratulationsViewModel() -> TripDetailCongratulationsViewModelProtocol {
        return TripDetailCongratulationsViewModel()
    }

    public func getEventDetailViewModel(for event: TripDetailEvent) -> TriplogEventDetailViewModelProtocol? {
        let eventModel = TripEventDetailModel(tripId: model.tripId,
                                              eventType: eventType,
                                              eventDetail: event,
                                              tripCoordinates: tripCoordinates)
        return container.resolve(TriplogEventDetailViewModelProtocol.self, argument: eventModel as TriplogEventDetailModelProtocol)
    }
}
