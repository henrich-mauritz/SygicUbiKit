import CoreLocation
import Swinject
import UIKit

// MARK: - TripDetailPageType

public enum TripDetailPageType: Int {
    case map = 0, score
}

// MARK: - SegmentedControllDelegate

public protocol SegmentedControllDelegate: AnyObject {
    func switchTableContent(to: TripDetailPageType)
}

// MARK: - TripDetailViewModel

public class TripDetailViewModel: TripDetailViewModelProtocol, InjectableType {
    public var tripID: String?
    public var monthData: TriplogTripDataType?

    public weak var delegate: TriplogViewModelDelegate?
    // Map view
    public private(set) var loading: Bool = false
    public var fromLocationName: String { detailData?.fromLocationName ?? monthData?.locationStartName ?? "" }
    public var toLocationName: String { detailData?.toLocationName ?? monthData?.locationEndName ?? ""}
    public var distanceTravelled: String {
        let newValue = detailData?.distanceTravelled ?? monthData?.distanceKm ?? 0
        return "\(NumberFormatter().distanceTraveledFormatted(value: newValue)) km"
    }

    public var tripDuration: String { durationFormatted }
    public var averageSpeed: String { formatSpeed(speed: detailData?.averageSpeed ?? 0) }
    public var maxSpeed: String { formatSpeed(speed: detailData?.maxSpeed ?? 0) }
    public var startTime: Date { detailData?.startTime ?? monthData?.startTime ?? Date() }
    public var endTime: Date { detailData?.endTime ?? monthData?.endTime ?? Date() }
    public var coordinates: [CLLocationCoordinate2D]? { detailData?.coordinates }
    public var currentFilteringVehicle: VehicleProfileType?
    public var mapViewModel: TriplogMapViewModelProtocol? {
        guard let data = detailData else { return nil }
        let mapViewModel = TriplogMapViewModel(with: data, forVehicle: currentFilteringVehicle?.vehicleType ?? .car)
        return mapViewModel
    }

    public var vehicleId: String?

    // Score view
    public var overallScore: String {
        let score = detailData?.overallScore ?? monthData?.overallScore ?? 0
        return Format.scoreFormatted(value: score)
    }

    public var isPerfectTrip: Bool {
        guard let tripScore = detailData?.overallScore, let eventsData = detailData?.events else { return false }
        for eventType in eventsData {
            if eventType.score < 100 {
                return false
            }
            if let events = eventType.items, events.count > 0 {
                return false
            }
        }
        return tripScore == 100
    }

    public var eventTableData: [TripDetailDataRow] {
        guard let eventsData = detailData?.events else { return [] }
        guard let currentFilteringVehicle = currentFilteringVehicle, currentFilteringVehicle.vehicleType == .motorcycle else {
            return eventsData.map { TripDetailDataRow(eventType: $0.type, eventScore: $0.score) }
        }

        return eventsData.filter { $0.type != .distraction }.map { TripDetailDataRow(eventType: $0.type, eventScore: $0.score) }
    }

    public var mapTableData: [(name: String, description: String)] {
        [
            (name: "triplog.tripDetail.tripScore".localized, description: overallScore),
            (name: "triplog.tripDetail.distance".localized, description: distanceTravelled),
            (name: "triplog.tripDetail.duration".localized, description: tripDuration),
            (name: "triplog.tripDetail.averageSpeed".localized, description: averageSpeed),
            (name: "triplog.tripDetail.maximumSpeed".localized, description: maxSpeed),
        ]
    }

    private var detailData: TripDetailDataProtocol?

    private var durationFormatted: String {
        var startTime: Date?
        var endTime: Date?
        if let detailData = detailData {
            startTime = detailData.startTime
            endTime = detailData.endTime
        } else if let overviewData = monthData {
            startTime = overviewData.startTime
            endTime = overviewData.endTime
        }
        guard let startDate = startTime, let endDate = endTime else { return "" }
        let duration = endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [ .minute, .hour ]
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = [ .dropLeading ]
        return formatter.string(from: duration) ?? ""
    }

    private lazy var repository: TripDetailRepositoryType = container.resolveTripDetailRepo()

    //MARK: - Lifecicle

    public func getEventsData(for type: EventType) -> TripDetailEventsGroup? {
        return detailData?.events.first(where: { $0.type == type })
    }

    public func getCongratulationsViewModel() -> TripDetailCongratulationsViewModelProtocol {
        return TripDetailCongratulationsViewModel()
    }

    public func getPartialScoreViewModel(for type: EventType) -> TripDetailPartialScoreViewModelProtocol? {
        guard let eventsData = getEventsData(for: type),
            let coordinates = coordinates,
            let tripId = detailData?.tripId else { return nil }
        let partialModel = TripPartialScoreModel(tripId: tripId, data: eventsData, tripCoordinates: coordinates)
        let partialViewModel = container.resolve(TripDetailPartialScoreViewModelProtocol.self, argument: partialModel as TripDetailPartialScoreModelProtocol)
        partialViewModel?.currentFilteringVehicle = self.currentFilteringVehicle
        return partialViewModel
    }

    private func formatSpeed(speed: Double) -> String {
        return (speed < 130) ? String(format: "%.0f km/h", speed) : "130+ km/h"
    }

    public func loadData() {
        guard let finalId = monthData?.id ?? tripID else {
            print("No id to load")
            return
        }
        loading = true
        repository.fetchTripDetail(with: finalId) {[weak self] result in
            guard let self = self else { return }
            self.loading = false
            switch result {
            case let .success(data):
                self.detailData = data
                self.delegate?.viewModelUpdated(self)
            case let .failure(error):
                print("Networking error: \(error)")
            }
        }
    }

    private func copyrightTextAttributes(for link: String?) -> [NSAttributedString.Key: Any] {
        let color = UIColor.foregroundPrimary.withAlphaComponent(0.4)
        let font = UIFont.stylingFont(.regular, with: 10)
        var attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
        ]
        if let link = link, let url = URL(string: link) {
            attributes[NSAttributedString.Key.link] = url
            attributes[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return attributes
    }
}

// MARK: - TripDetailCongratulationsViewModel

public class TripDetailCongratulationsViewModel: TripDetailCongratulationsViewModelProtocol {
    public var titleText: String { "triplog.tripDetailScore.perfectScoreDescription".localized }
    public var majorText: String { "triplog.tripDetailScore.perfectScoreCongrat".localized }
    public var score: String { "100" }
}

// MARK: - TripDetailDataRow

public struct TripDetailDataRow {
    public var eventType: EventType
    public var eventScore: Double
    public var color: UIColor { eventType.eventColor() }
    public var formattedEventName: String { eventType.formattedString() }
    public var formattedScore: String { Format.scoreFormatted(value: eventScore) }
}

// MARK: - TripEventRow

public struct TripEventRow {
    public var eventId: Int
    public var eventIntensity: Int
}
