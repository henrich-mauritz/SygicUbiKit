import Foundation

// MARK: - NetworkError

public enum NetworkError: LocalizedError {
    case noInternetConnection
    case serverUnavailable
    case invalidToken
    case httpError(code: Int, userInfo: [String: Any]? = nil)
    case decodingError
    case expiredSecureUserId
    case urlErrorDomain(error: Error)
    case unknown

    public static func error(from error: NSError?) -> NetworkError {
        if #available(iOS 13.0, *) {
            if let customError = error as? NetworkError {
                return customError
            }
        }
        guard let error = error else { return .unknown }
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorTimedOut:
                return .noInternetConnection
            case NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorDNSLookupFailed:
                return .serverUnavailable
            default:
                return .urlErrorDomain(error: error)
            }
        }
        return .unknown
    }

    public var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "no_internet_connection_error"
        case .serverUnavailable:
            return "server_unavaiable_error"
        case let .httpError(code, _):
            if code >= 400 && code <= 599 {
                return "networking.serverErrorDesction".localized
            }
            return "http_error_code_\(code)"
        case .decodingError:
            return "decoding_error"
        case .invalidToken:
            return "invalid_token_error"
        case .expiredSecureUserId:
            return "expired_secure_userid"
        case let .urlErrorDomain(error: error):
            return error.localizedDescription
        default:
            return "unknown_error"
        }
    }

    public var httpErrorCode: Int? {
        switch self {
        case let .httpError(code, _):
            return code
        default:
            return nil
        }
    }

    public var httpUserInfo: [String: Any]? {
        switch self {
        case let .httpError(_, userInfo):
            return userInfo
        default:
            return nil
        }
    }
}

// MARK: Equatable

extension NetworkError: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (noInternetConnection, .noInternetConnection):
            return true
        case (.serverUnavailable, .serverUnavailable):
            return true
        case (.invalidToken, .invalidToken):
            return true
        case let (.httpError(code1, _), .httpError(code2, _)):
            return code1 == code2
        case (.decodingError, .decodingError):
            return true
        case (.expiredSecureUserId, .expiredSecureUserId):
            return true
        default:
            return false
        }
    }
}
