import Foundation

public enum ApiRouterBadges: ApiEndpoints {
    case badgeList
    case badgeDetail(_ badgeId: String)
    case whatsNew(_ since: Date)

    public var endpoint: String {
        switch self {
        case .badgeList:
            return "gamification/badges"
        case let .badgeDetail(badgeId):
            return "gamification/badges/\(badgeId)"
        case .whatsNew(_):
            return "gamification/badges/whats-new"
        }
    }

    public func queryItems() -> [URLQueryItem]? {
        switch self {
        case let .whatsNew(since):
            return [URLQueryItem(name: "since", value: NetworkManager.shared.dateFormatter.string(from: since))]
        default:
            return nil
        }
    }
}
