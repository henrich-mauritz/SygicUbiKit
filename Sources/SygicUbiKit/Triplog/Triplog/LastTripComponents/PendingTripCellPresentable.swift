import Foundation

// MARK: - PendingTripCellPresentable

public protocol PendingTripCellPresentable {
    var id: String { get }
    var startTime: Date { get }
    var endTime: Date { get }
    var locationStartName: String { get }
    var locationEndName: String { get }
    var distanceKm: Double { get }
    var address: String { get }
    var date: String { get }
    var time: String { get }
    var status: PendingTripPendingStatus { get set }
    var selectedVehicle: VehicleProfileType? { get set }
}

// MARK: - PendingTripType

public protocol PendingTripType {
    var id: String { get }
    var startTime: Date { get }
    var endTime: Date { get }
    var locationStartName: String { get }
    var locationEndName: String { get }
    var distanceKm: Double { get }
    var vehiclePublicId: String? { get }
}

// MARK: - PendingTripPendingStatus

public enum PendingTripPendingStatus: String {
    case waitingForEvaluation
    case markingAsPassanger
    case failed

    public init(rawValue: String) {
        switch rawValue {
        case "markingAsPassanger":
            self = .markingAsPassanger
        case "failed":
            self = .failed
        default:
            self = .waitingForEvaluation
        }
    }
}

// MARK: - PendingTripCellViewModel

public class PendingTripCellViewModel: PendingTripCellPresentable, InjectableType {
    public var selectedVehicle: VehicleProfileType?
    public var id: String
    public var startTime: Date
    public var endTime: Date
    public var locationStartName: String
    public var locationEndName: String
    public var distanceKm: Double
    public var address: String { locationEndName }

    public var date: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter.string(from: endTime)
    }

    public var time: String {
        let endtimeString = endTime.hourInDayFormat()
        let startTimeString = startTime.hourInDayFormat()
        return "\(startTimeString)–\(endtimeString)"
    }

    public var status: PendingTripPendingStatus = .waitingForEvaluation

    public init(pendingTrip: PendingTripType) {
        self.id = pendingTrip.id
        self.startTime = pendingTrip.startTime
        self.endTime = pendingTrip.endTime
        self.distanceKm = pendingTrip.distanceKm
        self.locationStartName = pendingTrip.locationStartName
        self.locationEndName = pendingTrip.locationEndName
        let repo = container.resolveVehicleProfileRepo()
        if repo.storedVehicles.count > 1 {
            let vehicleById = repo.storedVehicles.first(where: { $0.publicId == pendingTrip.vehiclePublicId })
            selectedVehicle = vehicleById ?? repo.storedVehicles.first(where: { $0.isSelectedForDriving == true })
        }
    }
}
