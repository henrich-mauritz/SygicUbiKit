import Foundation

public enum NewsError: LocalizedError {
    case notFound

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "news.errorDescription.notFound".localized
        }
    }
}
