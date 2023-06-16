import Foundation

public enum GeneralError: LocalizedError {
    case notFound
    case unknown

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "common.generalError.notFound".localized
        default:
            return "common.generalError.unknown".localized
        }
    }
}
