import Foundation

public enum ApiRouterTriplog: ApiEndpoints {
    case triplogCurrentPeriod(_ vehicleId: String?)
    case triplogPeriodOverView(_ detailId: String, vehicleId: String?)
    case triplogTrips(_ requestData: ApiRouterTriplog.TripsRequestData)
    case triplogTripDetail(_ tripId: String)
    case triplogEventDetail(_ tripId: String, _ eventNumber: Int)
    case triplogEventReport(_ tripId: String, _ eventNumber: Int)

    public var requestMethod: String {
        switch self {
        case .triplogEventReport:
            return "POST"
        default:
            return "GET"
        }
    }

    public struct TripsRequestData: Codable, Hashable {
        var detailId: String
        var page: Int = 1
        var pageSize: Int = 20
        var isDescending: Bool = true
        var vehicleId: String?

        public func hash(into hasher: inout Hasher) {
            hasher.combine(detailId)
            hasher.combine("\(page)")
            hasher.combine(vehicleId)
        }
    }

    public var endpoint: String {
        switch self {
        case .triplogCurrentPeriod:
            return "triplog/period-overview/current"
        case let .triplogPeriodOverView(detailId, _):
            return "triplog/period-overview/\(detailId)"
        case .triplogTrips:
            return "triplog/trips"
        case let .triplogTripDetail(tripId):
            return "triplog/trips/\(tripId)"
        case let .triplogEventDetail(tripId, eventNumber):
            return "triplog/trips/\(tripId)/events/\(eventNumber)"
        case let .triplogEventReport(tripId, eventNumber):
            return "triplog/trips/\(tripId)/events/\(eventNumber)/speed-limit-inconsistency"
        }
    }

    public func queryItems() -> [URLQueryItem]? {
        if case let .triplogTrips(requestData) = self {
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "detailId", value: requestData.detailId),
                URLQueryItem(name: "page", value: "\(requestData.page)"),
                URLQueryItem(name: "pageSize", value: "\(requestData.pageSize)"),
                URLQueryItem(name: "isDescending", value: "\(requestData.isDescending)"),
            ]
            if let vid = requestData.vehicleId {
                queryItems.append(URLQueryItem(name: "vehicleId", value: "\(vid)"))
            }
            return queryItems
        } else {
            var queryItemVehicleId: String?
            switch self {
            case let .triplogCurrentPeriod(vehicleId):
                queryItemVehicleId = vehicleId
            case let .triplogPeriodOverView(_, vehicleId):
                queryItemVehicleId = vehicleId
            default:
                return nil
            }
            guard let queryItemVehicleId = queryItemVehicleId else {
                return nil
            }
            return [URLQueryItem(name: "vehicleId", value: queryItemVehicleId)]
        }
    }
}
