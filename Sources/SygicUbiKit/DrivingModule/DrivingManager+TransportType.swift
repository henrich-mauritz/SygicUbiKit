import Foundation

// MARK: - DrivingTransportType

public enum DrivingTransportType: Int {
    case driver
    case bus
    case train
    case passenger
    case other
}

// MARK: - DrivingManagerPendingTripError

public enum DrivingManagerPendingTripError: LocalizedError {
    case invalidTripId
    case failed
    case serverError(_ error: Error)
    case unknown
    case notAllowedTimeWindowElapsed
    case notAllowedAlreadySet
    case vehicleNotFound
    case invalidVehicleProfile
    case offSeasonVehicle

    init(with networkError: NetworkError) {
        guard let userInfo = networkError.httpUserInfo,
              let data = userInfo["data"] as? [String: Any],
              let reason = data["reason"] as? String else {
                  self = .unknown
                  return
              }
        switch reason {
        case "notAllowedTimeWindowElapsed":
            self = .notAllowedTimeWindowElapsed
        case "notAllowedAlreadySet":
            self = .notAllowedAlreadySet
        case "vehicleNotFound":
            self = .vehicleNotFound
        case "notAllowedInvalidVehicleProfile":
            self = .invalidVehicleProfile
        default:
            self = .unknown
        }
    }
}

// MARK: Equatable

extension DrivingManagerPendingTripError: Equatable {
    public static func == (lhs: DrivingManagerPendingTripError, rhs: DrivingManagerPendingTripError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidTripId, .invalidTripId):
            return true
        case (.failed, .failed):
            return true
        case (.unknown, .unknown):
            return true
        case let (.serverError(error1), .serverError(error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.notAllowedTimeWindowElapsed, .notAllowedTimeWindowElapsed):
            return true
        case (.notAllowedAlreadySet, .notAllowedAlreadySet):
            return true
        case (.vehicleNotFound, .vehicleNotFound):
            return true
        case (.invalidVehicleProfile, .invalidVehicleProfile):
            return true
        default:
            return false
        }
    }
}

public extension DrivingManager {
    func confirmTrip(tripId: String, transportType: DrivingTransportType, vehicle: VehicleProfileType?, completion: @escaping ((DrivingManagerPendingTripError?) -> Void)) {
        let postData = TransportRequestData(asDriver: transportType == .driver,
                                            vehicle: vehicle,
                                            transportType: transportType)
        NetworkManager.shared.requestAPI(ApiRouterDrivingModule.transportType(tripId: tripId), postData: postData) { (result: Result<TransportResponseData?, Error>) in
            switch result {
            case .success:
                completion(nil)
            case let .failure(error):
                guard let error = error as? NetworkError else {
                    completion(.failed)
                    return
                }
                completion(DrivingManagerPendingTripError(with: error))
            }
        }
    }
}

extension DrivingTransportType {
    var requestVehicleType: String {
        switch self {
        case .driver:
            return "car"
        case .passenger:
            return "car"
        case .train:
            return "train"
        case .bus:
            return "publicTransport"
        default:
            return "unknown"
        }
    }
}

// MARK: - TransportRequestData

struct TransportRequestData: Codable {
    struct Perspective: Codable {
        var userAsDriver: Bool
        var vehicleType: String
        var vehicleId: String?
    }

    var perspective: Perspective

    init(asDriver: Bool, vehicle: VehicleProfileType?, transportType: DrivingTransportType) {
        perspective = Perspective(userAsDriver: asDriver,
                                  vehicleType: vehicle != nil ? vehicle!.vehicleType.rawValue : transportType.requestVehicleType,
                                  vehicleId: vehicle?.publicId)
    }

    init(with transportType: DrivingTransportType, vehicleId: String?) {
        perspective = Perspective(userAsDriver: transportType == .driver, vehicleType: transportType.requestVehicleType, vehicleId: vehicleId)
    }
}

// MARK: - TransportResponseData

struct TransportResponseData: Codable {}
