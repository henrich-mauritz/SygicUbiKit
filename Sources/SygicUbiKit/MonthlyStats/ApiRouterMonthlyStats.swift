import Foundation

public enum ApiRouterMonthlyStats: ApiEndpoints {
    case monthlyStats(_ dateId: String?, _ vehicleId: String?)
    case current(_ vehicleId: String?)
    case listReports(_ vehicleId: String?)

    public var endpoint: String {
        switch self {
        case let .monthlyStats(dateId, _):
            if let dateId = dateId {
                return "monthly-reports/\(dateId)"
            } else {
                return "monthly-reports/current"
            }
        case .current(_):
            return "monthly-reports/current"
        case .listReports(_):
            return "monthly-reports"
        }
    }

    public var version: Int { 2 }

    public func queryItems() -> [URLQueryItem]? {
        var vId: String?
        switch self {
        case let .monthlyStats(_, vehicleId):
            vId = vehicleId
        case let .current(vehicleId):
            vId = vehicleId
        case let .listReports(vehicleId):
            vId = vehicleId
        }
        guard let vId = vId else {
            return nil
        }
        return [URLQueryItem(name: "vehicleId", value: vId)]
    }
}
