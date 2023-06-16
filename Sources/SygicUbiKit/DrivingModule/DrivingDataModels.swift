import Foundation
import Driving

// MARK: - TripEvent

public struct TripEvent: Identifiable, Equatable {
    public var id: Int32 {
        event.eventId
    }

    public var type: SygicTripEventType {
        event.eventType
    }

    public var location: CLLocation? {
        event.eventPosition
    }

    public var event: SygicTripEvent
    var status: EventStatus

    public static func == (lhs: TripEvent, rhs: TripEvent) -> Bool {
           lhs.id == rhs.id
       }

       public static func == (lhs: TripEvent, rhs: SygicTripEvent) -> Bool {
              lhs.id == rhs.eventId
       }

       public static func == (lhs: SygicTripEvent, rhs: TripEvent) -> Bool {
              lhs.eventId == rhs.id
       }

    enum EventStatus {
        case started, updated, ended
    }
}

// MARK: - DrivingError

public enum DrivingError: Error {
    case noUUID
    case dbLibInit(_ error: Error)
    case cannotInitialize

    var localizedDescription: String {
        switch self {
        case let .dbLibInit(error):
            return error.localizedDescription
        case .cannotInitialize:
            return "Multiple attempts failed to initialize DB lib"
        default:
            return "Unknown driving error"
        }
    }
}

public extension SygicTripUploadError {
    var localizedMessage: String {
        switch self {
        case .none:
            return ""
        case .unknown:
            return String(format: "driving.summary.errorGeneral".localized, "200-3")
        case .invalidStartEnd:
            return "driving.summary.errorTimeDate".localized
        case .invalidDurationTooShort:
            let localizedFormat = "driving.summary.errorDuration".localized
            let valueFormated = String(format: "%.0f", DrivingResultViewModel.durationThreshold / 60)
            return String(format: localizedFormat, valueFormated)
        case .invalidDistanceTooShort:
            let localizedFormat = "driving.summary.errorDistance".localized
            let valueFormated = String(format: "%.0f", DrivingResultViewModel.distanceThreshold)
            return String(format: localizedFormat, valueFormated)
        case .fraudBehaviourDetected:
            return "driving.summary.errorMultipleAccounts".localized
        case .uploadFailed:
            return "driving.summary.errorUpload".localized
        case .invalidInput:
            return String(format: "driving.summary.errorGeneral".localized, "200-1")
        case .invalidEvent:
            return String(format: "driving.summary.errorGeneral".localized, "200-2")
        case .timePeriodProhibited:
            return ""
        default:
            return ""
        }
    }
    
}

extension SygicTripEventType {
    var stringType: String {
        switch self {
        case .acceleration:
            return "Acceleration"
        case .braking:
            return "Braking"
        case .cornering:
            return "Cornering"
        case .speeding:
            return "Speeding"
        default:
            return "other"
        }
    }
}
