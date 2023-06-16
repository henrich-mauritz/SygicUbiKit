import Foundation

// MARK: - RewardError

public enum RewardError: LocalizedError {
    case unavailable
    case cacheNotFound(detailId: String?)
    case noInternetConnection
    case unknown

    init(from error: Error) {
        if case NetworkError.httpError(code: let errorCode, userInfo: _) = error, errorCode == 422 {
            self = .unavailable
        } else if case NetworkError.noInternetConnection = error {
            self = .noInternetConnection
        } else {
            self = .unknown
        }
    }

    init(statusCode: Int) {
        switch statusCode {
        case 422:
            self = .unavailable
        default:
            self = .unknown
        }
    }

    public var errorDescription: String? {
        switch self {
        case let .cacheNotFound(detailId):
            return "cache for detail ::: \(detailId ?? "LIST") :::, not found" //not to be used in UI no need to localized
        case .unavailable:
            return "rewards.error.notAvailable".localized
        default:
            return "unknown"
        }
    }
}

// MARK: Equatable

extension RewardError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.unavailable, .unavailable):
            return true
        case (.unknown, .unknown):
            return true
        case let (.cacheNotFound(detail1), .cacheNotFound(detail2)):
            return detail1 == detail2
        case (.noInternetConnection, .noInternetConnection):
            return true
        default:
            return false
        }
    }
}
