import Foundation

enum ApiRouterDrivingModule: ApiEndpoints {
    case config
    case transportType(tripId: String)
    case triplogTripDetail(_ tripId: String)

    var requestMethod: String {
        switch self {
        case .transportType:
            return "POST"
        default:
            return "GET"
        }
    }

    var endpoint: String {
        switch self {
        case .config:
            return "apps/config"
        case let .transportType(tripId: tripId):
            return "triplog/trips/\(tripId)/user-perspective"
        case let .triplogTripDetail(tripId):
            return "triplog/trips/\(tripId)"
        }
    }
}


struct TriplogDetailData: Codable {
    var data: ContainerData
    
    struct ContainerData: Codable {
        var totalScore: Double
    }
            
}
