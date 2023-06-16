import Foundation

enum ApiRouterRewards: ApiEndpoints {
    case rewards(_ requestData: RewardsRequestData)
    case rewardsAwarded(_ requestData: RewardsRequestData)
    case reward(_ id: String)
    case participation(_ rewardId: String)
    case whatsNew(_ since: Date)
    case claim(_ rewardId: String)

    public var requestMethod: String {
        switch self {
        case .participation, .claim(_):
            return "POST"
        default:
            return "GET"
        }
    }

    public var endpoint: String {
        switch self {
        case .rewards:
            return "gamification/contests/available"
        case .rewardsAwarded:
            return "gamification/contests/awarded"
        case let .reward(rewardId):
            return "gamification/contests/\(rewardId)"
        case let .participation(rewardId):
            return "gamification/contests/\(rewardId)/participation"
        case .whatsNew(_):
            return "gamification/contests/whats-new"
        case let .claim(rewardId):
            return "gamification/contests/\(rewardId)/reward-claiming"
        }
    }

    public var version: Int {
        3
    }

    public func queryItems() -> [URLQueryItem]? {
        switch self {
        case let .rewards(requestData), let .rewardsAwarded(requestData):
            return queryItems(from: requestData)
        case let .whatsNew(since):
            return [URLQueryItem(name: "since", value: NetworkManager.shared.dateFormatter.string(from: since))]
        default:
            return nil
        }
    }

    public struct RewardsRequestData: Codable, Hashable {
        var page: Int = 1
        var pageSize: Int = 100
        var isDescending: Bool = true

        public func hash(into hasher: inout Hasher) {
            hasher.combine("\(page)")
        }
    }
}
