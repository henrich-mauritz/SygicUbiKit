import Foundation

// MARK: - AppUpdateType

public enum AppUpdateType: String {
    case none
    case updateAvailable
    case updateRequired
}

// MARK: - AppUpdateData

public struct AppUpdateData: Codable {
    struct Container: Codable {
        var updateAction: String
    }

    var data: Container

    public var updateType: AppUpdateType? {
        return AppUpdateType(rawValue: data.updateAction)
    }
}
